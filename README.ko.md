# Claude Harness Kit

AI 에이전트 팀 하네스. 기획 분석 → 구현 → 빌드 → 테스트 → 리뷰까지 전체 개발 라이프사이클을 8개 스페셜리스트 에이전트 팀이 커버한다.

[![English](https://img.shields.io/badge/lang-English-blue)](README.md)

## 전체 라이프사이클

```
# 범용 워크플로 (이슈 트래커 없이 독립 동작)
/task analyze         → 기획서를 spec MD로 변환
/task plan            → 기획 문서 생성 (plan-analyst 에이전트)
/task design          → 설계 문서 생성 (design-architect 에이전트)
/task impl            → 코드 구현 (developer 에이전트)
/task review          → 코드 리뷰 (3개 에이전트 병렬)
/task done            → 빌드 확인 + 완료
/task e2e             → E2E 테스트

# Jira 연동 워크플로 (동일 phase + Jira 상태 전환/코멘트)
/jira-task start      → 태스크 시작 (브랜치 생성, Jira 전환)
/jira-task plan~done  → 위와 동일 + Jira 연동

# 독립 스킬 (워크플로 안에서도 밖에서도 사용 가능)
/analyze-spec         → 기획서 분석 (PPT, Google, Confluence)
/propagate-convention → ADR/규칙 → 에이전트/스킬 전파
/server {module} up   → 서버 기동/중지/빌드
/db up                → 인프라 기동
/e2e-test             → E2E API 테스트
```

## 구조

```
claude-harness-kit/
├── config.yaml                       # 프로젝트별 설정 (서버, 인프라, 경로)
├── setup.sh                          # 자동 설치 스크립트
│
├── agents/                           # 스페셜리스트 에이전트 팀 (8개)
│   ├── pm.md                         #   PM / 오케스트레이터 (opus)
│   ├── plan-analyst.md               #   기획 분석 (opus)
│   ├── design-architect.md           #   설계 (opus)
│   ├── developer.md                  #   구현 전문가 (sonnet)
│   ├── code-reviewer.md              #   코딩 표준 리뷰 (opus)
│   ├── architecture-reviewer.md      #   아키텍처 검증 (opus)
│   ├── test-reviewer.md              #   테스트 컨벤션 (sonnet)
│   └── convention-keeper.md          #   규칙 전파 (sonnet)
│
├── skills/
│   ├── task/                         # 범용 태스크 워크플로 (7개 서브 스킬)
│   ├── analyze-spec/                 # 독립: 기획서 분석
│   ├── server/                       # 독립: 서버 관리
│   ├── db/                           # 독립: 인프라 관리
│   ├── e2e-test/                     # 독립: E2E 테스트
│   ├── propagate-convention/         # 독립: ADR/규칙 전파
│   ├── examples/                     # 기술 특화 예시 스킬 (7개)
│   └── workflows/
│       └── jira-task/                # Jira 연동 워크플로 (13개 서브 스킬)
│
├── commands/
│   └── cleanup-worktree.md           # worktree 정리 커맨드
├── hooks/
│   ├── guard-merge.sh                # 머지 보호 훅
│   ├── session-logger.sh             # 세션 감사 로거 (3개 이벤트)
│   └── notify.sh                     # 데스크톱 알림
│
├── templates/
│   ├── CLAUDE.md.template            # 프로젝트 규칙 (~50줄, 포인터만)
│   ├── task-conventions.md.template  # phase별 컨벤션
│   ├── settings.json.template        # Claude Code 설정 (hooks 5개 + deny list)
│   ├── .mcp.json.template            # MCP 서버 설정 (Jira, PostgreSQL, Playwright)
│   └── docs/
│       ├── adr/                      # ADR 템플릿 + 가이드
│       ├── standards/                # 코딩/API/테스팅 표준 템플릿
│       └── artifacts/                # 산출물 디렉토리 가이드
│
└── docs/
    ├── GUIDE-task-workflow.md        # task 워크플로 사용 가이드
    ├── DESIGN-task-workflow.md       # task 워크플로 설계 문서
    └── token-optimization-guide.md   # 토큰 최적화 가이드
```

## 에이전트 팀

```
PM (오케스트레이터)
├── plan-analyst     → 분석/계획
├── design-architect → 설계
├── developer        → 구현 (스킬 참조하여 세분화된 체크리스트 활용)
├── code-reviewer    ─┐
├── architecture-reviewer ─ 병렬 리뷰
├── test-reviewer    ─┘
└── convention-keeper → 규칙 전파 (필요 시)
```

에이전트가 프로젝트 기준을 읽는 순서:

```
1. CLAUDE.md                      ← 프로젝트 개요, 핵심 패턴 (~50줄)
2. .claude/task-conventions.md    ← phase별 컨벤션 (~50줄)
3. docs/standards/*.md            ← 상세 표준 규격 (How)
4. docs/adr/*.md                  ← 의사결정 기록 (Why)
5. 기존 코드 Glob/Grep            ← 참조 패턴 탐색
6. (모두 없으면) 일반 원칙 + 사용자 질문
```

## 컨벤션 계층

| 파일 | 역할 | 변경 빈도 |
|------|------|----------|
| `CLAUDE.md` | 프로젝트 개요 + 핵심 패턴 (~50줄) | 드물게 |
| `.claude/task-conventions.md` | phase별 컨벤션 | 드물게 |
| `docs/standards/*.md` | 상세 표준 규격 (How) | 거의 불변 |
| `docs/adr/*.md` | 의사결정 기록 (Why) | 계속 추가 |

**신규 프로젝트**: CLAUDE.md만 ~30줄 작성하면 동작. 컨벤션은 나중에 추가.

## 독립 스킬

| 스킬 | 설명 |
|------|------|
| `/analyze-spec` | 기획서 → 구조화 MD 변환 (PPT, Google Slides/Docs/Sheets, Confluence) |
| `/propagate-convention` | 새 ADR/규칙 → 에이전트/스킬 파일에 체크리스트 전파 |
| `/db` | 로컬 인프라 관리 (DB, 캐시 등) |
| `/server` | 서비스 기동/중지/빌드/상태 관리 |
| `/e2e-test` | spec + 코드 기반 E2E API 테스트 (curl + Playwright) |
| `/cleanup-worktree` | git worktree 정리 |

## 예시 스킬 (기술 특화)

`skills/examples/`에 7개 예시. `[CUSTOMIZE]` 마커로 프로젝트에 맞게 수정 가능:

| 예시 | 설명 | 기술 스택 |
|------|------|----------|
| `domain-model` | DDD 도메인 모델 설계 | Spring Boot + jOOQ |
| `dto-design` | DTO 계층 분리 설계 | Spring Boot |
| `port-adapter` | Hexagonal Architecture | Spring Boot + jOOQ |
| `query-audit` | DB 쿼리 품질 감사 | jOOQ |
| `type-split` | wide table 분리 + sealed interface | Java 17+ |
| `test-convention` | 테스트 컨벤션 가이드 | JUnit 5 |
| `domain-refactor` | 도메인 코드 리팩토링 | DDD + Clean Arch |

## Hooks

| Hook | 이벤트 | 설명 |
|------|--------|------|
| `session-logger.sh` | SessionStart, UserPromptSubmit, PostToolUse | 세션 감사 — 세션 시작, 프롬프트, git 명령을 `.worktree.log`에 기록 |
| `guard-merge.sh` | PreToolUse(Bash) | 머지 보호 — 현재 브랜치 ≠ baseBranch일 때 머지 차단 |
| `notify.sh` | Notification | 작업 완료 데스크톱 알림 (macOS/Linux/WSL) |

## 추천 플러그인

### claude-md-management (Anthropic 공식)

CLAUDE.md 관리 플러그인. 세션 학습 내용 반영 + 품질 감사.

```bash
claude plugin install claude-md-management@claude-plugins-official
```

| 커맨드/스킬 | 용도 | 시점 |
|-----------|------|------|
| `/revise-claude-md` | 세션에서 배운 내용을 CLAUDE.md에 반영 | 세션 종료 전 |
| `claude-md-improver` | CLAUDE.md 품질 감사 (100점 만점) | 정기 유지보수 |

## 설치

```bash
# 원라이너 — 프로젝트 루트에서 실행
bash <(curl -sL https://raw.githubusercontent.com/AnSungWook/ClaudeHarnessKit/main/setup.sh)
```

setup.sh가 하는 일:
1. 공통 스킬 복사 (analyze-spec, db, server, e2e-test, propagate-convention)
2. 워크플로우 선택 (task 또는 jira-task) + 8개 에이전트 복사
3. Hooks 복사 (session-logger, guard-merge, notify)
4. config.yaml, settings.json, .mcp.json 설정 파일 생성
5. 컨벤션 디렉토리 생성 (docs/adr/, docs/standards/ + 템플릿)
6. 산출물 디렉토리 생성 (docs/specs, plan, design, review, test, reports)
7. CLAUDE.md + task-conventions.md 템플릿 생성

## 상세 문서

- [Task 워크플로 사용 가이드](docs/GUIDE-task-workflow.md)
- [Task 워크플로 설계](docs/DESIGN-task-workflow.md)
- [토큰 최적화 가이드](docs/token-optimization-guide.md) — 하네스 기반 토큰 절약 전략

## 라이선스

MIT
