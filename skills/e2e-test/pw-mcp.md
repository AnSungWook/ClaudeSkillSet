# MCP Playwright 브라우저 E2E 테스트

`/e2e-test pw {모듈} {spec}` 으로 호출됨.

## 목적

MCP Playwright 도구로 Swagger/Scalar UI 브라우저 E2E + curl 하이브리드로 테스트를 수행한다.

## 하이브리드 전략 (핵심)

| HTTP 메소드 | 도구 | 이유 |
|------------|------|------|
| **GET** | MCP Playwright (API 문서 UI) | Query Params 입력이 폼 기반이라 ref로 정확히 타겟팅 가능 |
| **POST/PUT/PATCH/DELETE** | curl (Bash) | Body 에디터가 CodeMirror 등이라 MCP로 값 교체 불안정 |
| **결과 확인 (GET)** | MCP Playwright | 수정/등록 후 GET 재호출하여 브라우저로 시각 검증 |

**절대 하지 말 것:**
- Body(CodeMirror) 에디터에 `browser_type`이나 `browser_fill_form`으로 JSON 입력 시도
- `browser_run_code`에서 `.cm-content`를 `pressSequentially`로 교체 시도

## MCP 도구 사용 규칙

| 도구 | 용도 | 주의사항 |
|------|------|---------|
| `browser_navigate` | API 문서 페이지 이동 | URL hash로 특정 API 섹션 직접 이동 가능 |
| `browser_snapshot` | 현재 상태 + ref 확인 | **조작 전 필수**. 결과가 너무 크면 파일로 저장 후 grep |
| `browser_click` | 요소 클릭 | ref 필수. `Ref not found` 에러 시 snapshot 재촬영 |
| `browser_type` | 텍스트 입력 | Header Key/Value, Query Param Value에만 사용. **Body에 사용 금지** |
| `browser_take_screenshot` | 시각 캡처 | 결과 검증용 |
| `browser_run_code` | JS 일괄 실행 | 여러 조작을 한번에 묶어 속도 개선 |
| `browser_close` | 브라우저 닫기 | 테스트 종료 시 |

## 실행 흐름

### Step 0: 환경 확인

config.yaml의 `server.modules`에서 해당 모듈의 포트와 상태를 확인.
서버 미기동 시 `/server {모듈} up` 실행.

### Step 1: spec 분석

병렬로 수집:
- `docs/specs/` 도메인 분석 문서 (비즈니스 컨텍스트)
- API 문서 (openapi3.yaml 등)
- Controller, DTO, ErrorCode (구현 세부사항)

### Step 2: TC 설계 → 사용자 확인

spec에 정의된 API별로 정상/엣지/에러 케이스 TC를 설계하고 사용자 확인 후 실행.

### Step 3: 테스트 실행

#### GET 테스트 — API 문서 UI (MCP Playwright)

1. API 문서 페이지로 이동 (`browser_navigate`)
2. 해당 API 그룹/엔드포인트 찾기 (`browser_snapshot` → `browser_click`)
3. Test/Try it 패널 열기
4. Headers, Query Parameters 입력 (`browser_type`)
5. Send/Execute 클릭 → 응답 확인 (`browser_take_screenshot`)

#### POST/PUT/PATCH 테스트 — curl (Bash)

Body가 필요한 API는 curl로 직접 호출. 여러 TC를 하나의 Bash 블록에 묶어 실행.

#### 결과 확인 — API 문서 UI에서 GET 재호출

POST/PUT 후 변경 결과를 브라우저에서 GET으로 확인.

### Step 4: 결과 요약

```
| # | 테스트명 | 방식 | 기대 | 실제 | 결과 |
|---|---------|------|------|------|------|
| TC-1 | GET 조회 | Playwright | 200 | 200 | PASS |
| TC-2 | POST 등록 | curl | 200 | 200 | PASS |
```

### Step 5: 정리

`browser_close`로 브라우저 닫기.

## 속도 최적화

1. **`browser_type`에 `slowly: true` 사용 금지** — 기본 fill이 충분히 동작
2. **`browser_run_code`로 여러 조작 묶기** — Close → Open → Send 등
3. **snapshot을 파일로 저장** — 결과가 클 때 `filename` 파라미터 사용 후 grep으로 ref 검색
4. **POST/PUT/PATCH는 curl로 일괄 실행** — 여러 TC를 하나의 Bash 블록에

## 에러 핸들링

| 증상 | 원인 | 해결 |
|------|------|------|
| `Ref not found` | 페이지 상태 변경으로 ref 갱신됨 | `browser_snapshot` 재촬영 후 새 ref 사용 |
| snapshot 결과 초과 | 전체 페이지가 너무 큼 | `filename` 파라미터로 파일 저장 → grep |
| Test/Try it 버튼 안 보임 | 가상 스크롤로 DOM 미렌더링 | 사이드바에서 해당 그룹 클릭하여 렌더링 트리거 |
| 기존 다이얼로그가 클릭 가로막음 | 이전 패널이 열린 상태 | Close 먼저 클릭 |
| POST/PUT Body 입력 안 됨 | CodeMirror → fill/type 불가 | **curl로 대체** (하이브리드) |
