# docs/design/

`/task design` 산출물.
plan 문서와 코드베이스 분석을 기반으로 작성한 기술 설계 문서.

## 생성 방법

```bash
/task design {taskId}
```

## 파일 네이밍

```
{taskId}-design.md
```

예시: `option-group-crud-design.md`, `user-auth-design.md`

## 문서에 포함되는 내용

- Architecture (컴포넌트/모듈 구조)
- Reference Patterns (따라야 할 기존 코드)
- Sequence Diagram (Mermaid)
- Implementation Plan (파일별 변경 사항 — **코드 없이 설명만**)
- Error Handling (에러 시나리오 + 처리 전략)
- Security Checklist
- Test Plan (테스트 케이스 명세 — **코드 없이 설명만**)

## 이 문서를 읽는 phase

- `/task impl` — 구현의 핵심 입력. Implementation Plan 순서대로 구현
- `/task review` — Gap Analysis (설계-구현 매칭 검증)
- `/task done` — 완료 요약 시 설계 내용 추출
