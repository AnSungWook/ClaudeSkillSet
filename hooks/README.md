# hooks/

Claude Code 훅 스크립트. `settings.json`에 등록하여 특정 이벤트 시 자동 실행된다.

## 파일 목록

| 파일 | 이벤트 | 용도 |
|------|--------|------|
| `guard-merge.sh` | PreToolUse(Bash) | 머지 보호 — worktree에서 잘못된 브랜치로 머지하는 것을 방지 |
| `session-logger.sh` | SessionStart, UserPromptSubmit, PostToolUse | 세션 감사 로거 — 세션 시작, 프롬프트, git 명령을 `.worktree.log`에 기록 |
| `notify.sh` | Notification | 작업 완료 알림 — macOS/Linux/WSL 데스크톱 알림 |

## 설치

`setup.sh`가 자동으로 `.claude/hooks/`에 복사합니다.

수동 설치 시:
```bash
mkdir -p .claude/hooks
cp hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

## 설정

`templates/settings.json.template`에 모든 hook이 미리 등록되어 있습니다.
프로젝트의 `.claude/settings.json`에 복사하여 사용하세요.
