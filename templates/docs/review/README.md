# docs/review/

`/task review` 산출물.
3개 에이전트(code-reviewer, architecture-reviewer, test-reviewer)의 병렬 리뷰 결과를 통합한 리포트.

## 생성 방법

```bash
/task review {taskId}
```

## 파일 네이밍

```
{taskId}-review.md
```

예시: `option-group-crud-review.md`, `user-auth-review.md`

## 문서에 포함되는 내용

- Summary (Approve / Request Changes / Needs Discussion)
- Gap Analysis (설계-구현 매칭률)
- Code Quality (코딩 표준 위반 — Critical / Warning / Info)
- Architecture (아키텍처 패턴 준수 여부)
- Test Coverage (테스트 컨벤션 + Design Test Plan 충족률)
- Positive Notes

## 판정 기준

- **Approve**: Critical 0개, Warning 2개 이하, 매칭률 90%+
- **Request Changes**: Critical 1개+, 또는 매칭률 80% 미만
- **Needs Discussion**: 그 외
