---
name: port-adapter
description: "[예시] Hexagonal Architecture Port/Adapter 설계. 도메인 Port 인터페이스와 Infrastructure Adapter 구현을 분리한다."
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

# /port-adapter — Hexagonal Architecture 설계 가이드

> **[CUSTOMIZE]** 이 스킬은 Spring Boot + jOOQ 기반 예시입니다.

## 구조

```
domain/port/
├── repository/     # Command/Query 분리 인터페이스
├── assembler/      # 복합 조회 조립 인터페이스
└── resolver/       # 비즈니스 규칙 전략 인터페이스

infrastructure/adaptor/
├── repository/     # jOOQ 구현 (@Repository)
├── assembler/      # 조립 구현 (@Component)
└── resolver/       # 전략 구현
```

## 규칙

- Port(인터페이스)는 domain에, Adapter(구현)는 infrastructure에
- domain 패키지는 프레임워크에 절대 의존하지 않음
- Repository는 Command/Query로 분리
- generic CRUD 메서드(`save`, `findAll`) 금지 — use-case 기반 메서드명
- [CUSTOMIZE] ORM/Query Builder 종류, DI 프레임워크

## 검증 기준

- [ ] Port 인터페이스에 프레임워크 import 없음
- [ ] Adapter가 올바른 위치에 배치
- [ ] Command/Query 분리 준수
