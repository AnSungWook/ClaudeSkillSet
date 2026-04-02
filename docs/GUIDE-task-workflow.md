# Task Workflow 사용 가이드

## 개요

`/task`는 Jira/GitHub 없이 동작하는 범용 태스크 워크플로입니다.
`.task-context.json`으로 단계 간 상태를 연결하고, 프로젝트 기준은 정해진 경로에서 읽어옵니다.

```
/task analyze → plan → design → impl → review → done → e2e
```

---

## 1. 컨벤션 저장 구조

에이전트가 읽는 파일과 역할이 분리되어 있습니다.
**CLAUDE.md는 200줄 이내로 유지하세요.**

### 탐색 순서 (모든 에이전트 공통)

```
1. CLAUDE.md                     ← 프로젝트 개요 + 포인터 (필수, ~80줄)
2. .claude/task-conventions.md   ← phase별 컨벤션 (선택, phase당 ~10줄)
3. docs/standards/*.md           ← 상세 규정 (선택, 필요할 때)
4. 기존 코드 Glob/Grep           ← 참조 패턴 탐색
5. (모두 없으면) 일반 원칙 + 사용자 질문
```

### 파일별 역할

```
my-project/
├── CLAUDE.md                          ← 프로젝트 개요 + 포인터만
│   ├── 기술 스택 (테이블)
│   ├── 핵심 패턴 (5줄)
│   ├── 작업 경계 (3줄)
│   └── 상세 규정 테이블 → 경로 링크
│
├── .claude/
│   ├── task-conventions.md            ← phase별 컨벤션 (분리)
│   │   ├── plan — 기획 시 규칙
│   │   ├── design — 설계 시 규칙
│   │   ├── impl — 구현 시 규칙
│   │   ├── test — 테스트 규칙
│   │   └── review — 리뷰 체크리스트
│   └── skills/
│       ├── config.yaml                ← 서버/인프라/경로 설정
│       └── task/                      ← task 스킬 파일들
│
├── docs/standards/                    ← 상세 규정 (큰 프로젝트용)
│   ├── coding-standards.md
│   ├── api-standards.md
│   └── ...
│
├── .task-context.json                 ← [자동생성] 태스크 상태
└── docs/
    ├── specs/                         ← analyze 산출물
    ├── plan/                          ← plan 산출물
    ├── design/                        ← design 산출물
    └── review/                        ← review 산출물
```

### 에이전트별 참조 맵

| 에이전트 | CLAUDE.md에서 | task-conventions.md에서 | docs/standards/에서 |
|---------|-------------|----------------------|-------------------|
| plan-analyst | 기술 스택, 핵심 패턴 | `plan` 섹션 | architecture-*.md |
| design-architect | 핵심 패턴 | `design` 섹션 | coding/api/db-*.md |
| code-reviewer | 핵심 패턴, 금지 패턴 | `review` 체크리스트 | coding/api/error-*.md |
| architecture-reviewer | 핵심 패턴, 작업 경계 | `review` 체크리스트 | architecture-*.md |
| test-reviewer | 테스트 프레임워크 | `test` 섹션 | testing-strategy.md |

---

## 2. 프로젝트 유형별 설정

### 신규 프로젝트 (코드 없음)

최소 설정으로 시작 가능. 컨벤션은 나중에 추가.

```
CLAUDE.md만 작성 (기술 스택 + 핵심 패턴)
→ 에이전트가 일반 원칙으로 동작
→ 불확실한 부분은 사용자에게 질문
→ 코드가 쌓이면 task-conventions.md 추가
```

**CLAUDE.md 예시 (신규 Next.js 프로젝트, ~30줄):**

```markdown
# My App

## 프로젝트 개요
사용자 대시보드 웹앱. Next.js 15 + TypeScript.

## 기술 스택
| 항목 | 값 |
|------|-----|
| 프레임워크 | Next.js 15 (App Router) |
| 언어 | TypeScript |
| 빌드 | pnpm |
| DB | Prisma + PostgreSQL |
| 테스트 | vitest |

## 핵심 패턴
- App Router 사용 (Pages Router 미사용)
- Server Components 기본, Client Components는 'use client' 명시

## 작업 경계
- node_modules/, .next/ 편집 금지
```

→ 이것만으로 `/task plan` → `/task design` → `/task impl` 동작 가능.

### 기존 프로젝트 (코드 있음, 규정 문서 없음)

```
CLAUDE.md 작성 (기술 스택 + 핵심 패턴 + 작업 경계)
→ 에이전트가 기존 코드를 Glob/Grep으로 탐색하여 패턴 파악
→ 필요하면 task-conventions.md 추가
```

### 기존 프로젝트 (코드 + 규정 문서 있음)

```
CLAUDE.md (~80줄) — 개요 + 포인터
.claude/task-conventions.md (~50줄) — phase별 컨벤션
docs/standards/ — 상세 규정
```

---

## 3. 사용법

### 기본 플로우

```bash
/task analyze /path/to/spec.pptx   # 기획서 분석 → spec MD
/task plan my-feature               # 기획 문서 생성
/task design my-feature             # 설계 문서 생성
/task impl my-feature               # 구현
/task review my-feature             # 코드 리뷰 (3 에이전트 병렬)
/task done my-feature               # 빌드 확인 + 완료
/task e2e my-feature                # E2E 테스트 (선택)
```

### 상태 확인

```bash
/task                               # .task-context.json 기반 현재 상태
```

### 중간부터 시작 가능

모든 단계를 거칠 필요 없습니다. context 없으면 독립 동작합니다.

```bash
/task plan my-feature               # 기획서 없이 바로 plan
/task impl my-feature               # plan/design 없이 바로 구현
/task review my-feature             # 구현 후 리뷰만
```

### taskId 규칙

- kebab-case 권장: `option-group-crud`, `user-auth`
- `/task analyze` 시 spec 파일명에서 자동 추출
- 직접 지정도 가능

---

## 4. .task-context.json

모든 스킬이 시작 시 읽고, 종료 시 업데이트하는 접착제.

```json
{
  "taskId": "option-group-crud",
  "branch": "feature/option-group-crud",
  "baseBranch": "develop",
  "status": "In Progress",
  "completedSteps": ["analyze", "plan"],
  "artifacts": {
    "spec": "docs/specs/option-group.md",
    "plan": "docs/plan/option-group-crud-plan.md",
    "design": null,
    "review": null
  },
  "server": { "module": "catalog", "port": 8091 },
  "createdAt": "2026-04-02T10:00:00+09:00"
}
```

context가 없으면 각 스킬이 독립 동작합니다 (사용자에게 물어봄).

---

## 5. 에이전트

```
에이전트 = 역할 (공용, agents/)
         + 기준 (프로젝트별, CLAUDE.md + task-conventions.md + docs/standards/)
```

| 에이전트 | 역할 | 사용 phase | model |
|---------|------|-----------|-------|
| plan-analyst | 요구사항 분석 | plan | opus |
| design-architect | 패턴 탐색, 설계 | design | opus |
| code-reviewer | 코딩 표준 리뷰 | review | opus |
| architecture-reviewer | 아키텍처 검증 | review | opus |
| test-reviewer | 테스트 컨벤션 | review | sonnet |

커스텀 에이전트: `agents/`에 `.md` 추가 + config.yaml의 `workflow.review.agents`에 등록.

---

## 6. jira-task와의 관계

| 항목 | `/task` | `/jira-task` |
|------|---------|-------------|
| 이슈 트래커 | 없음 | Jira MCP |
| 상태 관리 | `.task-context.json` | `.jira-context.json` + Jira |
| 컨벤션 참조 | 동일 경로 | 동일 경로 |
| 에이전트 | 공유 | 공유 |

---

## 7. 트러블슈팅

**에이전트가 컨벤션을 안 읽음** → `.claude/task-conventions.md` 경로 확인. worktree면 심링크 필요.

**산출물 경로가 다름** → config.yaml의 `workflow.artifacts` 확인.

**review가 항상 실패** → task-conventions.md의 review 체크리스트가 과도할 수 있음.

**context 꼬임** → `.task-context.json` 삭제하면 초기화. 각 phase가 독립 동작.
