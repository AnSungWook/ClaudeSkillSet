---
name: dto-design
description: "[예시] DTO 계층 분리 설계 가이드. Request/Query/Response 3계층으로 관심사를 분리한다."
user-invocable: true
disable-model-invocation: false
recommended-model: opus
argument-hint: "{기능명}"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# /dto-design — DTO 3계층 설계 가이드

> **[CUSTOMIZE]** 이 스킬은 Spring Boot 기반 예시입니다.

## 3계층 구조

| 계층 | 역할 | 위치 |
|------|------|------|
| Request | 외부 입력 수신 + validation | `application/dto/request/` |
| Query | 내부 조회 결과 전달 | `application/dto/query/` |
| Response | 외부 응답 출력 | `application/dto/response/` |

## 규칙

- 하나의 DTO가 여러 역할을 겸하지 않는다
- Request → Entity 매핑은 `toEntity()` 메서드로
- Response는 `of(Query)` 팩토리로 생성
- [CUSTOMIZE] DTO 기술 (Java record, Lombok class, Kotlin data class 등)

## 검증 기준

- [ ] 하나의 DTO가 Request/Query/Response를 겸하지 않음
- [ ] Request에 validation 어노테이션 존재
- [ ] Response가 Entity를 직접 노출하지 않음
