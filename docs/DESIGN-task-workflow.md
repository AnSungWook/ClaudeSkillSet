# task 워크플로 설계 문서

## 개요

독립 스킬(analyze-spec, e2e-test, server, db)을 `.task-context.json`으로 유기적으로 연결하는 범용 태스크 워크플로.
Jira/GitHub 등 외부 이슈 트래커 의존 없이 동작하며, 프로젝트별 기준은 CLAUDE.md에서 읽어온다.

## 플로우

```
/task analyze  → 기획서 분석 (analyze-spec 호출)    ← opus
/task plan     → 기획 문서                          ← opus
/task design   → 설계 문서                          ← opus
/task impl     → 구현                               ← sonnet
/task review   → 코드 리뷰 (에이전트 병렬)          ← opus
/task done     → 완료 + 빌드 확인                   ← sonnet
/task e2e      → E2E 검증 (e2e-test 호출)           ← sonnet
```

## 아키텍처

```
┌─────────────────────────────────────────────┐
│  /task (라우터)                              │
│  analyze|plan|design|impl|review|done|e2e   │
├─────────────────────────────────────────────┤
│  Phase Skills (각 단계 스킬)                 │
│  task-analyze, task-plan, task-design, ...   │
│  각 phase가 필요한 agent를 spawn             │
├─────────────────────────────────────────────┤
│  Agent Layer (공용 에이전트 풀)              │
│  plan-analyst | design-architect            │
│  code-reviewer | architecture-reviewer      │
│  test-reviewer                              │
├─────────────────────────────────────────────┤
│  Independent Skills (독립 스킬)              │
│  analyze-spec | e2e-test | server | db      │
│  context 있으면 연결, 없으면 독립 동작       │
├─────────────────────────────────────────────┤
│  Infrastructure                             │
│  .task-context.json | hooks | commands      │
└─────────────────────────────────────────────┘
```

## .task-context.json (접착제)

모든 스킬이 시작 시 읽고, 종료 시 업데이트한다.
context가 없으면 독립 동작, 있으면 자동 연결.

```json
{
  "taskId": "option-group-crud",
  "baseBranch": "develop",
  "status": "In Progress",
  "completedSteps": ["analyze", "plan", "design"],
  "artifacts": {
    "spec": "docs/specs/option-group.md",
    "plan": "docs/plan/option-group-plan.md",
    "design": "docs/design/option-group-design.md",
    "review": null
  },
  "server": {
    "module": "catalog",
    "port": 8091
  }
}
```

## 레포 구조

```
claude-skills-kit/
├── config.yaml
├── commands/
│   └── cleanup-worktree.md
├── hooks/
│   └── guard-merge.sh
├── templates/
│   ├── CLAUDE.md.template
│   └── settings.json.template
│
├── agents/
│   ├── plan-analyst.md              # opus — 요구사항/스펙 분석
│   ├── design-architect.md          # opus — 패턴 탐색, 설계 제안
│   ├── code-reviewer.md             # opus — 코딩 표준 리뷰
│   ├── architecture-reviewer.md     # opus — 아키텍처 검증
│   └── test-reviewer.md             # sonnet — 테스트 컨벤션
│
├── skills/
│   ├── analyze-spec/                # 독립: 기획서 분석
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── analyze.md
│   │       ├── check-schema.md
│   │       └── sync-jira.md
│   ├── db/SKILL.md                  # 독립: 인프라 관리
│   ├── server/SKILL.md              # 독립: 서버 + 빌드
│   ├── e2e-test/                    # 독립: E2E 테스트
│   │   ├── SKILL.md
│   │   └── pw-mcp.md
│   │
│   └── task/                        # 코어 워크플로
│       ├── SKILL.md                 # 라우터
│       ├── task-analyze/SKILL.md    # → analyze-spec 호출, context 기록
│       ├── task-plan/SKILL.md       # → plan-analyst agent
│       ├── task-design/SKILL.md     # → design-architect agent
│       ├── task-impl/SKILL.md       # → 직접 구현
│       ├── task-review/SKILL.md     # → 에이전트 3개 병렬 오케스트레이션
│       ├── task-done/SKILL.md       # → 빌드 확인 + 정리
│       └── task-e2e/SKILL.md        # → e2e-test 호출, context 기록
│
└── README.md
```

## Phase별 상세

### /task analyze
- **model**: opus
- **동작**: /analyze-spec 스킬 호출 (인자 그대로 전달)
- **context 기록**: artifacts.spec
- **다음**: /task plan

### /task plan
- **model**: opus
- **agent**: plan-analyst (요구사항 분석, 영향 범위 식별)
- **입력**: context.artifacts.spec 자동 참조
- **출력**: docs/plan/{taskId}-plan.md
- **context 기록**: artifacts.plan, completedSteps += "plan"
- **다음**: /task design

### /task design
- **model**: opus
- **agent**: design-architect (기존 코드 패턴 탐색, 설계 제안)
- **입력**: context.artifacts.spec + plan 자동 참조
- **출력**: docs/design/{taskId}-design.md
- **context 기록**: artifacts.design, completedSteps += "design"
- **다음**: /task impl

### /task impl
- **model**: sonnet
- **agent**: 없음 (직접 구현)
- **입력**: context.artifacts.design 자동 참조
- **동작**: 설계 문서 기반 기계적 구현. CLAUDE.md의 impl 규칙 준수
- **context 기록**: completedSteps += "impl"
- **다음**: /task review

### /task review
- **model**: opus (오케스트레이터)
- **agent**: 병렬 3개
  - code-reviewer: 코딩 표준 위반 (CLAUDE.md + docs/standards/ 참조)
  - architecture-reviewer: 아키텍처 패턴 준수 (CLAUDE.md 참조)
  - test-reviewer: 테스트 컨벤션 (CLAUDE.md 참조)
- **출력**: docs/review/{taskId}-review.md (통합 리포트)
- **context 기록**: artifacts.review, completedSteps += "review"
- **다음**: /task done

### /task done
- **model**: sonnet
- **동작**: 빌드 확인 (/server build 호출 가능), 변경 요약, cleanup 안내
- **context 기록**: completedSteps += "done", status = "Done"
- **다음**: /task e2e

### /task e2e
- **model**: sonnet
- **동작**: /e2e-test 스킬 호출
  - context.server.module/port 자동 주입
  - context.artifacts.spec 자동 참조
- **context 기록**: completedSteps += "e2e"

## Agent 설계 원칙

```
에이전트 = 역할(무엇을 하는가)  ← 공용 (이 레포)
         + 기준(어떻게 판단하는가)  ← 프로젝트별 (CLAUDE.md, docs/standards/)
```

에이전트는 역할만 정의하고, 리뷰/설계 기준은 프로젝트의 CLAUDE.md에서 읽어온다.
같은 code-reviewer.md가:
- Spring Boot 프로젝트에서는 "jOOQ 사용, JPA 금지" 검사
- React 프로젝트에서는 "hooks 규칙, 컴포넌트 구조" 검사

### agent frontmatter 예시

```yaml
---
name: code-reviewer
description: 변경 코드를 프로젝트 코딩 표준 기반으로 리뷰한다. CLAUDE.md에서 기준을 읽는다.
model: opus
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(git diff *)
---

당신은 코드 리뷰어입니다.

## 기준 로드
1. CLAUDE.md를 읽어 코딩 표준, 금지 패턴, 핵심 패턴을 파악한다
2. docs/standards/ 가 있으면 관련 문서를 읽는다
3. 기준이 없으면 일반적인 클린 코드 원칙으로 리뷰한다

## 리뷰 수행
...
```

## config.yaml 확장

```yaml
workflow:
  models:
    analyze: opus
    plan: opus
    design: opus
    impl: sonnet
    review: opus
    done: sonnet
    e2e: sonnet
  review:
    agents:
      - code-reviewer
      - architecture-reviewer
      - test-reviewer
      # 프로젝트별 추가 가능:
      # - jooq-query-auditor
  artifacts:
    spec: "docs/specs"
    plan: "docs/plan"
    design: "docs/design"
    review: "docs/review"
```

## 독립 스킬 연결 패턴

모든 스킬의 공통 패턴:

```
1. .task-context.json 있으면 읽는다
2. 이전 단계 산출물이 있으면 자동 참조한다
3. 내 산출물 경로를 context에 기록한다
4. 다음 추천 스킬을 안내한다
```

context가 없으면 독립 동작 (사용자에게 직접 물어봄).
context가 있으면 자동 연결.

## 워크트리 연동

worktree 관리는 task에 포함하지 않고 독립 유틸리티로 둔다.
- commands/cleanup-worktree.md — 정리
- hooks/guard-merge.sh — 머지 보호
- 워크트리 생성 시 .claude/ + docs/ 심링크 → context가 루트/워크트리 양쪽에서 접근 가능

## Integration Layer (선택)

task-core 위에 Jira/GitHub 어댑터를 얹으면:
- 각 phase 전후에 이슈 상태 전환, 코멘트 게시
- .task-context.json에 integration 필드 추가

```json
{
  "integration": {
    "type": "jira",
    "issueKey": "AFNBPB-798"
  }
}
```

이건 별도 플러그인/워크플로로 구현 (이 설계의 범위 밖).
