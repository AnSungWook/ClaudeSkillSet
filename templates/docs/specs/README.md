# docs/specs/

`/task analyze` 또는 `/analyze-spec` 산출물.
기획서/스토리보드를 분석하여 AI가 참조할 수 있는 구조화된 마크다운으로 변환한 문서.

## 생성 방법

```bash
/task analyze /path/to/spec.pptx          # 로컬 파일
/task analyze https://docs.google.com/... # Google Slides/Docs
/analyze-spec https://...                 # 독립 실행도 가능
```

## 파일 네이밍

```
{feature-name}.md
```

예시: `option-group.md`, `user-auth.md`, `payment-flow.md`

## 이 문서를 읽는 phase

- `/task plan` — 요구사항 분석의 입력
- `/task design` — 설계 시 참조
- `/task e2e` — E2E 테스트 시나리오 도출
