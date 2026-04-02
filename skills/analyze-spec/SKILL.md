---
name: analyze-spec
description: 기획서/스토리보드를 분석하여 AI 친화적 MD 문서로 변환. PPT, Google Slides, Google Docs, Google Sheets, Confluence 지원. Use /analyze-spec to convert planning docs to structured markdown.
user-invocable: true
disable-model-invocation: false
allowed-tools: Bash, Read, Write, Glob, Grep, Agent, AskUserQuestion, mcp__google-drive__downloadFile, mcp__google-drive__uploadFile, mcp__google-drive__deleteItem, mcp__google-drive__getGoogleSlidesContent, mcp__google-drive__exportSlideThumbnail, mcp__google-drive__getGoogleDocContent, mcp__google-drive__getDocumentInfo, mcp__google-docs__readDocument, mcp__google-docs__readSpreadsheet, mcp__google-docs__getSpreadsheetInfo, mcp__atlassian__jira_create_issue, mcp__atlassian__jira_update_issue, mcp__atlassian__jira_get_issue, mcp__atlassian__jira_search, WebFetch
---

# 기획서/스토리보드 분석

기획서, 스토리보드, IF 스펙 문서를 분석하여 AI가 구현 시 참조할 수 있는 구조화된 MD 문서를 생성한다.
설정은 `config.yaml`의 `spec`, `jira` 섹션을 참조한다.

## Usage

```
/analyze-spec                          # 대화형으로 파일 경로/URL 입력
/analyze-spec /path/to/file.pptx       # 로컬 PPT 파일
/analyze-spec https://docs.google.com/presentation/d/xxx/edit   # Google Slides
/analyze-spec https://docs.google.com/document/d/xxx/edit       # Google Docs
/analyze-spec https://{domain}.atlassian.net/wiki/spaces/XX/pages/123  # Confluence
/analyze-spec check-schema             # 기분석된 spec MD vs DB 스키마 대조
/analyze-spec check-schema docs/specs/xxx.md   # 특정 spec MD 지정
/analyze-spec sync-jira                # 산출물을 Jira 티켓에 연결 → jira-task 핸드오프
/analyze-spec sync-jira docs/specs/xxx.md      # 특정 spec MD 지정
```

## 워크플로

```
/analyze-spec {url}        →  spec MD 생성
/analyze-spec check-schema →  DB 스키마 대조 (optional)
/analyze-spec sync-jira    →  Jira 티켓 생성/연결 + 산출물 첨부
                           →  /jira-task start {KEY} 안내
```

## Arguments Routing

Parse `$ARGUMENTS`:
- `check-schema` → `references/check-schema.md` 실행
- `sync-jira` → `references/sync-jira.md` 실행
- 그 외 (URL, 파일 경로, 없음) → `references/analyze.md` 실행

## 제약사항

| 항목 | 필요 조건 |
|------|-----------|
| pptx 텍스트 추출 | `python-pptx` (`pip install python-pptx`) |
| PDF 변환 | `LibreOffice` (`brew install --cask libreoffice`) |
| Google Slides/Docs/Sheets | `google-docs`, `google-drive` MCP 서버 |
| Confluence | curl + atlassian MCP 환경변수 (CONFLUENCE_TOKEN) |
| Jira 연동 | `atlassian` MCP 서버 (jira_create_issue, jira_update_issue) |
| check-schema | DB 스키마 파일 (ERD/DDL) 접근 |
| 이미지 전용 슬라이드 | 텍스트 추출 불가 → 시각 분석에만 의존, `[확인 필요]` 태그 |
