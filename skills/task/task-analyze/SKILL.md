---
name: task-analyze
description: 기획서를 분석하여 spec MD를 생성하고 .task-context.json에 기록한다. /analyze-spec 스킬을 호출한다.
user-invocable: false
recommended-model: opus
argument-hint: "{url|path}"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Skill
  - AskUserQuestion
---

# task-analyze: Spec Analysis

## Language Rule

모든 출력을 한국어로 작성한다.
예외: 코드, 변수명, 파일명, 명령어는 영어를 유지한다.

## Workflow

### Step 1: Call /analyze-spec

`$ARGUMENTS`를 그대로 `/analyze-spec` 스킬에 전달한다.

```
Skill("analyze-spec", args: "$ARGUMENTS")
```

인자가 없으면 `/analyze-spec`이 대화형으로 파일/URL을 물어본다.

### Step 2: Identify Output

`/analyze-spec`이 생성한 spec MD 파일 경로를 파악한다.
config.yaml의 `spec.output_dir` 또는 `workflow.artifacts.spec` 경로에서 가장 최근 파일을 찾는다.

### Step 3: Initialize/Update .task-context.json

spec 파일명에서 taskId를 추출 (예: `option-group.md` → `option-group`).

`.task-context.json`이 있으면 업데이트, 없으면 새로 생성:

```json
{
  "taskId": "{taskId}",
  "branch": null,
  "baseBranch": null,
  "status": "Analyzing",
  "completedSteps": ["analyze"],
  "artifacts": {
    "spec": "{spec 파일 경로}",
    "plan": null,
    "design": null,
    "review": null
  },
  "server": null,
  "createdAt": "{ISO 8601}"
}
```

### Step 4: Completion Summary

```
---
✅ **Analyze Complete** — {taskId}

- spec 문서: `{spec 경로}`
- `.task-context.json` 생성됨

**Progress**: **analyze ✓** → plan → design → impl → review → done → e2e

**Next**: `/task plan {taskId}` — 기획 문서를 작성합니다
---
```
