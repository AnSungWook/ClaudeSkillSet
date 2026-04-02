# skills/

Claude Code 스킬 파일 모음. 각 디렉토리의 `SKILL.md`가 스킬 정의.

## 구조

```
skills/
├── task/            ← 범용 태스크 워크플로 (이슈 트래커 없이 독립 동작)
├── analyze-spec/    ← 기획서/스토리보드 → MD 변환 (독립 스킬)
├── server/          ← 백엔드 서비스 기동/중지/빌드 (독립 스킬)
├── db/              ← 로컬 인프라(DB, 캐시) 관리 (독립 스킬)
├── e2e-test/        ← E2E API 테스트 (독립 스킬)
└── workflows/       ← 이슈 트래커 연동 워크플로 (jira-task 등)
```

## 독립 스킬 vs 워크플로

| 유형 | 설명 | 예시 |
|------|------|------|
| **독립 스킬** | 단독 실행 가능. context 있으면 연결, 없으면 독립 동작 | `/server`, `/db`, `/e2e-test`, `/analyze-spec` |
| **워크플로** | 여러 phase를 순차 연결. `.task-context.json`으로 상태 관리 | `/task`, `/jira-task` |

## setup.sh로 설치

`setup.sh`를 실행하면 프로젝트의 `.claude/skills/`에 복사된다.
독립 스킬은 항상 설치, 워크플로는 선택.
