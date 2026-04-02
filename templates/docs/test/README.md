# docs/test/

`/jira-task test` 또는 `/task` 워크플로에서 테스트 실행 후 생성되는 테스트 리포트.

## 생성 방법

```bash
/jira-task test {TASK-ID}
```

## 파일 네이밍

```
{taskId}.test-report.md
```

예시: `PROJ-123.test-report.md`, `option-group-crud.test-report.md`

## 문서에 포함되는 내용

- Summary (Total / Passed / Failed / Skipped / Duration)
- Unit Tests 결과
- E2E Tests 결과 (Playwright 등)
- Failed Tests Detail (에러 메시지, 스택 트레이스)
- Screenshots (Playwright 실패 스크린샷 경로)
