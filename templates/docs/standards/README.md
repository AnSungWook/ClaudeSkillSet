# docs/standards/ — 프로젝트 표준 규격

프로젝트의 **영구 표준 규칙(How)**을 정의하는 디렉토리.
CLAUDE.md가 ~50줄 개요라면, 여기는 상세 규정이다.

## ADR과의 관계

| | docs/standards/ | docs/adr/ |
|---|---|---|
| 성격 | 규칙 (How) — "항상 이렇게 한다" | 결정 기록 (Why) — "왜 이렇게 결정했는가" |
| 변경 빈도 | 거의 불변 | 계속 추가 |
| 예시 | "Controller는 `CommonResponse<T>` 반환" | "ADR-005: ResponseEntity 대신 CommonResponse 채택 (이유: 일관성)" |

**표준 규격이 먼저 확립되고, ADR은 그 결정의 이유를 기록한다.**

## 권장 파일 구조

프로젝트에 필요한 파일만 생성한다. 전부 만들 필요 없음.

| 파일 | 역할 | 참조하는 에이전트 |
|------|------|-----------------|
| `coding-standards.md` | 네이밍, 스타일, 금지 패턴, 클래스 구조 | code-reviewer, developer |
| `api-standards.md` | URL 설계, 응답 형식, 버저닝, 태그 규칙 | code-reviewer, developer |
| `error-handling.md` | 예외 계층, 에러 코드, 응답 형식 | code-reviewer, developer |
| `architecture-application.md` | 계층 구조, 모듈 역할, 의존 방향 | architecture-reviewer, design-architect |
| `architecture-infra.md` | 인프라 구성, 배포, CI/CD | architecture-reviewer |
| `database-guidelines.md` | DB 접근 패턴, 마이그레이션, 네이밍 | developer, code-reviewer |
| `testing-strategy.md` | 테스트 레벨, 커버리지, 픽스처, Mocking | test-reviewer, developer |
| `logging-guidelines.md` | 로깅 레벨, 형식, 민감 정보 규칙 | code-reviewer |

## 에이전트 로딩 순서

모든 에이전트는 아래 순서로 기준을 탐색한다:

```
1. CLAUDE.md              ← 핵심 패턴 (~50줄)
2. task-conventions.md     ← phase별 컨벤션 (~50줄)
3. docs/standards/*.md     ← 상세 규정 (이 디렉토리)
4. 기존 코드 (Glob/Grep)   ← 레퍼런스 패턴
5. (없으면) 범용 원칙 + 사용자 확인
```

## 작성 가이드

- **구체적으로**: "깔끔하게 작성" ✗ → "`@RequiredArgsConstructor` + `private final` 필드 주입" ✓
- **예시 포함**: 규칙만 쓰지 말고, 올바른 예시와 잘못된 예시를 함께
- **심각도 명시**: 각 규칙에 BLOCKER / WARNING / NIT 표시하면 code-reviewer가 정확히 분류
- **CLAUDE.md와 중복 금지**: CLAUDE.md에 이미 있는 내용은 여기서 반복하지 않음
