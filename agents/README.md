# agents/

에이전트 = **역할** 정의 파일. 프로젝트별 기준은 포함하지 않는다.

에이전트는 실행 시 아래 순서로 프로젝트 기준을 스스로 찾아 읽는다:
```
CLAUDE.md → .claude/task-conventions.md → docs/standards/ → 기존 코드 탐색
```

## 파일 목록

| 파일 | 역할 | 사용하는 phase | model |
|------|------|--------------|-------|
| `plan-analyst.md` | 요구사항 분석, 영향 범위 식별, 태스크 분해 | `/task plan` | opus |
| `design-architect.md` | 기존 패턴 탐색, 기술 설계, 참조 패턴 명시 | `/task design` | opus |
| `code-reviewer.md` | 코딩 표준 위반 검사 (네이밍, 스타일, 보안) | `/task review` | opus |
| `architecture-reviewer.md` | 아키텍처 패턴 준수 검증 (계층, 모듈 경계) | `/task review` | opus |
| `test-reviewer.md` | 테스트 컨벤션 검증 (커버리지, 픽스처, 네이밍) | `/task review` | sonnet |

## 커스텀 에이전트 추가

1. 이 디렉토리에 `{name}.md` 생성
2. frontmatter에 `name`, `description`, `model`, `allowed-tools` 명시
3. "기준 로드" 섹션에서 위 탐색 순서를 따르도록 작성
4. config.yaml의 `workflow.review.agents`에 이름 추가 (review용인 경우)
