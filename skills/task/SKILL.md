---
name: task
description: 범용 태스크 워크플로 라우터. Jira/GitHub 없이 .task-context.json 기반으로 analyze|plan|design|impl|review|done|e2e 단계를 관리한다.
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Skill, AskUserQuestion
---

# Task Workflow Router

외부 이슈 트래커(Jira, GitHub) 의존 없이 동작하는 범용 태스크 워크플로.
`.task-context.json`으로 단계 간 상태를 연결하고, 프로젝트 기준은 `CLAUDE.md`에서 읽는다.

## Usage

```
/task                          # 현재 상태 확인
/task analyze {url|path}       # 기획서 분석 → spec MD 생성
/task plan {taskId}            # 기획 문서 생성
/task design {taskId}          # 설계 문서 생성
/task impl {taskId}            # 구현
/task review {taskId}          # 코드 리뷰 (에이전트 3개 병렬)
/task done {taskId}            # 완료 + 빌드 확인
/task e2e {taskId}             # E2E 테스트
```

## Arguments Routing

`$ARGUMENTS`를 파싱하여 첫 번째 단어로 라우팅:

| 인자 | 라우팅 대상 | model |
|------|-----------|-------|
| (없음) | 현재 상태 표시 (아래 Status 섹션) | — |
| `analyze` | `task:task-analyze` 스킬 | opus |
| `plan` | `task:task-plan` 스킬 | opus |
| `design` | `task:task-design` 스킬 | opus |
| `impl` | `task:task-impl` 스킬 | sonnet |
| `review` | `task:task-review` 스킬 | opus |
| `done` | `task:task-done` 스킬 | sonnet |
| `e2e` | `task:task-e2e` 스킬 | sonnet |

첫 번째 단어를 제거한 나머지를 하위 스킬의 `args`로 전달한다.

## Status (인자 없이 호출 시)

`.task-context.json`이 있으면 읽어서 현재 상태를 표시:

```
📋 Task: {taskId}
📂 Branch: {branch}
📍 Status: {status}

Progress: analyze → plan → design → impl → review → done → e2e
          {completedSteps에 있으면 ✓, 없으면 ○}

Artifacts:
  spec:   {경로 또는 "—"}
  plan:   {경로 또는 "—"}
  design: {경로 또는 "—"}
  review: {경로 또는 "—"}

Next: /task {다음 미완료 단계} {taskId}
```

`.task-context.json`이 없으면:

```
📋 활성 태스크가 없습니다.

시작하려면:
  /task analyze {기획서 경로/URL}  — 기획서 분석부터
  /task plan {taskId}             — 기획 문서부터
  /task impl {taskId}             — 바로 구현 시작
```

## .task-context.json 관리 원칙

- 모든 phase 스킬은 시작 시 이 파일을 읽고, 종료 시 업데이트한다
- context가 없으면 각 스킬은 독립 동작한다 (사용자에게 직접 물어봄)
- context가 있으면 이전 단계 산출물을 자동 참조한다

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
  "server": {
    "module": "catalog",
    "port": 8091
  },
  "createdAt": "2026-04-02T10:00:00+09:00"
}
```
