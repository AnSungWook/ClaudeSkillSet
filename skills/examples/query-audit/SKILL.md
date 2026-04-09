---
name: query-audit
description: "[예시] DB 쿼리 품질 감사. N+1, 루프 내 쿼리, 비효율 패턴을 감지한다."
user-invocable: true
disable-model-invocation: false
recommended-model: opus
argument-hint: "{파일경로 | git diff}"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(git diff *)
---

# /query-audit — DB 쿼리 품질 감사

> **[CUSTOMIZE]** 이 스킬은 jOOQ 기반 예시입니다. ORM/Query Builder에 맞게 수정하세요.

## 감사 대상

- `git diff` 기반 자동 감지 또는 특정 파일/디렉토리 지정
- [CUSTOMIZE] Repository/DAO/Mapper 파일 패턴

## 감사 항목

### BLOCKER
- [ ] N+1 쿼리: 루프 내에서 DB 호출
- [ ] 루프 내 쿼리: for/forEach/stream 안에서 repository 호출
- [ ] 페이징 없는 전체 조회 (대량 데이터 테이블)

### WARNING
- [ ] SELECT * (모든 컬럼 조회)
- [ ] 불필요한 JOIN (사용하지 않는 테이블 JOIN)
- [ ] 인덱스 미활용 쿼리 패턴
- [ ] 이미 로드된 데이터의 재조회

### INFO
- [ ] batch load → grouping → assign 패턴 미사용
- [ ] 쿼리 결과 캐싱 가능 여부

## 출력 형식

```
## 쿼리 감사 결과

### BLOCKER (N건)
1. `파일명:라인` — [N+1] 루프 내 repository 호출
   → 권장: batch load + Map grouping 패턴

### WARNING (N건)
...

### INFO (N건)
...
```
