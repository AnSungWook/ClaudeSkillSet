---
name: task-impl
description: 설계 문서를 기반으로 코드를 구현한다. 에이전트 없이 직접 구현한다.
user-invocable: false
recommended-model: sonnet
argument-hint: "{taskId}"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

# task-impl: Implement Task

## Language Rule

모든 출력을 한국어로 작성한다.
예외: 코드, 변수명, 파일명, 명령어는 영어를 유지한다.

## Prerequisites

- design 문서가 있어야 한다 (`docs/design/{taskId}-design.md`). 없으면 경고.
- 브랜치가 준비되어 있지 않으면 사용자에게 안내.

## Workflow

### Step 1: Load Context

1. `.task-context.json` 읽기
2. `docs/design/{taskId}-design.md` 읽기 (없으면 plan, spec 순으로 대체)
3. `CLAUDE.md` 읽어 핵심 패턴, 작업 경계 확인
4. `.claude/task-conventions.md` 읽어 impl 컨벤션 확인
   - `impl` 섹션이 있으면 해당 규칙을 **반드시** 따른다
   - 없으면 CLAUDE.md의 핵심 패턴 + 기존 코드 탐색으로 대체

### Step 2: Implement Based on Design Document

design 문서의 **Implementation Plan** 순서를 따라 구현한다.

**구현 원칙:**
1. Implementation Plan의 순서를 따른다
2. **Reference Patterns에 명시된 기존 코드를 반드시 먼저 읽고 따라한다**
3. `.claude/task-conventions.md`의 impl 규칙을 100% 준수한다
4. 기존 코드 스타일과 패턴을 따른다 — 새로운 패턴을 도입하지 않는다
5. Error Handling, Security Checklist를 반영한다

**Design 문서가 없으면:**
- CLAUDE.md와 기존 코드 패턴을 탐색하여 구현
- 유사한 기존 구현을 Grep으로 찾아 참조

### Step 2.5: Write Tests Alongside Implementation

design 문서의 **Test Plan**에 명세된 테스트를 구현과 병행하여 작성.

- 기능 코드 작성 후 해당 테스트를 바로 작성
- 프로젝트의 기존 테스트 프레임워크와 패턴을 따름
- Test Plan이 없으면 핵심 로직의 단위테스트만 작성

### Step 3: Verify Implementation

CLAUDE.md에 빌드/컴파일 검증 명령이 명시되어 있으면 실행한다.
없으면 기본 검증:

```bash
# 프로젝트 빌드 도구에 따라
# Gradle: ./gradlew compileJava
# npm: npm run build
# etc.
```

검증 실패 시 수정 후 재검증. 통과할 때까지 반복.

### Step 4: Update .task-context.json

```json
{
  "completedSteps": [..., "impl"],
  "status": "In Progress"
}
```

### Step 5: Completion Summary

```
---
✅ **Implementation Complete** — {taskId}

- 생성된 파일: {list}
- 수정된 파일: {list}
- 빌드 검증: {통과/실패}

**Progress**: analyze → plan → design → **impl ✓** → review → done → e2e

**Next**: `/task review {taskId}` — 코드 리뷰를 실행합니다
---
```
