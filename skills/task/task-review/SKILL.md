---
name: task-review
description: 3개 에이전트(code-reviewer, architecture-reviewer, test-reviewer)를 병렬 실행하여 코드 리뷰를 수행한다.
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
---

# task-review: Code Review (3-Agent Parallel)

## Language Rule

모든 출력을 한국어로 작성한다.
예외: 코드, 변수명, 파일명, 명령어는 영어를 유지한다.

## Workflow

### Step 1: Identify Changes

변경된 파일 목록과 diff를 수집:

```bash
# base branch 감지 (.task-context.json → develop → main → master)
git diff --name-only {baseBranch}..HEAD
git diff {baseBranch}..HEAD
```

`.task-context.json`의 `baseBranch`를 사용. 없으면 `develop` → `main` → `master` 순으로 탐색.

### Step 2: Gap Analysis (설계-구현 비교)

`docs/design/{taskId}-design.md`가 있으면 설계-구현 매칭 분석을 직접 수행:

1. Design 문서의 Implementation Plan 항목을 체크리스트로 변환
2. 각 항목에 대해 실제 구현 코드가 존재하는지 Glob/Grep으로 확인
3. 결과를 표로 정리:

| Design 항목 | 구현 여부 | 파일 위치 | 비고 |
|------------|----------|----------|------|
| {item} | O / X | {path} | {note} |

매칭률 = 구현된 항목 / 전체 항목 x 100

설계 문서가 없으면 이 단계를 스킵.

### Step 3: Launch 3 Review Agents in Parallel

`Agent` 도구로 3개 에이전트를 **동시에** 실행:

#### Agent 1: code-reviewer

```
Agent({
  description: "code-review: {taskId}",
  prompt: "코드 리뷰를 수행하세요.

## 변경된 파일
{파일 목록}

## Diff 요약
{diff 내용 또는 주요 변경 파일}

## Instructions
1. CLAUDE.md를 읽어 코딩 표준을 파악하세요
2. docs/standards/가 있으면 coding-standards.md, api-standards.md, error-handling.md를 읽으세요
3. 변경된 파일을 읽고 코딩 표준 위반을 찾으세요
4. 심각도별로 분류하세요: Critical / Warning / Info
5. 추가 검증 항목:
   - 이미 로드된 데이터를 별도 쿼리로 다시 조회하지 않는지
   - 조건 분기 3단계+, 스트림 체이닝 4단계+, 메서드 15줄+ 시 더 단순한 대안이 있는지
   - N+1 쿼리, 루프 내 쿼리, 이미 조회된 데이터의 재조회 금지
6. 결과를 마크다운으로 반환하세요

모든 출력은 한국어로 작성하세요."
})
```

#### Agent 2: architecture-reviewer

```
Agent({
  description: "architecture-review: {taskId}",
  prompt: "아키텍처 리뷰를 수행하세요.

## 변경된 파일
{파일 목록}

## Instructions
1. CLAUDE.md를 읽어 아키텍처 패턴, 모듈 구조를 파악하세요
2. docs/standards/가 있으면 아키텍처 관련 문서를 읽으세요
3. 변경된 파일이 올바른 레이어에 위치하는지, 모듈 경계를 준수하는지 검증하세요
4. 심각도별로 분류하세요
5. 결과를 마크다운으로 반환하세요

모든 출력은 한국어로 작성하세요."
})
```

#### Agent 3: test-reviewer

```
Agent({
  description: "test-review: {taskId}",
  prompt: "테스트 리뷰를 수행하세요.

## 변경된 파일
{파일 목록}

## Design Test Plan (있는 경우)
{design 문서의 Test Plan 섹션}

## Instructions
1. CLAUDE.md를 읽어 테스트 컨벤션을 파악하세요
2. docs/standards/가 있으면 testing-strategy.md를 읽으세요
3. 구현 코드에 대응하는 테스트가 있는지 확인하세요
4. 테스트 네이밍, 픽스처, Mock 사용이 프로젝트 패턴과 일치하는지 검증하세요
5. 결과를 마크다운으로 반환하세요

모든 출력은 한국어로 작성하세요."
})
```

### Step 4: Compile Review Report

3개 Agent 결과 + Gap Analysis를 통합하여 구조화된 리뷰 생성:

```markdown
# Review Report: {taskId}

**Date**: {date}
**Branch**: {branch}

## Summary
- **Result**: {Approve / Request Changes / Needs Discussion}
- **Files Reviewed**: {count}
- **Commits**: {count}

## Gap Analysis (설계-구현)
**매칭률**: {N}%
{매칭 테이블}

## Code Quality (code-reviewer)
{Agent 1 결과}

## Architecture (architecture-reviewer)
{Agent 2 결과}

## Test Coverage (test-reviewer)
{Agent 3 결과}

## Decision Criteria
- Approve: Critical 0개, Warning 2개 이하, 매칭률 90% 이상
- Request Changes: Critical 1개 이상, 또는 매칭률 80% 미만
- Needs Discussion: 그 외
```

### Step 5: Save Review Report

`docs/review/{taskId}-review.md`에 저장.

### Step 6: Update .task-context.json

**Approve 시:**
```json
{
  "completedSteps": [..., "review"],
  "artifacts": { "review": "docs/review/{taskId}-review.md" }
}
```

**Request Changes 시:** `completedSteps`에 "review"를 추가하지 않음.

### Step 7: Completion Summary

**Approve:**
```
---
✅ **Review Complete** — {taskId}

- 결과: Approve
- 설계-구현 매칭률: {N}%
- 리뷰 파일: {N}개
- 리뷰 리포트: `docs/review/{taskId}-review.md`

**Progress**: analyze → plan → design → impl → **review ✓** → done → e2e

**Next**: `/task done {taskId}` — 빌드 확인 후 완료 처리합니다
---
```

**Request Changes:**
```
---
⚠️ **Review: Changes Requested** — {taskId}

- 결과: Request Changes
- 주요 이슈:
  - {Critical/Warning 목록}

**Progress**: analyze → plan → design → impl → **review ✗** → done → e2e

**Next**: 이슈 수정 후 `/task review {taskId}` 재실행
---
```
