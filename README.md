# Claude Skills Kit

AI 기반 개발 자동화 스킬 모음. 기획 분석 → 구현 → 빌드 → 테스트 → 리뷰까지 전체 개발 라이프사이클을 커버한다.

## 전체 라이프사이클

```
/analyze-spec         → 기획서/SB를 spec MD로 변환

/jira-task start      → 태스크 시작 (브랜치 생성)      ← workflow에 따라 달라짐
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

## 구조

```
claude-skills-kit/
├── README.md
├── setup.sh                          # 자동 설치 (워크플로우 선택 포함)
├── config.yaml                       # 프로젝트별 설정
├── commands/
│   └── cleanup-worktree.md           # worktree 정리 커맨드
├── hooks/
│   └── guard-merge.sh                # 머지 보호 훅 (baseBranch 검증)
├── templates/
│   ├── CLAUDE.md.template            # 프로젝트 규칙 템플릿
│   └── settings.json.template        # Claude Code 설정 템플릿 (hooks 포함)
└── skills/
    ├── analyze-spec/                  # 공통: 기획서 분석
    │   └── references/               # 서브커맨드 (check-schema, sync-jira)
    ├── db/                            # 공통: 인프라 관리
    ├── server/                        # 공통: 서버 + 빌드
    ├── e2e-test/                      # 공통: E2E 테스트 (curl + Playwright)
    │   └── pw-mcp.md                 # Playwright MCP 브라우저 테스트
    └── workflows/                     # 구현 워크플로우 (택 1)
        ├── jira-task/                 # Jira 기반 (사용 가능)
        ├── github-task/               # GitHub Issues 기반 (미구현)
        ├── linear-task/               # Linear 기반 (미구현)
        └── standalone/                # PM 도구 없이 (미구현)
```

## 스킬 목록

### 공통 스킬

| 스킬 | 설명 |
|------|------|
| `/analyze-spec` | 기획서/SB → 구조화 MD 변환 (PPT, Google Slides/Docs/Sheets, Confluence) |
| `/db` | 로컬 인프라 관리 (DB, 캐시 등) |
| `/server` | 서비스 기동/중지/빌드/상태 관리 |
| `/e2e-test` | spec + 코드 기반 E2E API 테스트 (curl + Playwright) |
| `/cleanup-worktree` | git worktree 정리 (MCP 설정 제거 + 삭제 명령 클립보드 복사) |

### 구현 워크플로우 (택 1)

`config.yaml`의 `workflow.type`으로 선택. `setup.sh`가 선택한 워크플로우를 `.claude/skills/`에 설치.

| 워크플로우 | 상태 | 설명 |
|-----------|------|------|
| `jira-task` | **사용 가능** | Jira 연동 개발 워크플로우 (13개 서브 스킬) |
| `github-task` | 미구현 | GitHub Issues/Projects 기반 |
| `linear-task` | 미구현 | Linear 기반 |
| `standalone` | 미구현 | PM 도구 없이 로컬 워크플로우 |

### jira-task 서브 스킬

| 서브 스킬 | 설명 |
|-----------|------|
| `init` | 스프린트 태스크 초기화 + worktree 세팅 |
| `start` | 태스크 시작 (브랜치 생성, Jira 상태 전환) |
| `plan` | 기획 문서 생성 |
| `design` | 설계 문서 생성 |
| `impl` | 코드 구현 |
| `test` | 테스트 실행 + 결과 보고 |
| `review` | 코드 리뷰 + gap 분석 |
| `merge` | 로컬 브랜치 병합 |
| `pr` | PR 생성 + 이슈 링크 |
| `done` | 태스크 완료 |
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
2. 커맨드/훅 복사 (cleanup-worktree, guard-merge)
3. 워크플로우 선택 → 해당 워크플로우 스킬 복사
4. config.yaml 생성 (프로젝트 루트 자동 설정)
5. settings.json 템플릿 생성 (hooks 설정 포함)
6. CLAUDE.md 템플릿 생성 (선택)

### 수동 설치

```bash
# 1. 공통 스킬 복사
cp -r skills/analyze-spec skills/db skills/server skills/e2e-test .claude/skills/

# 2. 커맨드/훅 복사
mkdir -p .claude/commands .claude/hooks
cp commands/cleanup-worktree.md .claude/commands/
cp hooks/guard-merge.sh .claude/hooks/
chmod +x .claude/hooks/guard-merge.sh

# 3. 워크플로우 선택하여 복사 (예: jira-task)
cp -r skills/workflows/jira-task .claude/skills/

# 4. config.yaml 복사 후 수정
cp config.yaml .claude/skills/config.yaml

# 5. settings.json 템플릿 복사 후 수정
cp templates/settings.json.template .claude/settings.json

# 6. CLAUDE.md 템플릿 복사 후 수정
cp templates/CLAUDE.md.template CLAUDE.md
```

## CLAUDE.md 템플릿

`templates/CLAUDE.md.template`은 프로젝트의 **AI 행동 규칙** 템플릿이다.

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

워크플로우 스킬들이 실행될 때 이 CLAUDE.md를 자동으로 참조하므로, 여기에 적힌 규칙이 구현/리뷰 품질을 결정한다.

## 설정

`config.yaml`을 프로젝트에 맞게 수정하세요.

### 필수 설정
- `project.root` — 프로젝트 루트 절대경로
- `workflow.type` — 구현 워크플로우 선택
- `server.modules` — 서비스 모듈 정의

### 선택 설정
- `jira.*` — Jira 연동 (workflow.type = jira-task)
- `spec.confluence.*` — Confluence 접근
- `spec.google.enabled` — Google Workspace 접근
- `infra.*` — 인프라 관리 (type: none이면 비활성)

## 사전 요구사항

| 항목 | 필요한 스킬 | 설치 |
|------|------------|------|
| python-pptx | analyze-spec | `pip install python-pptx` |
| LibreOffice | analyze-spec | `brew install --cask libreoffice` |
| Docker | db | Docker Desktop |
| curl + python3 | e2e-test | 기본 내장 |
| Playwright MCP | e2e-test (pw) | `.mcp.json`에 `@playwright/mcp` 등록 |
| Jira MCP | jira-task | `claude mcp add atlassian ...` |
| Google MCP | analyze-spec | `.mcp.json`에 등록 |

## 커스텀

### 스킬 동작 변경
각 스킬의 `SKILL.md` 파일을 직접 수정. config.yaml은 환경 설정, SKILL.md는 로직/동작.

### 스킬 추가
`.claude/skills/{skill-name}/SKILL.md` 파일을 만들면 자동 인식.

### 워크플로우 추가
`skills/workflows/{workflow-name}/` 디렉토리에 스킬 구성 후 config.yaml의 `workflow.type`에 추가.

### 스킬 비활성화
해당 스킬 디렉토리를 삭제하거나 이름 앞에 `_`를 붙이면 됨.
