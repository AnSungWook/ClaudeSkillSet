#!/bin/bash
# =============================================================================
# 세션 감사 로거
# =============================================================================
# 3개 hook에서 공유하는 로깅 스크립트
#
# 사용법 (settings.json hooks 설정):
#
# SessionStart:
#   bash "$CLAUDE_PROJECT_DIR/.claude/hooks/session-logger.sh" session-start
#
# UserPromptSubmit:
#   bash "$CLAUDE_PROJECT_DIR/.claude/hooks/session-logger.sh" prompt "$CLAUDE_USER_PROMPT"
#
# PostToolUse (Bash matcher):
#   bash "$CLAUDE_PROJECT_DIR/.claude/hooks/session-logger.sh" tool "$CLAUDE_BASH_COMMAND"
# =============================================================================

LOG_FILE="${CLAUDE_PROJECT_DIR:-.}/.worktree.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
ACTION="${1:-unknown}"

case "$ACTION" in
  session-start)
    # 세션 시작 기록 + 최근 로그 80줄 출력
    echo "[$TIMESTAMP] === SESSION START ===" >> "$LOG_FILE"

    # 최근 로그가 있으면 표시 (jq 가용 시 구조화, 아니면 tail)
    if [ -f "$LOG_FILE" ]; then
      if command -v jq &>/dev/null; then
        tail -80 "$LOG_FILE" | jq -R '.' 2>/dev/null || tail -80 "$LOG_FILE"
      else
        tail -80 "$LOG_FILE"
      fi
    fi
    ;;

  prompt)
    # 사용자 프롬프트 기록 (최대 300자)
    PROMPT="${2:-}"
    TRUNCATED="${PROMPT:0:300}"
    echo "[$TIMESTAMP] PROMPT: $TRUNCATED" >> "$LOG_FILE"
    ;;

  tool)
    # git commit/push/merge 명령만 기록
    CMD="${2:-}"
    if echo "$CMD" | grep -qE 'git\s+(commit|push|merge)'; then
      echo "[$TIMESTAMP] GIT: $CMD" >> "$LOG_FILE"
    fi
    ;;

  *)
    echo "[$TIMESTAMP] UNKNOWN: $ACTION" >> "$LOG_FILE"
    ;;
esac
