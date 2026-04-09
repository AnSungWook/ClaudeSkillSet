# agents/

에이전트 = **역할** 정의 파일. 프로젝트별 기준은 포함하지 않는다.

에이전트는 실행 시 아래 순서로 프로젝트 기준을 스스로 찾아 읽는다:
```
CLAUDE.md → .claude/task-conventions.md → docs/standards/ → 기존 코드 탐색
```

## 에이전트 팀 구성

8개 스페셜리스트 에이전트가 팀으로 동작한다:

```
PM (오케스트레이터)
├── plan-analyst     → 분석/계획
├── design-architect → 설계
├── developer        → 구현
├── code-reviewer    ─┐
├── architecture-reviewer ─ 병렬 리뷰
├── test-reviewer    ─┘
└── convention-keeper → 규칙 전파 (필요 시)
```

## 파일 목록

| 파일 | 역할 | 사용하는 phase | model |
|------|------|--------------|-------|
| `pm.md` | PM/오케스트레이터 — Jira 관리, 에이전트 팀 조율 | `/task` 전체 | opus |
| `plan-analyst.md` | 요구사항 분석, 영향 범위 식별, 태스크 분해 | `/task plan` | opus |
| `design-architect.md` | 기존 패턴 탐색, 기술 설계, 참조 패턴 명시 | `/task design` | opus |
| `developer.md` | 기존 패턴 100% 준수 구현, TDD 모드 지원 | `/task impl` | sonnet |
| `code-reviewer.md` | 코딩 표준 위반 검사 (네이밍, 스타일, 보안, 복잡도) | `/task review` | opus |
| `architecture-reviewer.md` | 아키텍처 패턴 준수 검증 (계층, 모듈 경계) | `/task review` | opus |
| `test-reviewer.md` | 테스트 컨벤션 검증 (커버리지, 픽스처, 네이밍) | `/task review` | sonnet |
| `convention-keeper.md` | 새 ADR/표준 → 에이전트/스킬 파일 규칙 전파 | `/propagate-convention` | sonnet |

## 커스텀 에이전트 추가

1. 이 디렉토리에 `{name}.md` 생성
2. frontmatter에 `name`, `description`, `model`, `allowed-tools` 명시
3. "기준 로드" 섹션에서 위 탐색 순서를 따르도록 작성
4. config.yaml의 `workflow.review.agents`에 이름 추가 (review용인 경우)
