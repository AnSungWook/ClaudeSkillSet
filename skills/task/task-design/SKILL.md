---
name: task-design
description: 기획 문서와 코드베이스 분석을 기반으로 설계 문서를 생성한다. design-architect 에이전트를 활용한다.
user-invocable: false
recommended-model: opus
argument-hint: "{taskId}"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# task-design: Generate Design Document

## Language Rule

모든 출력을 한국어로 작성한다.
예외: 코드, 변수명, 파일명, 명령어는 영어를 유지한다.

## Workflow

### Step 1: Check Prerequisites

1. `.task-context.json` 읽기
2. `docs/plan/{taskId}-plan.md` 존재 확인
   - 있으면 읽어서 컨텍스트에 포함
   - 없으면 `/task plan {taskId}`를 먼저 실행하라고 안내 (사용자가 원하면 계속 진행)
3. spec 문서가 있으면(`artifacts.spec`) 함께 읽기

### Step 2: Run design-architect Agent

`Agent` 도구로 design-architect 에이전트를 실행:

```
Agent({
  description: "design-architect: {taskId} 설계",
  prompt: "다음 태스크의 기술 설계를 수행하세요.

## Task
- taskId: {taskId}

## Plan Document
{plan 문서 내용}

## Spec (있는 경우)
{spec 문서 내용}

## Instructions
1. CLAUDE.md를 읽어 프로젝트 아키텍처, 핵심 패턴을 파악하세요
2. .claude/task-conventions.md가 있으면 design 섹션을 읽으세요
3. docs/standards/가 있으면 관련 문서를 읽으세요
4. design-architect 에이전트 역할에 따라 설계를 수행하세요
4. 기존 코드 패턴을 반드시 탐색하고 참조 패턴으로 명시하세요
5. 코드를 작성하지 마세요 — 파일명과 변경 설명만 기술하세요
6. 결과를 마크다운 형식으로 반환하세요

모든 출력은 한국어로 작성하세요."
})
```

### Step 3: Save Design Document

Agent 결과를 `docs/design/{taskId}-design.md`에 저장.
config.yaml의 `workflow.artifacts.design` 경로가 있으면 해당 경로 사용.

### Step 4: Update .task-context.json

```json
{
  "completedSteps": [..., "design"],
  "artifacts": {
    "design": "docs/design/{taskId}-design.md"
  }
}
```

### Step 5: Completion Summary

```
---
✅ **Design Complete** — {taskId}

- 설계 문서: `docs/design/{taskId}-design.md`

**Progress**: analyze → plan → **design ✓** → impl → review → done → e2e

**Next**: `/task impl {taskId}` — 설계 기반으로 구현을 시작합니다
---
```
