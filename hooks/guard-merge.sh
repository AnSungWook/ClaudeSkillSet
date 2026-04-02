#!/bin/bash
# 머지 보호 훅: .jira-context.json의 baseBranch와 현재 브랜치 일치 확인
# PreToolUse(Bash)에서 git merge 명령 감지 시 실행
# git -C <path> merge ... 패턴도 감지

CMD="$CLAUDE_BASH_COMMAND"

# git merge 명령이 아니면 통과 (git -C <path> merge 포함)
echo "$CMD" | grep -qE 'git\s+(-C\s+\S+\s+)?merge' || exit 0

# git -C <path>가 있으면 해당 경로 기준, 없으면 현재 디렉토리 기준
REPO_DIR=$(echo "$CMD" | sed -n 's/.*git\s\+-C\s\+"\?\([^"[:space:]]*\)"\?.*/\1/p')
REPO_DIR="${REPO_DIR:-.}"

# 워크트리의 .jira-context.json 탐색 (현재 디렉토리 우선 → REPO_DIR)
CONTEXT=""
if [ -f ".jira-context.json" ]; then
  CONTEXT=".jira-context.json"
elif [ -f "$REPO_DIR/.jira-context.json" ]; then
  CONTEXT="$REPO_DIR/.jira-context.json"
fi

# .jira-context.json이 없으면 통과 (jira-task 워크플로 밖)
[ -n "$CONTEXT" ] || exit 0

BASE=$(python3 -c "import json; print(json.load(open('$CONTEXT'))['baseBranch'])" 2>/dev/null)
CURRENT=$(git -C "$REPO_DIR" branch --show-current 2>/dev/null)

if [ -n "$BASE" ] && [ "$CURRENT" != "$BASE" ]; then
  echo "BLOCKED: current branch($CURRENT) != baseBranch($BASE). Checkout $BASE first."
  exit 1
fi
