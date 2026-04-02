# sync-jira: Jira 연동 + 태스크 세분화

analyze-spec 산출물을 Jira에 연결하고, API 단위로 태스크를 세분화하여 의존관계/병렬화 정보를 포함한다.

## 진입 방식

1. `/analyze-spec sync-jira` → AskUserQuestion으로 spec MD 경로 입력
2. `/analyze-spec sync-jira docs/specs/xxx.md` → 지정된 경로 사용

---

## Step SJ-1: 산출물 확인

spec MD + schema-check MD 존재 여부 확인.

---

## Step SJ-2: 에픽 생성 또는 연결

AskUserQuestion: "에픽을 새로 만들까요, 기존 에픽에 연결할까요?"
- 새 에픽: spec MD 제목 기반 자동 제안 + 담당자 설정
- 기존 에픽: KEY 입력

---

## Step SJ-2.5: 태스크 세분화 + 의존관계 분석

spec MD + schema-check + **코드베이스 분석**을 통해 태스크를 도출하고 의존관계를 매핑한다.

### 2.5.1 태스크 도출

spec MD에서 API 목록을 추출하여 **API 개별 = 1 태스크** 원칙으로 세분화.

### 2.5.2 의존관계 분석

코드베이스의 기존 패턴을 Explore Agent로 분석하여 아래 규칙 적용:

**CQRS 기반 병렬화:**
- Command(POST/PUT)와 Query(GET)는 **독립 서비스** → 같은 도메인 내 병렬 가능

**FK 기반 순서:**
- 부모 엔티티 먼저 (예: 그룹 → 항목 → 상세)
- DB FK 관계로 Phase 순서 결정

### 2.5.3 Phase 배정 결과 예시

```
Phase 0+1: {부모 엔티티} CRUD (도메인 모델 구축 포함)
  ├─ [KEY] 등록 ──┐ 병렬
  ├─ [KEY] 조회 ──┤ 병렬
  └─ [KEY] 수정 ──┘ 병렬

Phase 2: {자식 엔티티} CRUD (Phase 1 완료 후)
  ├─ ... 동일 패턴
```

---

## Step SJ-3: 태스크 생성

각 태스크 description에 아래 정보를 포함:

```
Phase: {N} | 선행: {선행 KEY 또는 "없음"}
병렬 가능: {같은 Phase 태스크 KEY 목록}
---
{API 스펙 요약: Method, URL, Request/Response 필드}
관련 테이블: {DB 테이블 목록}
참조: docs/specs/{name}.md #{섹션 번호}
```

---

## Step SJ-4: 에픽 업데이트

에픽 description에 전체 태스크 목록 + 의존관계 그래프 + 추천 실행 순서 추가.

---

## Step SJ-5: 완료 보고

```
## Jira 연동 완료

- **에픽**: {KEY}
- **하위 태스크**: {N}건
- **병렬화**: Phase {N}개, 최대 동시 {N} worktree

다음: /jira-task start {첫 번째 태스크 KEY}
```
