# Claude Skills Kit

AI 기반 개발 자동화 스킬 모음. 기획 분석 → 구현 → 빌드 → 테스트 → 리뷰까지 전체 개발 라이프사이클을 커버한다.

## 전체 라이프사이클

```
# 범용 워크플로 (이슈 트래커 없이 독립 동작)
/task analyze         → 기획서를 spec MD로 변환
/task plan            → 기획 문서 생성 (plan-analyst 에이전트)
/task design          → 설계 문서 생성 (design-architect 에이전트)
/task impl            → 코드 구현
/task review          → 코드 리뷰 (3개 에이전트 병렬)
/task done            → 빌드 확인 + 완료
/task e2e             → E2E 테스트

# Jira 연동 워크플로 (동일 phase + Jira 상태 전환/코멘트)
/jira-task start      → 태스크 시작 (브랜치 생성, Jira 전환)
/jira-task plan~done  → 위와 동일 + Jira 연동

# 독립 스킬 (워크플로 안에서도 밖에서도 사용 가능)
/analyze-spec         → 기획서 분석 (PPT, Google, Confluence)
/server {module} up   → 서버 기동/중지/빌드
/db up                → 인프라 기동
/e2e-test             → E2E API 테스트
```

## 구조

```
claude-skills-kit/
├── config.yaml                       # 프로젝트별 설정 (서버, 인프라, 경로)
├── setup.sh                          # 자동 설치 스크립트
│
├── agents/                           # 공용 에이전트 (역할만 정의, 기준은 프로젝트에서)
│   ├── plan-analyst.md               #   기획 분석 (opus)
│   ├── design-architect.md           #   설계 (opus)
│   ├── code-reviewer.md              #   코딩 표준 리뷰 (opus)
│   ├── architecture-reviewer.md      #   아키텍처 검증 (opus)
│   └── test-reviewer.md              #   테스트 컨벤션 (sonnet)
│
├── skills/
│   ├── task/                         # 범용 태스크 워크플로 (이슈 트래커 불필요)
│   │   ├── SKILL.md                  #   라우터
│   │   ├── task-analyze/             #   → /analyze-spec 호출
│   │   ├── task-plan/                #   → plan-analyst 에이전트
│   │   ├── task-design/              #   → design-architect 에이전트
│   │   ├── task-impl/                #   → 직접 구현
│   │   ├── task-review/              #   → 3개 리뷰 에이전트 병렬
│   │   ├── task-done/                #   → 빌드 확인 + 완료
│   │   └── task-e2e/                 #   → /e2e-test 호출
│   ├── analyze-spec/                 # 독립: 기획서 분석
│   ├── server/                       # 독립: 서버 관리
│   ├── db/                           # 독립: 인프라 관리
│   ├── e2e-test/                     # 독립: E2E 테스트
│   └── workflows/
│       └── jira-task/                # Jira 연동 워크플로 (13개 서브 스킬)
│
├── commands/
│   └── cleanup-worktree.md           # worktree 정리 커맨드
├── hooks/
│   └── guard-merge.sh                # 머지 보호 훅
│
├── templates/
│   ├── CLAUDE.md.template            # 프로젝트 규칙 (~50줄, 포인터만)
│   ├── task-conventions.md.template  # phase별 컨벤션 (CLAUDE.md에서 분리)
│   ├── settings.json.template        # Claude Code 설정
│   └── docs/                         # 산출물 디렉토리 README 템플릿
│       ├── specs/README.md           #   /task analyze 산출물
│       ├── plan/README.md            #   /task plan 산출물
│       ├── design/README.md          #   /task design 산출물
│       ├── review/README.md          #   /task review 산출물
│       ├── test/README.md            #   테스트 리포트
│       └── reports/README.md         #   현황 리포트
│
└── docs/
    ├── DESIGN-task-workflow.md       # task 워크플로 설계 문서
    └── GUIDE-task-workflow.md        # task 워크플로 사용 가이드
```

## 에이전트 구조

```
에이전트 = 역할 (무엇을 하는가)  ← 공용 (agents/)
         + 기준 (어떻게 판단하는가)  ← 프로젝트별 (아래 참조)
```

같은 `code-reviewer.md`가:
- Spring Boot 프로젝트에서는 "jOOQ 사용, JPA 금지" 검사
- React 프로젝트에서는 "hooks 규칙, 컴포넌트 구조" 검사

### 에이전트가 프로젝트 기준을 읽는 순서

```
1. CLAUDE.md                      ← 프로젝트 개요, 핵심 패턴 (~50줄)
2. .claude/task-conventions.md    ← phase별 컨벤션 (~50줄)
3. docs/standards/*.md            ← 상세 규정 (있으면)
4. 기존 코드 Glob/Grep            ← 참조 패턴 탐색
5. (모두 없으면) 일반 원칙 + 사용자 질문
```

## 컨벤션 분리 원칙

CLAUDE.md를 200줄 이내로 유지하기 위해 3계층으로 분리:

| 파일 | 역할 | 줄 수 |
|------|------|------|
| `CLAUDE.md` | 프로젝트 개요 + 포인터 | ~50줄 |
| `.claude/task-conventions.md` | phase별 컨벤션 (plan/design/impl/test/review) | ~50줄 |
| `docs/standards/*.md` | 상세 규정 (코딩 표준, API 규격 등) | 필요한 만큼 |

**신규 프로젝트**: CLAUDE.md만 ~30줄 작성하면 동작. 컨벤션은 나중에 추가.

## 스킬 목록

### 독립 스킬

| 스킬 | 설명 |
|------|------|
| `/analyze-spec` | 기획서/SB → 구조화 MD 변환 (PPT, Google Slides/Docs/Sheets, Confluence) |
| `/db` | 로컬 인프라 관리 (DB, 캐시 등) |
| `/server` | 서비스 기동/중지/빌드/상태 관리 |
| `/e2e-test` | spec + 코드 기반 E2E API 테스트 (curl + Playwright) |
| `/cleanup-worktree` | git worktree 정리 |

### 워크플로 (택 1)

| 워크플로 | 상태 | 설명 |
|----------|------|------|
| `task` | **사용 가능** | 범용. 이슈 트래커 없이 독립 동작 (8개 phase) |
| `jira-task` | **사용 가능** | Jira 연동 (13개 서브 스킬) |
| `github-task` | 미구현 | GitHub Issues/Projects 기반 |
| `linear-task` | 미구현 | Linear 기반 |

### task 서브 스킬

| 서브 스킬 | 에이전트 | model | 설명 |
|-----------|---------|-------|------|
| `analyze` | — | opus | /analyze-spec 호출 → context 기록 |
| `plan` | plan-analyst | opus | 요구사항 분석, 기획 문서 생성 |
| `design` | design-architect | opus | 패턴 탐색, 설계 문서 생성 |
| `impl` | — | sonnet | 설계 기반 직접 구현 |
| `review` | code/architecture/test-reviewer | opus | 3개 에이전트 병렬 리뷰 |
| `done` | — | sonnet | 빌드 확인 + 변경 요약 |
| `e2e` | — | sonnet | /e2e-test 호출 |

### jira-task 서브 스킬

| 서브 스킬 | 설명 |
|-----------|------|
| `init` | 스프린트 태스크 초기화 + worktree 세팅 |
| `start` | 태스크 시작 (브랜치 생성, Jira 상태 전환) |
| `plan` | 기획 문서 생성 + Jira 코멘트 |
| `design` | 설계 문서 생성 + Jira 코멘트 |
| `impl` | 코드 구현 + Jira 코멘트 |
| `test` | 테스트 실행 + 결과 보고 |
| `review` | 코드 리뷰 + gap 분석 |
| `merge` | 로컬 브랜치 병합 |
| `pr` | PR 생성 + 이슈 링크 |
| `done` | 태스크 완료 + Jira 전환 |
| `auto` | 전체 워크플로우 자동 실행 |
| `report` | 할당 이슈 현황 리포트 |
| `setup` | MCP 초기 설정 위저드 |

## 설치

### 자동 설치 (권장)

```bash
# 프로젝트 루트에서 실행
bash /path/to/claude-skills-kit/setup.sh
```

setup.sh가 하는 일:
1. 공통 스킬 복사 (analyze-spec, db, server, e2e-test)
2. 워크플로우 선택 (task 또는 jira-task) + 에이전트 복사
3. config.yaml 생성 (프로젝트 루트 자동 설정)
4. 산출물 디렉토리 생성 (docs/specs, plan, design, review, test, reports + README)
5. CLAUDE.md + task-conventions.md 템플릿 생성

### 수동 설치

```bash
# 1. 공통 스킬
cp -r skills/analyze-spec skills/db skills/server skills/e2e-test .claude/skills/

# 2. 워크플로우 (택 1)
cp -r skills/task .claude/skills/           # 범용
# cp -r skills/workflows/jira-task .claude/skills/  # Jira 연동

# 3. 에이전트
mkdir -p .claude/agents
cp agents/*.md .claude/agents/

# 4. config.yaml
cp config.yaml .claude/skills/config.yaml

# 5. 컨벤션 템플릿
cp templates/CLAUDE.md.template CLAUDE.md
cp templates/task-conventions.md.template .claude/task-conventions.md
```

## 설정

`config.yaml`을 프로젝트에 맞게 수정.

### 필수 설정
- `project.root` — 프로젝트 루트 절대경로
- `workflow.type` — `task` 또는 `jira-task`
- `server.modules` — 서비스 모듈 정의

### 선택 설정
- `workflow.models` — phase별 모델 지정 (task 워크플로)
- `workflow.review.agents` — 리뷰 에이전트 목록 (커스텀 추가 가능)
- `jira.*` — Jira 연동 (workflow.type = jira-task)
- `infra.*` — 인프라 관리 (type: none이면 비활성)

## 사전 요구사항

| 항목 | 필요한 스킬 | 설치 |
|------|------------|------|
| python-pptx | analyze-spec | `pip install python-pptx` |
| LibreOffice | analyze-spec | `brew install --cask libreoffice` |
| Docker | db | Docker Desktop |
| Playwright MCP | e2e-test (pw) | `.mcp.json`에 `@playwright/mcp` 등록 |
| Jira MCP | jira-task | `claude mcp add atlassian ...` |
| Google MCP | analyze-spec | `.mcp.json`에 등록 |

## 상세 문서

- [Task 워크플로 사용 가이드](docs/GUIDE-task-workflow.md) — 컨벤션 저장 경로, 사용법, 신규 프로젝트 대응
- [Task 워크플로 설계](docs/DESIGN-task-workflow.md) — 아키텍처, 상세 스펙
