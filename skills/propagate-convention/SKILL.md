---
name: propagate-convention
description: 새 ADR/표준 추가 시 관련 에이전트·스킬 파일에 체크리스트, 안티패턴, 가이드를 자동 전파한다. Use /propagate-convention to propagate new rules to all agent/skill files.
user-invocable: true
disable-model-invocation: false
recommended-model: sonnet
argument-hint: "{ADR-NNN | rule-name} {요약}"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# /propagate-convention — 규칙 전파

## Language Rule

모든 출력을 한국어로 작성한다.
예외: 코드, 변수명, 파일명, 명령어는 영어를 유지한다.

## Workflow

### Step 1: Parse Arguments

`$ARGUMENTS`에서 규칙 원본과 요약을 파싱:
- `ADR-*` → `docs/adr/ADR-*` 문서 검색
- `CLAUDE.md 규칙 #N` → CLAUDE.md에서 해당 규칙 검색
- 경로 직접 지정 → 해당 파일 읽기

### Step 2: ADR 존재 확인 (필수)

대응하는 ADR이 `docs/adr/`에 존재하는지 확인.

**ADR이 없으면 전파를 시작하지 않는다.**
먼저 `docs/adr/ADR-{NNN}_{slug}.md`를 생성한 후 전파를 진행한다.
- 기존 ADR 번호 체계에 맞게 다음 번호 부여
- 최소 섹션: Status, Date, Intent, Context, Decision, Consequences, References
- Status: `Draft` (내용이 확정되면 `Accepted`로 변경)

### Step 3: Run convention-keeper Agent

```
Agent({
  description: "convention-keeper: 규칙 전파",
  prompt: "다음 규칙의 전파를 수행하세요.

## 규칙 원본
{ADR 문서 내용 또는 CLAUDE.md 규칙}

## 규칙 요약
{1-2문장 핵심}

## Instructions
1. CLAUDE.md를 읽어 프로젝트 개요를 파악하세요
2. .claude/agents/*.md, .claude/skills/*/SKILL.md 파일들을 확인하세요
3. 각 파일에서 규칙 관련 키워드가 이미 존재하는지 Grep으로 확인하세요
4. 영향 매핑 → 변경 계획을 산출하세요
5. 변경 계획을 마크다운 표로 반환하세요 (파일, 섹션, 조치, 심각도)

모든 출력은 한국어로 작성하세요."
})
```

### Step 4: 변경 계획 승인

convention-keeper의 변경 계획을 사용자에게 표시:
- 변경 대상 파일 목록
- 각 파일의 변경 위치와 내용 요약

`AskUserQuestion`으로 승인 요청. **승인 없이 파일 수정 금지.**

### Step 5: 전파 실행

승인 후 convention-keeper 에이전트를 재실행하여 실제 Edit 수행.

### Step 6: 검증 및 완료

- 모든 대상 파일에서 규칙 키워드 Grep 검색
- 누락 파일 없는지 확인

```
---
✅ **Convention Propagation Complete**

- 규칙: {규칙 요약}
- 수정된 파일: {N}개
- 추가된 체크리스트 항목: {N}건
- 누락: 없음
---
```
