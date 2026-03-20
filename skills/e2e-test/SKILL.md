---
name: e2e-test
description: E2E API 테스트. spec MD + 코드 분석 기반으로 curl 테스트 시나리오를 생성/실행. DB/서버 자동 기동/종료 포함. Use /e2e-test to run end-to-end API tests.
user-invocable: true
disable-model-invocation: false
allowed-tools: Bash, Read, Write, Glob, Grep, Agent, AskUserQuestion, Skill, mcp__atlassian__jira_create_issue, mcp__atlassian__jira_update_issue, mcp__atlassian__jira_get_issue
---

# E2E API 테스트

spec MD와 코드 구현부를 분석하여 curl 기반 E2E 테스트 시나리오를 자동 생성/실행한다.
DB, 서버 기동/종료까지 전체 라이프사이클을 관리한다.
설정은 `config.yaml`의 `test`, `server`, `jira` 섹션을 참조한다.

## Usage

```
/e2e-test {모듈} {spec명}
/e2e-test api 옵션그룹목록
```

---

## Step 0: 입력 확인

인자가 없으면 AskUserQuestion으로 질문:
1. **모듈**: config.yaml의 `server.modules` 목록에서 선택
2. **spec**: config.yaml의 `test.spec_dir` 디렉토리에서 MD 파일 목록 제시

---

## Step 1: 환경 기동

### 1-1. 인프라 확인/기동
인프라 상태 확인 → 미실행 시 `/db up` 스킬 실행.

### 1-2. 서버 확인/기동
해당 모듈 서버 상태 확인 → 미실행 시 `/server {모듈} up` 스킬 실행.

### 1-3. 헬스체크
config.yaml의 `server.modules[].health` 엔드포인트로 확인.

---

## Step 2: spec + 코드 분석

### 2-1. spec MD 로드
`{test.spec_dir}/{spec명}.md` 파일에서 추출:
- API 대상 기능, 조회 조건, 결과 구조, 비즈니스 규칙, 연관 API

### 2-2. 코드 구현부 분석
해당 모듈의 코드를 탐색:
- **Controller**: API 엔드포인트, 파라미터, 응답 타입
- **DTO**: 요청/응답 필드, `@Valid` 유효성 검증
- **Service**: 비즈니스 로직 분기, 예외 처리
- **Repository**: 쿼리 조건, 정렬, 페이징

---

## Step 3: 테스트 시나리오 생성

### 카테고리
1. **정상 케이스** — spec 명세대로 API 호출, 응답 검증
2. **엣지 케이스** — 코드 분기에서 도출 (경계값, 조합, 빈 결과)
3. **에러 케이스** — 유효성 검증 실패, 예외 상황

### 시나리오 포맷
```
[TC-001] {카테고리}: {테스트명}
- 엔드포인트: {METHOD} {URL}
- 요청: {헤더, 파라미터}
- 기대: {상태코드, 응답 구조}
```

---

## Step 4: 인증 토큰 확보

config.yaml의 `test.auth` 설정에 따라 토큰 발급:

```bash
TOKEN=$(curl -s -X POST http://localhost:{port}{auth.login_endpoint} \
  -H "Content-Type: application/json" \
  -d '{auth.login_body}' | python3 -c "import sys,json; print(json.load(sys.stdin){token_path_parsing})")
```

`test.auth.type`이 `none`이면 건너뛴다.
실패 시 AskUserQuestion으로 토큰 직접 입력 요청.

---

## Step 5: 테스트 실행

생성된 시나리오를 순차 curl 실행.

```bash
response=$(curl -s -w "\n%{http_code}" {curl_opts} \
  -H "Authorization: Bearer $TOKEN" \
  "http://localhost:{port}{endpoint}")
# 상태코드 + 응답 구조 검증
```

---

## Step 6: 결과 리포트

```
## E2E 테스트 결과

| 항목 | 수 |
|------|-----|
| 총 테스트 | {N} |
| ✅ PASS | {N} |
| ❌ FAIL | {N} |

### 상세
| # | 카테고리 | 테스트명 | 결과 | 비고 |
```

---

## Step 7: Jira 연동

config.yaml의 `jira.enabled`가 true인 경우만.

AskUserQuestion:
- 기존 티켓에 결과 추가 / 새 티켓 생성 / 안 함

---

## Step 8: 환경 종료

AskUserQuestion:
- 전부 종료 (서버 + DB) / 서버만 종료 / 유지

---

## 제약사항

| 항목 | 필요 조건 |
|------|-----------|
| 인프라 | `/db` 스킬 설정 완료 |
| 서버 | `/server` 스킬 설정 완료 |
| spec MD | `/analyze-spec`으로 사전 생성 |
| 인증 | config.yaml `test.auth` 설정 |
| Jira | `atlassian` MCP (선택) |
