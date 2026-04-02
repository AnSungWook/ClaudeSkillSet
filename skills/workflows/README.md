# skills/workflows/

외부 이슈 트래커와 연동하는 워크플로 스킬.
`setup.sh`에서 하나를 선택하여 프로젝트에 설치한다.

## 사용 가능한 워크플로

| 디렉토리 | 이슈 트래커 | 설명 |
|----------|-----------|------|
| `jira-task/` | Jira (MCP) | Jira 이슈 기반 워크플로. 상태 전환, 코멘트, 첨부 자동화 |

## task vs workflows

이슈 트래커가 **없으면** → `skills/task/` (범용, 독립 동작)
이슈 트래커가 **있으면** → `skills/workflows/{tracker}/` (연동)

둘 다 같은 에이전트(`agents/`)와 컨벤션(`.claude/task-conventions.md`)을 공유한다.
