# 워크플로 산출물 디렉토리 가이드

`/task` 및 `/jira-task` 워크플로에서 생성되는 산출물 디렉토리 안내.
`setup.sh`가 아래 6개 디렉토리를 자동 생성한다.

## 디렉토리 구조

```
docs/
├── specs/        ← 기획 분석 산출물
├── plan/         ← 기획 문서
├── design/       ← 설계 문서
├── review/       ← 리뷰 리포트
├── test/         ← 테스트 리포트
└── reports/      ← 상태 리포트
```

## 산출물 상세

### docs/specs/ — 기획 분석

| 항목 | 내용 |
|------|------|
| 생성 | `/task analyze` 또는 `/analyze-spec` |
| 네이밍 | `{feature-name}.md` |
| 참조 phase | plan, design, e2e |
| 포함 내용 | 기획서/스토리보드를 구조화한 마크다운 |

### docs/plan/ — 기획 문서

| 항목 | 내용 |
|------|------|
| 생성 | `/task plan {taskId}` |
| 네이밍 | `{taskId}-plan.md` |
| 참조 phase | design, done |
| 포함 내용 | Background, Scope, Acceptance Criteria, Impact Analysis, Existing Patterns, Task Breakdown, Risks |

### docs/design/ — 설계 문서

| 항목 | 내용 |
|------|------|
| 생성 | `/task design {taskId}` |
| 네이밍 | `{taskId}-design.md` |
| 참조 phase | impl, review, done |
| 포함 내용 | Architecture, Reference Patterns, Sequence Diagram, Implementation Plan, Error Handling, Security Checklist, Test Plan |

### docs/review/ — 리뷰 리포트

| 항목 | 내용 |
|------|------|
| 생성 | `/task review {taskId}` |
| 네이밍 | `{taskId}-review.md` |
| 참조 phase | done |
| 포함 내용 | Gap Analysis (매칭률), Code Quality, Architecture, Test Coverage |
| 판정 | Approve (Critical 0, Warning ≤2, 매칭률 90%+) / Request Changes / Needs Discussion |

### docs/test/ — 테스트 리포트

| 항목 | 내용 |
|------|------|
| 생성 | `/jira-task test {TASK-ID}` |
| 네이밍 | `{taskId}.test-report.md` |
| 포함 내용 | Summary (Total/Passed/Failed), Unit Tests, E2E Tests, Failed Details |

### docs/reports/ — 상태 리포트

| 항목 | 내용 |
|------|------|
| 생성 | `/jira-task report` |
| 네이밍 | `status-{YYYY-MM-DD}.report.md` |
| 포함 내용 | 이슈 상태별 분류, 담당자별 요약, 블로커/의존성 목록 |
