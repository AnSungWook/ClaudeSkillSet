# templates/

프로젝트에 복사되는 템플릿 파일. `setup.sh`가 이 파일들을 대상 프로젝트에 배치한다.

## 파일 목록

| 파일 | 복사 위치 | 역할 |
|------|----------|------|
| `CLAUDE.md.template` | `{project}/CLAUDE.md` | 프로젝트 개요 + 포인터 (~50줄). 200줄 이내 유지 권장 |
| `task-conventions.md.template` | `{project}/.claude/task-conventions.md` | phase별 워크플로 컨벤션 (plan/design/impl/test/review) |
| `settings.json.template` | `{project}/.claude/settings.json` | Claude Code 권한/환경 설정 (hooks 5개 + deny list 포함) |
| `.mcp.json.template` | `{project}/.mcp.json` | MCP 서버 설정 (Jira, PostgreSQL, Playwright) |

## docs/ 하위 구조

| 디렉토리 | 복사 방식 | 역할 |
|----------|----------|------|
| `docs/adr/` | 디렉토리 + 템플릿 복사 | 의사결정 기록 (Why). ADR-000 템플릿 포함 |
| `docs/standards/` | 디렉토리 + 템플릿 복사 | 표준 규격 (How). coding/api/testing 템플릿 포함 |
| `docs/artifacts/` | README만 → `docs/ARTIFACTS.md`로 복사 | 6개 산출물 디렉토리(specs, plan, design, review, test, reports) 가이드 |

## 컨벤션 계층

```
CLAUDE.md (~50줄)               ← 프로젝트 개요, 기술 스택, 핵심 패턴
.claude/task-conventions.md     ← phase별 컨벤션 (CLAUDE.md에서 분리)
docs/standards/*.md             ← 상세 표준 규격 (How)
docs/adr/*.md                   ← 의사결정 기록 (Why)
```

CLAUDE.md에 모든 규칙을 넣으면 200줄을 초과하므로,
phase 컨벤션은 `task-conventions.md`로, 상세 규정은 `docs/standards/`로 분리한다.
