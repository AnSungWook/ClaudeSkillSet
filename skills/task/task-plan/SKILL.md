---
name: task-plan
description: 요구사항을 분석하여 기획 문서를 생성한다. plan-analyst 에이전트를 활용한다.
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

# task-plan: Generate Planning Document

## Language Rule

모든 출력을 한국어로 작성한다.
예외: 코드, 변수명, 파일명, 명령어는 영어를 유지한다.

## Workflow

### Step 1: Load Context

1. `.task-context.json` 읽기 — `taskId`, `artifacts.spec` 확인
2. `$ARGUMENTS`에서 taskId가 주어지면 우선 사용
3. spec 문서가 있으면(`artifacts.spec`) 읽어서 Agent에 전달할 컨텍스트 준비
4. spec이 없으면 사용자에게 요구사항 설명을 요청

### Step 1.5: Validate Information Sufficiency

수집한 정보의 충분성을 평가:

**필수 정보 체크리스트:**
- [ ] 무엇을 구현해야 하는지 명확한가?
- [ ] 성공 기준(Acceptance Criteria)을 유추할 수 있는가?
- [ ] 대상 모듈/영역이 식별 가능한가?

부족하면 `AskUserQuestion`으로 보충 질문. 충분하면 Step 2로.

### Step 2: Run plan-analyst Agent

`Agent` 도구로 plan-analyst 에이전트를 실행:

```
Agent({
  description: "plan-analyst: {taskId} 기획 분석",
  prompt: "다음 태스크의 기획 분석을 수행하세요.

## Task
- taskId: {taskId}

## Spec (있는 경우)
{spec 문서 내용}

## Instructions
1. CLAUDE.md를 읽어 프로젝트 개요와 핵심 패턴을 파악하세요
2. .claude/task-conventions.md가 있으면 plan 섹션을 읽으세요
3. plan-analyst 에이전트 역할에 따라 분석을 수행하세요
4. 태스크를 2-7개 단계로 분해하고, 각 단계에 대상 파일/참조 파일/검증 기준을 명시하세요
5. Handoff Envelope을 마지막에 포함하세요
6. 결과를 마크다운 형식으로 반환하세요

모든 출력은 한국어로 작성하세요."
})
```

### Step 2.5: Validate Plan Quality

Agent 결과를 검증:

**필수 포함 항목:**
- [ ] 영향 범위 식별 (모듈/파일/레이어)
- [ ] 2-7개 단계 분해 (각 단계에 대상 파일, 참조 파일, 검증 기준)
- [ ] 기존 패턴 참조 (유사 구현 파일 경로)
- [ ] 위험 요소 식별
- [ ] Handoff Envelope

누락된 항목이 있으면 Agent를 재실행하여 보충.

### Step 3: Save Plan Document

Agent 결과를 `docs/plan/{taskId}-plan.md`에 저장.
config.yaml의 `workflow.artifacts.plan` 경로가 있으면 해당 경로 사용.

### Step 4: Update .task-context.json

```json
{
  "completedSteps": [..., "plan"],
  "artifacts": {
    "plan": "docs/plan/{taskId}-plan.md"
  }
}
```

### Step 5: Completion Summary

```
---
✅ **Plan Complete** — {taskId}

- 기획 문서: `docs/plan/{taskId}-plan.md`

**Progress**: analyze → **plan ✓** → design → impl → review → done → e2e

**Next**: `/task design {taskId}` — 설계 문서를 작성합니다
---
```
