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

# 스킬 복사
echo ""
echo "스킬 복사 중..."

for skill_dir in "$SCRIPT_DIR/skills"/*/; do
    skill_name=$(basename "$skill_dir")
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

# config.yaml 복사
CONFIG_FILE="$SKILLS_DIR/config.yaml"
if [ -f "$CONFIG_FILE" ]; then
    read -p "config.yaml 이미 존재합니다. 덮어쓸까요? (y/N): " overwrite_config
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

# CLAUDE.md 템플릿 복사
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [ ! -f "$CLAUDE_MD" ]; then
    read -p "CLAUDE.md 템플릿을 생성할까요? (y/N): " create_claude
    if [[ "$create_claude" == "y" || "$create_claude" == "Y" ]]; then
        cp "$SCRIPT_DIR/templates/CLAUDE.md.template" "$CLAUDE_MD"
        echo "  ✅ CLAUDE.md (템플릿 생성 — 프로젝트에 맞게 수정하세요)"
    fi
else
    echo "  → CLAUDE.md 이미 존재, 건너뜀"
fi

# config.yaml에 프로젝트 루트 자동 설정
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|/path/to/project|$PROJECT_ROOT|g" "$CONFIG_FILE"
else
    sed -i "s|/path/to/project|$PROJECT_ROOT|g" "$CONFIG_FILE"
fi

echo ""
echo "=========================================="
echo " 설치 완료"
echo "=========================================="
echo ""
echo "다음 단계:"
echo "  1. $CONFIG_FILE 을 프로젝트에 맞게 수정하세요"
echo "     - server.modules: 서비스 모듈 정의"
echo "     - infra: 인프라 환경 설정"
echo "     - jira: Jira 연동 설정 (선택)"
echo ""
echo "  2. 필요한 MCP 서버를 등록하세요:"
echo "     - Jira: claude mcp add atlassian ..."
echo "     - Google: .mcp.json에 google-docs, google-drive 추가"
echo ""
echo "  3. 필수 도구를 설치하세요:"
echo "     - pip install python-pptx (analyze-spec용)"
echo "     - brew install --cask libreoffice (analyze-spec용)"
echo ""
echo "사용 예시:"
echo "  /analyze-spec /path/to/storyboard.pptx"
echo "  /server api build"
echo "  /e2e-test api 옵션그룹목록"
echo "  /jira-task start PROJ-123"
