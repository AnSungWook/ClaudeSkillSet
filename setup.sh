#!/bin/bash
# =============================================================================
# Claude Skills Kit - 자동 설치 스크립트
# =============================================================================
# 프로젝트 루트에서 실행하세요: bash /path/to/setup.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(pwd)"
SKILLS_DIR="$PROJECT_ROOT/.claude/skills"

echo "=========================================="
echo " Claude Skills Kit Installer"
echo "=========================================="
echo ""
echo "프로젝트 루트: $PROJECT_ROOT"
echo "스킬 설치 경로: $SKILLS_DIR"
echo ""

# 확인
read -p "이 위치에 설치하시겠습니까? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "설치를 취소합니다."
    exit 0
fi

# .claude/skills 디렉토리 생성
mkdir -p "$SKILLS_DIR"

# -----------------------------------------------
# 1. 공통 스킬 복사
# -----------------------------------------------
echo ""
echo "[1/5] 공통 스킬 복사 중..."

for skill_dir in "$SCRIPT_DIR/skills"/*/; do
    skill_name=$(basename "$skill_dir")

    # workflows 디렉토리는 건너뜀 (별도 처리)
    if [ "$skill_name" = "workflows" ]; then
        continue
    fi

    target="$SKILLS_DIR/$skill_name"

    if [ -d "$target" ]; then
        read -p "  $skill_name 이미 존재합니다. 덮어쓸까요? (y/N): " overwrite
        if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
            echo "  → $skill_name 건너뜀"
            continue
        fi
    fi

    cp -r "$skill_dir" "$target"
    echo "  ✅ $skill_name"
done

# -----------------------------------------------
# 2. 워크플로우 선택 및 복사
# -----------------------------------------------
echo ""
echo "[2/5] 구현 워크플로우 선택..."
echo ""

# 사용 가능한 워크플로우 목록
# 1) skills/task/ — 범용 (이슈 트래커 없이 독립 동작)
# 2+) skills/workflows/*/ — 이슈 트래커 연동 워크플로우
WORKFLOWS_DIR="$SCRIPT_DIR/skills/workflows"
available_workflows=()
workflow_sources=()
idx=1

# standalone task 워크플로 (항상 첫 번째)
if [ -d "$SCRIPT_DIR/skills/task" ]; then
    task_skill_count=$(find "$SCRIPT_DIR/skills/task" -name "SKILL.md" | wc -l | tr -d ' ')
    echo "  $idx) task — 범용 워크플로 ($task_skill_count개 스킬, 이슈 트래커 불필요)"
    available_workflows+=("task")
    workflow_sources+=("$SCRIPT_DIR/skills/task")
    idx=$((idx + 1))
fi

# 이슈 트래커 연동 워크플로우
for wf_dir in "$WORKFLOWS_DIR"/*/; do
    [ -d "$wf_dir" ] || continue
    wf_name=$(basename "$wf_dir")
    available_workflows+=("$wf_name")
    workflow_sources+=("$wf_dir")

    skill_count=$(find "$wf_dir" -name "SKILL.md" | wc -l | tr -d ' ')
    echo "  $idx) $wf_name ($skill_count개 스킬)"
    idx=$((idx + 1))
done

echo "  0) 워크플로우 설치 안 함"
echo ""

read -p "워크플로우를 선택하세요 (번호): " wf_choice

if [[ "$wf_choice" -gt 0 && "$wf_choice" -le ${#available_workflows[@]} ]]; then
    selected_wf="${available_workflows[$((wf_choice - 1))]}"
    selected_src="${workflow_sources[$((wf_choice - 1))]}"
    target="$SKILLS_DIR/$selected_wf"

    if [ -d "$target" ]; then
        read -p "  $selected_wf 이미 존재합니다. 덮어쓸까요? (y/N): " overwrite_wf
        if [[ "$overwrite_wf" != "y" && "$overwrite_wf" != "Y" ]]; then
            echo "  → $selected_wf 건너뜀"
        else
            rm -rf "$target"
            cp -r "$selected_src" "$target"
            echo "  ✅ $selected_wf (워크플로우 설치됨)"
        fi
    else
        cp -r "$selected_src" "$target"
        echo "  ✅ $selected_wf (워크플로우 설치됨)"
    fi

    # agents/ 디렉토리도 함께 복사 (task 및 모든 워크플로에서 사용)
    if [ -d "$SCRIPT_DIR/agents" ]; then
        AGENTS_TARGET="$SKILLS_DIR/../agents"
        mkdir -p "$AGENTS_TARGET"
        cp -r "$SCRIPT_DIR/agents/"*.md "$AGENTS_TARGET/" 2>/dev/null
        echo "  ✅ agents (에이전트 설치됨)"
    fi
else
    echo "  → 워크플로우 설치 건너뜀"
    selected_wf=""
fi

# -----------------------------------------------
# 3. config.yaml 복사
# -----------------------------------------------
echo ""
echo "[3/5] 설정 파일..."

CONFIG_FILE="$SKILLS_DIR/config.yaml"
if [ -f "$CONFIG_FILE" ]; then
    read -p "  config.yaml 이미 존재합니다. 덮어쓸까요? (y/N): " overwrite_config
    if [[ "$overwrite_config" == "y" || "$overwrite_config" == "Y" ]]; then
        cp "$SCRIPT_DIR/config.yaml" "$CONFIG_FILE"
        echo "  ✅ config.yaml (덮어쓰기)"
    else
        echo "  → config.yaml 건너뜀"
    fi
else
    cp "$SCRIPT_DIR/config.yaml" "$CONFIG_FILE"
    echo "  ✅ config.yaml"
fi

# config.yaml에 프로젝트 루트 자동 설정
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|/path/to/project|$PROJECT_ROOT|g" "$CONFIG_FILE"
    # 선택한 워크플로우 반영
    if [ -n "$selected_wf" ]; then
        sed -i '' "s|type: jira-task|type: $selected_wf|g" "$CONFIG_FILE"
    fi
else
    sed -i "s|/path/to/project|$PROJECT_ROOT|g" "$CONFIG_FILE"
    if [ -n "$selected_wf" ]; then
        sed -i "s|type: jira-task|type: $selected_wf|g" "$CONFIG_FILE"
    fi
fi

# -----------------------------------------------
# 4. CLAUDE.md 템플릿
# -----------------------------------------------
echo ""
echo "[4/5] 산출물 디렉토리..."

# 산출물 디렉토리에 README 배치 (각 폴더의 용도 안내)
DOCS_TEMPLATE_DIR="$SCRIPT_DIR/templates/docs"
if [ -d "$DOCS_TEMPLATE_DIR" ]; then
    for doc_dir in "$DOCS_TEMPLATE_DIR"/*/; do
        dir_name=$(basename "$doc_dir")
        target_dir="$PROJECT_ROOT/docs/$dir_name"
        if [ ! -d "$target_dir" ]; then
            mkdir -p "$target_dir"
            cp "$doc_dir/README.md" "$target_dir/README.md" 2>/dev/null
            echo "  ✅ docs/$dir_name/ (README 포함)"
        else
            # 디렉토리는 있지만 README가 없으면 추가
            if [ ! -f "$target_dir/README.md" ] && [ -f "$doc_dir/README.md" ]; then
                cp "$doc_dir/README.md" "$target_dir/README.md"
                echo "  ✅ docs/$dir_name/README.md 추가"
            else
                echo "  → docs/$dir_name/ 이미 존재, 건너뜀"
            fi
        fi
    done
fi

# -----------------------------------------------
# 5. CLAUDE.md + task-conventions.md
# -----------------------------------------------
echo ""
echo "[5/5] CLAUDE.md..."

CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [ ! -f "$CLAUDE_MD" ]; then
    read -p "  CLAUDE.md 템플릿을 생성할까요? (y/N): " create_claude
    if [[ "$create_claude" == "y" || "$create_claude" == "Y" ]]; then
        cp "$SCRIPT_DIR/templates/CLAUDE.md.template" "$CLAUDE_MD"
        echo "  ✅ CLAUDE.md (템플릿 — 프로젝트에 맞게 수정하세요)"
    fi
else
    echo "  → CLAUDE.md 이미 존재, 건너뜀"
fi

# task-conventions.md (워크플로우 컨벤션 분리 파일)
CONVENTIONS_MD="$PROJECT_ROOT/.claude/task-conventions.md"
if [ ! -f "$CONVENTIONS_MD" ] && [ -f "$SCRIPT_DIR/templates/task-conventions.md.template" ]; then
    read -p "  task-conventions.md 템플릿을 생성할까요? (y/N): " create_conv
    if [[ "$create_conv" == "y" || "$create_conv" == "Y" ]]; then
        mkdir -p "$PROJECT_ROOT/.claude"
        cp "$SCRIPT_DIR/templates/task-conventions.md.template" "$CONVENTIONS_MD"
        echo "  ✅ .claude/task-conventions.md (phase별 컨벤션 — 프로젝트에 맞게 수정하세요)"
    fi
elif [ -f "$CONVENTIONS_MD" ]; then
    echo "  → .claude/task-conventions.md 이미 존재, 건너뜀"
fi

# -----------------------------------------------
# 완료
# -----------------------------------------------
echo ""
echo "=========================================="
echo " 설치 완료"
echo "=========================================="
echo ""
echo "설치된 스킬:"
for d in "$SKILLS_DIR"/*/; do
    [ -d "$d" ] && echo "  - $(basename "$d")"
done
echo ""
echo "다음 단계:"
echo "  1. $CONFIG_FILE 수정"
echo "     - project.root, server.modules, infra 등"
if [ "$selected_wf" = "jira-task" ]; then
echo "     - jira.enabled: true, jira.project_key 설정"
elif [ "$selected_wf" = "task" ]; then
echo "     - workflow.type: task 확인"
echo ""
echo "  📖 Task 워크플로 사용법: docs/GUIDE-task-workflow.md"
fi
echo ""
echo "  2. CLAUDE.md 작성 (프로젝트 규칙)"
echo "     - 기술 스택, 핵심 패턴, 워크플로우 컨벤션 등"
echo ""
echo "  3. (선택) MCP 서버 등록"
echo "     - Jira: claude mcp add atlassian ..."
echo "     - Google: .mcp.json에 google-docs, google-drive 추가"
echo ""
echo "  4. (선택) 필수 도구 설치"
echo "     - pip install python-pptx"
echo "     - brew install --cask libreoffice"
