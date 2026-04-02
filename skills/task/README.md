# skills/task/

범용 태스크 워크플로. Jira/GitHub 없이 `.task-context.json` 기반으로 동작한다.

## 플로우

```
/task analyze  → 기획서 분석 (analyze-spec 호출)
/task plan     → 기획 문서 (plan-analyst 에이전트)
/task design   → 설계 문서 (design-architect 에이전트)
/task impl     → 구현 (직접 실행)
/task review   → 코드 리뷰 (3개 에이전트 병렬)
/task done     → 빌드 확인 + 완료 처리
/task e2e      → E2E 테스트 (e2e-test 호출)
/task          → 현재 상태 확인
```

## 파일 구조

| 파일 | 역할 |
|------|------|
| `SKILL.md` | 라우터 — 인자 파싱 후 하위 스킬로 분기 |
| `task-analyze/SKILL.md` | `/analyze-spec` 호출 → context 기록 |
| `task-plan/SKILL.md` | plan-analyst 에이전트 → plan 문서 생성 |
| `task-design/SKILL.md` | design-architect 에이전트 → design 문서 생성 |
| `task-impl/SKILL.md` | 설계 기반 직접 구현 (에이전트 없음) |
| `task-review/SKILL.md` | code/architecture/test 리뷰어 3개 병렬 |
| `task-done/SKILL.md` | 빌드 확인 + 변경 요약 + 완료 |
| `task-e2e/SKILL.md` | `/e2e-test` 호출 → context 기록 |

## 컨벤션 참조 경로

에이전트가 프로젝트 기준을 읽는 순서:
```
CLAUDE.md → .claude/task-conventions.md → docs/standards/ → 기존 코드
```

## 산출물 경로

| Phase | 기본 경로 |
|-------|----------|
| analyze | `docs/specs/{taskId}.md` |
| plan | `docs/plan/{taskId}-plan.md` |
| design | `docs/design/{taskId}-design.md` |
| review | `docs/review/{taskId}-review.md` |

경로는 `config.yaml`의 `workflow.artifacts`로 변경 가능.
