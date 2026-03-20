# Claude Skills Kit

AI 기반 개발 자동화 스킬 모음. 기획 분석 → 구현 → 빌드 → 테스트 → 리뷰까지 전체 개발 라이프사이클을 커버한다.

## 전체 라이프사이클

```
/analyze-spec         → 기획서/SB를 spec MD로 변환

/jira-task start      → Jira 태스크 시작 (브랜치 생성)
/jira-task plan       → 기획 문서 생성 (spec MD 참조)
/jira-task design     → 설계 문서 생성
/jira-task impl       → 코드 구현
/jira-task review     → 코드 리뷰
/server {module} build → 빌드 + 단위 테스트 + REST Docs + Swagger

/db up                → 인프라 기동
/server {module} up   → 서버 기동
/e2e-test             → API E2E 테스트

/jira-task pr         → PR 생성
/jira-task done       → 작업 완료
```

## 스킬 목록

| 스킬 | 설명 |
|------|------|
| `/analyze-spec` | 기획서/SB → 구조화 MD 변환 (PPT, Google Slides/Docs/Sheets, Confluence) |
| `/db` | 로컬 인프라 관리 (DB, 캐시 등) |
| `/server` | 서비스 기동/중지/빌드/상태 관리 |
| `/e2e-test` | spec + 코드 기반 curl E2E API 테스트 |
| `/jira-task` | Jira 연동 개발 워크플로우 (13개 서브 스킬) |

### jira-task 서브 스킬

| 서브 스킬 | 설명 |
|-----------|------|
| `init` | 스프린트 태스크 초기화 + worktree 세팅 |
| `start` | 태스크 시작 (브랜치 생성, Jira 상태 전환) |
| `plan` | 기획 문서 생성 |
| `design` | 설계 문서 생성 |
| `impl` | 코드 구현 |
| `test` | 테스트 실행 + 결과 Jira 보고 |
| `review` | 코드 리뷰 + gap 분석 |
| `merge` | 로컬 브랜치 병합 |
| `pr` | PR 생성 + Jira 링크 |
| `done` | 태스크 완료 |
| `auto` | 전체 워크플로우 자동 실행 |
| `report` | 할당 이슈 현황 리포트 |
| `setup` | Jira MCP 초기 설정 위저드 |

## 설치

### 1. 자동 설치 (setup.sh)

```bash
# 프로젝트 루트에서 실행
bash /path/to/claude-skills-kit/setup.sh
```

### 2. 수동 설치

```bash
# 1. skills 디렉토리 복사
cp -r claude-skills-kit/skills/* .claude/skills/

# 2. config.yaml 복사 후 수정
cp claude-skills-kit/config.yaml .claude/skills/config.yaml
# → 프로젝트에 맞게 config.yaml 수정

# 3. (선택) MCP 서버 등록
# Jira: claude mcp add atlassian ...
# Google: .mcp.json에 google-docs, google-drive 추가
```

## CLAUDE.md 템플릿

`templates/CLAUDE.md.template`은 프로젝트의 **AI 행동 규칙** 템플릿이다. setup.sh 실행 시 프로젝트 루트에 `CLAUDE.md`로 복사된다.

### 템플릿 구조

```
CLAUDE.md
├── 코딩 원칙 (Karpathy Guidelines)    ← 범용, 수정 불필요
├── 프로젝트 개요                       ← 프로젝트별 작성
├── 기술 스택                           ← 프로젝트별 작성
├── 디렉토리 맵                         ← 프로젝트별 작성
├── 핵심 패턴                           ← 프로젝트별 작성
├── 작업 경계                           ← 프로젝트별 작성
├── 상세 규정 참조                       ← 프로젝트별 작성
└── jira-task 워크플로우 컨벤션          ← 프로젝트별 작성
    ├── plan 규칙
    ├── design 규칙
    ├── impl 규칙
    ├── test 규칙
    └── review 규칙
```

`{예: ...}` 부분을 프로젝트에 맞게 채우면 된다. jira-task 스킬들이 실행될 때 이 CLAUDE.md를 자동으로 참조하므로, 여기에 적힌 규칙이 구현/리뷰 품질을 결정한다.

## 설정

`config.yaml`을 프로젝트에 맞게 수정하세요.

### 필수 설정
- `project.root` — 프로젝트 루트 절대경로
- `server.modules` — 서비스 모듈 정의 (이름, 포트, 명령어)

### 선택 설정
- `jira.*` — Jira 연동 (enabled: true + project_key)
- `spec.confluence.*` — Confluence 접근
- `spec.google.enabled` — Google Workspace 접근
- `infra.*` — 인프라 관리 (none이면 비활성)

## 사전 요구사항

| 항목 | 필요한 스킬 | 설치 |
|------|------------|------|
| python-pptx | analyze-spec | `pip install python-pptx` |
| LibreOffice | analyze-spec | `brew install --cask libreoffice` |
| Docker | db | Docker Desktop |
| Java + Gradle | server | 프로젝트별 |
| curl + python3 | e2e-test | 기본 내장 |
| Jira MCP | jira-task | `claude mcp add atlassian ...` |
| Google MCP | analyze-spec | `.mcp.json`에 등록 |

## 커스텀

### 스킬 동작 변경
각 스킬의 `SKILL.md` 파일을 직접 수정하세요. config.yaml은 경로/인증 같은 환경 설정만 담당하고, 스킬의 로직/동작은 SKILL.md에 있습니다.

### 스킬 추가
`.claude/skills/{skill-name}/SKILL.md` 파일을 만들면 자동으로 인식됩니다.

### 스킬 비활성화
해당 스킬 디렉토리를 삭제하거나 이름 앞에 `_`를 붙이세요.
