---
name: domain-refactor
description: "[예시] 도메인 코드 품질 리팩토링. 기존 코드를 프로젝트 구현 가이드라인에 맞게 개선한다."
user-invocable: true
disable-model-invocation: false
recommended-model: opus
argument-hint: "{대상 파일/디렉토리}"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# /domain-refactor — 도메인 코드 리팩토링

> **[CUSTOMIZE]** 이 스킬은 DDD + Clean Architecture 기반 예시입니다.

## 리팩토링 대상 감지

code-reviewer 또는 architecture-reviewer가 감지한 이슈를 기반으로 리팩토링:

### 흔한 안티패턴

1. **public 생성자 Entity** → private ctor + 팩토리 메서드
2. **raw List 노출** → Collection VO로 래핑
3. **Service에 도메인 로직** → Entity/VO로 이동
4. **generic CRUD Repository** → use-case 기반 메서드
5. **하나의 DTO가 여러 역할** → Request/Query/Response 분리
6. [CUSTOMIZE] 프로젝트별 안티패턴 추가

## 절차

1. **감지**: reviewer가 이슈 목록 생성
2. **계획**: 변경 순서 결정 (안쪽 레이어부터)
3. **적용**: developer가 리팩토링 실행
4. **검증**: 기존 테스트 통과 확인

## 검증 기준

- [ ] 기존 테스트 전체 통과
- [ ] 외부 API 호환성 유지
- [ ] 리팩토링 전후 동작 동일
