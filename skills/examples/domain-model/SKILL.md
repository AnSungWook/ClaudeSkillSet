---
name: domain-model
description: "[예시] DDD 도메인 모델 설계 가이드. Entity, Value Object, Collection VO, Exception을 의존성 순서대로 생성한다."
user-invocable: true
disable-model-invocation: false
recommended-model: opus
argument-hint: "{도메인명}"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# /domain-model — DDD 도메인 모델 설계 가이드

> **[CUSTOMIZE]** 이 스킬은 Spring Boot + jOOQ 기반 예시입니다.
> 프로젝트 기술 스택에 맞게 수정하세요.

## Language Rule

모든 출력을 한국어로 작성한다.
예외: 코드, 변수명, 파일명, 명령어는 영어를 유지한다.

## 생성 순서 (의존성 기반)

```
Exception → Value Object → Entity → Collection VO
```

### 1. Exception 계층

```
{Module}Exception (abstract, extends DomainException)
├── {Module}NotFoundException
├── {Module}InvalidValueException
└── {Module}DuplicateException
```

- [CUSTOMIZE] 베이스 예외 클래스명과 상속 구조

### 2. Value Object

- 도메인 행위를 포함 (단순 getter-only data holder 아님)
- private 생성자 + static 팩토리
- [CUSTOMIZE] 불변 보장 방식 (Java record, Kotlin data class, TypeScript readonly 등)

### 3. Entity

- private 생성자 + 팩토리 메서드 (`create()` / `load()`)
- 내부 Validator로 불변량 보호
- [CUSTOMIZE] 감사 필드 처리 방식 (AOP, interceptor, middleware 등)

### 4. Collection VO

- 일급 컬렉션으로 List를 감쌈
- 도메인 조회/검증 행위 제공 (`find()`, `get()`, `isEmpty()`)
- [CUSTOMIZE] 컬렉션 베이스 클래스 (AbstractCollection, ImmutableList 등)

## 검증 기준

- [ ] 컴파일/빌드 성공
- [ ] Entity의 create()에 유효하지 않은 값 → 예외 발생
- [ ] VO가 행위를 가지고 있는지 (getter-only 아닌지)
- [ ] Collection VO가 raw List를 노출하지 않는지
