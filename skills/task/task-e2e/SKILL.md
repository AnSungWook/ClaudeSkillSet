---
name: task-e2e
description: E2E 테스트를 실행한다. /e2e-test 스킬을 호출하고 .task-context.json에 기록한다.
user-invocable: false
recommended-model: sonnet
argument-hint: "{taskId}"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Skill
  - AskUserQuestion
---

# task-e2e: E2E Testing

## Language Rule

모든 출력을 한국어로 작성한다.
예외: 코드, 변수명, 파일명, 명령어는 영어를 유지한다.

## Workflow

### Step 1: Load Context

1. `.task-context.json` 읽기
2. `server.module`, `server.port` 확인
3. `artifacts.spec` 확인 — spec이 있으면 e2e-test에 참조 전달

### Step 2: Determine E2E Arguments

context에서 모듈과 spec 정보를 추출하여 `/e2e-test` 호출 인자를 구성:

- `server.module`이 있으면 모듈명으로 사용
- `artifacts.spec`이 있으면 spec명으로 사용
- 둘 다 없으면 사용자에게 물어봄

### Step 3: Call /e2e-test

```
Skill("e2e-test", args: "{module} {spec}")
```

### Step 4: Update .task-context.json

```json
{
  "completedSteps": [..., "e2e"]
}
```

### Step 5: Completion Summary

```
---
✅ **E2E Complete** — {taskId}

- E2E 테스트 실행 완료

**Progress**: analyze → plan → design → impl → review → done → **e2e ✓**

🎉 모든 단계가 완료되었습니다!
---
```
