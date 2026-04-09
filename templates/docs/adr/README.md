# docs/adr/ — Architecture Decision Records

프로젝트의 **의사결정 기록**을 보관하는 디렉토리.

## ADR이란?

ADR(Architecture Decision Record)은 **왜 이 결정을 했는가**를 기록하는 문서다.
`docs/standards/`가 "어떻게 해야 하는가(How)"를 정의한다면, ADR은 "왜 이렇게 결정했는가(Why)"를 기록한다.

| | docs/standards/ | docs/adr/ |
|---|---|---|
| 성격 | 규칙 (How) | 결정 기록 (Why) |
| 변경 빈도 | 거의 불변 | 계속 추가 |
| 예시 | "API는 항상 snake_case" | "ADR-007: snake_case 채택 (이유: 기존 시스템 호환)" |

## 파일 네이밍

```
ADR-{NNN}_{slug}.md
```

예시:
- `ADR-001_keycode-wrapper.md`
- `ADR-002_collection-vo-pattern.md`
- `ADR-003_flyway-to-liquibase.md`

## 규칙 전파 연동

- `/propagate-convention` 스킬과 `convention-keeper` 에이전트는 ADR을 **규칙의 단일 원본(Single Source of Truth)**으로 사용한다
- 새 규칙을 에이전트/스킬에 전파하려면 **먼저 ADR을 생성**해야 한다
- ADR이 없는 규칙은 전파되지 않는다
