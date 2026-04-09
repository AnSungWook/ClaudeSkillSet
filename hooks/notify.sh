#!/bin/bash
# =============================================================================
# 작업 완료 알림
# =============================================================================
# Notification hook에서 실행. 플랫폼별 알림을 보낸다.
#
# 사용법 (settings.json hooks 설정):
#   Notification:
#     bash "$CLAUDE_PROJECT_DIR/.claude/hooks/notify.sh"
# =============================================================================

TITLE="Claude Code"
MESSAGE="작업이 완료되었습니다"

# macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null
  exit 0
fi

# Linux (notify-send)
if command -v notify-send &>/dev/null; then
  notify-send "$TITLE" "$MESSAGE" 2>/dev/null
  exit 0
fi

# Windows (WSL)
if command -v powershell.exe &>/dev/null; then
  powershell.exe -Command "[System.Windows.Forms.MessageBox]::Show('$MESSAGE','$TITLE')" 2>/dev/null
  exit 0
fi

# Fallback: terminal bell
echo -e "\a"
