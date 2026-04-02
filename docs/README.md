# docs/

설계 문서와 사용 가이드.

## 파일 목록

| 파일 | 용도 |
|------|------|
| `DESIGN-task-workflow.md` | task 워크플로 설계 문서 (아키텍처, 상세 스펙) |
| `GUIDE-task-workflow.md` | task 워크플로 사용 가이드 (컨벤션 저장 경로, 사용법, 신규 프로젝트 대응) |

## 프로젝트에 생성되는 산출물 디렉토리

task 워크플로가 phase별로 산출물을 저장하는 경로 (대상 프로젝트 안에 생성됨):

```
{project}/docs/
├── specs/     ← /task analyze 산출물 (spec MD)
├── plan/      ← /task plan 산출물 ({taskId}-plan.md)
├── design/    ← /task design 산출물 ({taskId}-design.md)
├── review/    ← /task review 산출물 ({taskId}-review.md)
├── test/      ← /jira-task test 산출물 (test report)
└── reports/   ← /jira-task report 산출물 (status report)
```

경로는 `config.yaml`의 `workflow.artifacts`로 변경 가능.
