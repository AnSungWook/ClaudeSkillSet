---
name: task-done
description: 빌드 확인, 변경 요약을 수행하고 태스크를 완료 처리한다.
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

# task-done: Complete Task

## Language Rule

모든 출력을 한국어로 작성한다.
예외: 코드, 변수명, 파일명, 명령어는 영어를 유지한다.

## Workflow

### Step 1: Load Context

1. `.task-context.json` 읽기
2. `$ARGUMENTS`에서 taskId가 주어지면 우선 사용

### Step 2: Build Verification

config.yaml의 `server` 섹션이 있고 대상 모듈이 식별되면 `/server {module} build` 호출.
없으면 기본 빌드 명령 시도:

```bash
# Gradle
./gradlew build 2>&1 | tail -20

# npm
npm run build 2>&1 | tail -20
```

빌드 실패 시 에러를 보고하고, 사용자에게 수정 후 재실행할지 문의.

### Step 3: Summarize Changes

```bash
git log --oneline {baseBranch}..HEAD
git diff --stat {baseBranch}..HEAD
```

PDCA 문서들을 읽어 요약에 반영:
1. `docs/plan/{taskId}-plan.md` — 기획 요약
2. `docs/design/{taskId}-design.md` — 설계 요약
3. `docs/review/{taskId}-review.md` — 리뷰 결과

### Step 4: Generate Completion Report

```markdown
# Task Complete: {taskId}

**Date**: {date}
**Branch**: {branch}
**Commits**: {count}
**Files Changed**: {count} (+{added} -{deleted})

## Summary
- **Plan**: {기획 요약 1줄}
- **Design**: {설계 요약 1줄}
- **Review**: {리뷰 결과}
- **Build**: {통과/실패}

## Key Changes
{구현 변경사항 요약}

## Artifacts
- spec: {경로}
- plan: {경로}
- design: {경로}
- review: {경로}
```

### Step 5: Update .task-context.json

```json
{
  "completedSteps": [..., "done"],
  "status": "Done",
  "completedAt": "{ISO 8601}"
}
```

### Step 6: Completion Summary

```
---
✅ **Task Done** — {taskId}

- 빌드: {통과/실패}
- 커밋: {N}개
- 변경 파일: {N}개

**Progress**: analyze → plan → design → impl → review → **done ✓** → e2e

**Next steps**:
  /task e2e {taskId}  — E2E 테스트 (선택)
  git push             — 원격에 푸시
  PR 생성              — 코드 리뷰 요청
---
```
