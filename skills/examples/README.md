# Example Skills (기술 특화 예시)

이 디렉토리의 스킬들은 **특정 기술 스택에 특화된 예시**입니다.
프로젝트에 맞게 커스터마이즈하여 사용하세요.

## 사용법

1. 프로젝트에 맞는 예시를 `.claude/skills/`에 복사
2. 기술 스택에 맞게 SKILL.md 수정
3. 체크리스트/패턴을 프로젝트 컨벤션에 맞게 조정

## 예시 목록

| 디렉토리 | 설명 | 기술 스택 예시 |
|----------|------|---------------|
| `domain-model/` | DDD 도메인 모델 설계 가이드 | Spring Boot + jOOQ |
| `dto-design/` | DTO 계층 분리 설계 가이드 | Spring Boot |
| `port-adapter/` | Hexagonal Architecture Port/Adapter 설계 | Spring Boot + jOOQ |
| `query-audit/` | DB 쿼리 품질 감사 | jOOQ |
| `type-split/` | wide table 분리 + sealed interface | Java 17+ |
| `test-convention/` | 테스트 컨벤션 가이드 | JUnit 5 + Spring Boot Test |
| `domain-refactor/` | 도메인 코드 리팩토링 가이드 | DDD + Clean Architecture |

## 커스터마이즈 가이드

### 다른 기술 스택으로 변환

예시는 Spring Boot + jOOQ 기준이지만, 핵심 원칙은 범용적입니다:

- **domain-model**: Entity/VO/Collection 패턴 → TypeScript의 class/interface, Go의 struct로 변환
- **dto-design**: Request/Query/Response 분리 → GraphQL의 Input/Type, gRPC의 Message로 변환
- **port-adapter**: Port/Adapter → 어떤 언어든 interface + implementation 분리
- **query-audit**: N+1 감지, 루프 내 쿼리 → ORM/Query Builder 무관하게 적용

### 최소 수정 포인트

각 SKILL.md에서 `[CUSTOMIZE]` 마커가 있는 부분을 프로젝트에 맞게 수정하세요.
