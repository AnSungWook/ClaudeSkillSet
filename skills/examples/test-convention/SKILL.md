---
name: test-convention
description: "[예시] 테스트 컨벤션 가이드. 프로젝트의 테스트 패턴, 네이밍, 데이터 관리 규칙을 정의한다."
user-invocable: true
disable-model-invocation: false
recommended-model: sonnet
allowed-tools:
  - Read
  - Glob
  - Grep
  - AskUserQuestion
---

# /test-convention — 테스트 컨벤션 가이드

> **[CUSTOMIZE]** 이 스킬은 JUnit 5 + Spring Boot Test 기반 예시입니다.

## 테스트 레벨

| 레벨 | 대상 | 네이밍 | [CUSTOMIZE] |
|------|------|--------|-------------|
| 단위 | 도메인/유틸 | `*Test` | 프레임워크 의존 없음 |
| 통합 | Service + DB | `*IT` | @SpringBootTest + @Transactional |
| API | Controller | `*ApiTest` | MockMvc / WebTestClient |

## 테스트 데이터 관리

- [CUSTOMIZE] 테스트 전용 설정 파일
- [CUSTOMIZE] 데이터 정리 방식 (rollback, truncate, etc.)
- [CUSTOMIZE] 공통 테스트 픽스처 모듈

## Mocking 전략

- 외부 시스템은 Mock/Stub으로 대체
- [CUSTOMIZE] 내부 DB는 실제 DB 사용 vs Mock 결정

## 검증 기준

- [ ] 구현 코드에 대응하는 테스트 존재
- [ ] 테스트 네이밍 컨벤션 준수
- [ ] Given-When-Then 구조
