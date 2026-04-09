---
name: type-split
description: "[예시] 타입별 분기 컬럼 분리. CommonCode/Enum 타입에 따라 입력 컬럼이 달라지는 wide table을 감지하고 분리한다."
user-invocable: true
disable-model-invocation: false
recommended-model: opus
argument-hint: "{테이블명 | 엔티티명}"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# /type-split — 타입별 분기 컬럼 분리

> **[CUSTOMIZE]** 이 스킬은 Java sealed interface 기반 예시입니다.

## 감지 기준

"wide table" 안티패턴:
- 하나의 테이블에 타입 컬럼이 있고
- 타입에 따라 사용하는 컬럼이 달라지며
- 미사용 컬럼이 NULL로 남는 구조

## 분리 절차

1. **감지**: 타입 컬럼 + NULL 패턴 분석
2. **설계**: 타입별 별도 테이블 설계
3. **구현**: [CUSTOMIZE] sealed interface/abstract class 적용
4. **마이그레이션**: 기존 데이터 분리 SQL 생성

## 검증 기준

- [ ] 분리 후 각 타입 테이블에 NULL 컬럼 없음
- [ ] 공통 필드는 부모 인터페이스/클래스에 정의
- [ ] 기존 API 호환성 유지
