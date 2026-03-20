---
name: jira-task
description: Jira task workflow orchestration for Codex. init/start/plan/design/impl/test/review/pr/done/report/status/auto 흐름을 .jira-context.json 기준으로 관리한다.
---

# Jira Task Skill

## Trigger
- Jira 중심 개발 플로우 요청: `jira-task`, `task start`, `plan 문서`, `design 문서`, `test report`, `review`, `pr 생성`, `작업 완료`, `status`, `auto`.

## Input Contract
- Action format: `[action] [TASK-ID?]`
- Supported actions: `init`, `start`, `plan`, `design`, `impl`, `test`, `review`, `merge`, `pr`, `done`, `report`, `status`, `auto`.
- `init` 입력은 `[count | ISSUE-KEY | 자연어설명]` 형식을 추가로 지원한다.
  - 숫자/빈 입력: 할당된 작업 일괄 초기화
  - 이슈 키 포함 입력: 부모/하위작업 기준 초기화
  - 자연어만 있는 입력: 이슈 키 확인 또는 Jira 검색 근거를 먼저 확보
- TASK-ID 생략 시 탐지 순서:
1. 브랜치 `feature/<TASK-ID>`
2. 현재 디렉터리명 `[A-Z]+-[0-9]+`
3. `.jira-context.json`의 `taskId`

## Execution Policy
- Primary: Codex developer tools + Jira MCP
  - Jira 상태 조회/코멘트/전환/링크는 `mcp__jira-mcp__*` 도구를 우선 사용한다.
  - 로컬 context/doc 생성은 `scripts/jira_task_context.sh`, `scripts/jira_task_detect.sh` 또는 직접 파일 편집으로 처리한다.
- Root scripts 연계:
  - 구현/테스트/서버 검증 중 런타임 실행이 필요하면 root `scripts/bootrun.sh`, `scripts/mysql-tunnel.sh`, `scripts/test-cleanup.sh`를 우선 사용.
- Fallback:
  - Jira MCP를 사용할 수 없는 경우에만 `scripts/jira_task_run.sh`, `scripts/jira_task_comment.sh`, `scripts/jira_task_attach.sh`, `scripts/jira_task_transition.sh`를 사용한다.
  - root scripts가 없는 단계만 모듈 `./gradlew` 또는 수동 실행.

## Mandatory Execution Path
- 기본 원칙:
  - Jira에 반영하는 액션(`start`, `plan`, `design`, `impl`, `test`, `review`, `pr`, `done`)은 MCP tool로 직접 수행한다.
  - 로컬 문서/컨텍스트 생성이 필요한 경우에만 skill 내 scripts를 부분적으로 사용한다.
- `auto`는 경량 오케스트레이터로 유지한다.
  - 단계 실행 전후마다 `.jira-context.json`을 다시 읽어 완료 여부를 판단한다.
  - `review`가 `Request Changes`이면 리뷰 문서를 기준으로 수정 후 `test -> review`를 최대 2회 재시도한다.
  - Codex에는 Claude plugin의 `recommended-model`/sub-agent 라우팅이 없으므로, 모델 추천 메타데이터는 이식하지 않는다.
- shell runner는 fallback 경로이며, sandbox 네트워크 제약으로 Jira `curl` 호출이 실패할 수 있음을 전제로 한다.
- shell fallback은 코드 자동수정 컨텍스트가 없으므로 `review` 미통과 시 재시도 대신 복구 명령을 출력하고 중단한다.
- fallback runner 실패 시 실패 단계/원인/복구 명령을 그대로 전달한다.

## Workflow Source
- 상세 단계: `references/workflows.md`
- 템플릿: `references/templates.md`

## Context State
- 진행 상태는 `.jira-context.json`으로 관리.
- 갱신에는 `scripts/jira_task_context.sh` 사용.
- `baseBranch`는 `init` 시 기본 저장 대상이다.
- `baseBranch`가 비어 있으면 shell runner는 Jira 부모 이슈의 `feature/<PARENT-KEY>` 브랜치를 먼저 추론하고, 없을 때만 `origin/HEAD` 또는 `develop`으로 폴백한다.

## Standard Artifacts
- `docs/plan/<TASK-ID>.plan.md`
- `docs/design/<TASK-ID>.design.md`
- `docs/test/<TASK-ID>.test-report.md`
- `docs/review/<TASK-ID>.review.md`
- `docs/reports/status-<YYYY-MM-DD>.report.md`

## Output Language
- 사용자 설명/코멘트는 한국어.
- 코드 식별자/경로/명령은 영어.

## MCP Mapping
- 코멘트 등록: `mcp__jira-mcp__jira_add_comment`
- 상태 조회/이슈 확인: `mcp__jira-mcp__jira_get_issue`
- 전환 가능 상태 조회: `mcp__jira-mcp__jira_get_transitions`
- 상태 전환: `mcp__jira-mcp__jira_transition_issue`
- 원격 링크 추가: `mcp__jira-mcp__jira_create_remote_issue_link`

## Attachment Rule
- 현재 기본 toolset에는 Jira 파일 첨부 전용 MCP tool이 없으므로, MCP 경로에서는 아래 순서를 따른다.
1. 로컬 산출물 파일 생성/갱신
2. Jira 코멘트에 문서 경로와 핵심 요약을 남김
3. 원격 URL이 있는 문서만 `jira_create_remote_issue_link`로 링크
- shell attachment script는 네트워크 제약이 없는 환경에서만 fallback으로 사용한다.
