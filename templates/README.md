# templates/

프로젝트에 복사되는 템플릿 파일. `setup.sh`가 이 파일들을 대상 프로젝트에 배치한다.

## 파일 목록

| 파일 | 복사 위치 | 역할 |
|------|----------|------|
| `CLAUDE.md.template` | `{project}/CLAUDE.md` | 프로젝트 개요 + 포인터 (~50줄). 200줄 이내 유지 권장 |
| `task-conventions.md.template` | `{project}/.claude/task-conventions.md` | phase별 워크플로 컨벤션 (plan/design/impl/test/review) |
| `settings.json.template` | `{project}/.claude/settings.json` | Claude Code 권한/환경 설정 (hooks 5개 + deny list 포함) |
| `.mcp.json.template` | `{project}/.mcp.json` | MCP 서버 설정 (Jira, PostgreSQL, Playwright) |

## 컨벤션 분리 원칙

```
CLAUDE.md (~50줄)               ← 프로젝트 개요, 기술 스택, 핵심 패턴, 포인터
.claude/task-conventions.md     ← phase별 컨벤션 (CLAUDE.md에서 분리)
docs/standards/*.md             ← 상세 규정 (코딩 표준, API 규격 등)
```

CLAUDE.md에 모든 규칙을 넣으면 200줄을 초과하므로,
phase 컨벤션은 `task-conventions.md`로, 상세 규정은 `docs/standards/`로 분리한다.
