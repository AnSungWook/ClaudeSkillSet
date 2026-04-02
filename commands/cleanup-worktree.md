현재 워크트리를 정리해줘. 아래 순서대로 진행:

## 1. 현재 워크트리 정보 수집

```bash
WORKTREE_PATH=$(pwd)
REPO_ROOT=$(git worktree list | head -1 | awk '{print $1}')
BRANCH=$(git branch --show-current)
TASK_ID=$(basename "$WORKTREE_PATH")
```

`.jira-context.json`이 있으면 읽어서 taskId, baseBranch 확인.

## 2. 미커밋 변경사항 확인

`git status --porcelain` 결과가 있으면 **경고하고 사용자 확인** 후 진행.

## 3. MCP 설정 정리

`~/.claude.json`에서 이 워크트리 경로의 mcpServers 제거:

```bash
WORKTREE_PATH="$(pwd)" python3 << 'PYEOF'
import json, os
claude_json = os.path.expanduser("~/.claude.json")
with open(claude_json, "r") as f:
    data = json.load(f)
wt = os.environ["WORKTREE_PATH"].replace("\\", "/").rstrip("/")
projects = data.get("projects", {})
for k in list(projects.keys()):
    if k.replace("\\", "/").rstrip("/") == wt:
        if isinstance(projects[k], dict):
            projects[k].pop("mcpServers", None)
            print(f"MCP config removed: {k}")
        break
else:
    print("No MCP entry found, skipping")
with open(claude_json, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
PYEOF
```

## 4. 삭제 명령 클립보드 복사

macOS:
```bash
echo "git worktree remove \"$WORKTREE_PATH\" --force && echo 'worktree removed'" | pbcopy
```

Linux:
```bash
echo "git worktree remove \"$WORKTREE_PATH\" --force && echo 'worktree removed'" | xclip -selection clipboard 2>/dev/null || echo "(클립보드 복사 실패 — 아래 명령을 직접 실행하세요)"
```

## 5. 완료 안내

```
워크트리 정리 준비 완료

- 워크트리: {WORKTREE_PATH}
- 브랜치: {BRANCH}
- MCP 설정: 제거됨

클립보드에 삭제 명령이 복사되었습니다.
이 세션을 닫고 터미널에서 붙여넣기 하세요.

브랜치(feature/{TASK_ID})는 삭제하지 않습니다. PR 완료 후 삭제하세요.
```
