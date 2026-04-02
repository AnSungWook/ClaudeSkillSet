# docs/plan/

`/task plan` 산출물.
요구사항을 분석하여 구현 계획을 수립한 기획 문서.

## 생성 방법

```bash
/task plan {taskId}
```

## 파일 네이밍

```
{taskId}-plan.md
```

예시: `option-group-crud-plan.md`, `user-auth-plan.md`

## 문서에 포함되는 내용

- Background (배경/요구사항)
- Scope (범위: In/Out)
- Acceptance Criteria (성공 기준)
- Impact Analysis (영향 범위, 변경 대상 파일/모듈)
- Existing Patterns (참조할 기존 코드)
- Task Breakdown (구현 단계 분해)
- Risks & Edge Cases

## 이 문서를 읽는 phase

- `/task design` — 설계의 입력
- `/task done` — 완료 요약 시 기획 내용 추출
