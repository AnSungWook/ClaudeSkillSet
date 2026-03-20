---
name: analyze-spec
description: 기획서/스토리보드를 분석하여 AI 친화적 MD 문서로 변환. PPT, Google Slides, Google Docs, Google Sheets, Confluence 지원. Use /analyze-spec to convert planning docs to structured markdown.
user-invocable: true
disable-model-invocation: false
allowed-tools: Bash, Read, Write, Glob, Grep, Agent, AskUserQuestion, mcp__google-drive__downloadFile, mcp__google-drive__uploadFile, mcp__google-drive__deleteItem, mcp__google-drive__getGoogleSlidesContent, mcp__google-drive__exportSlideThumbnail, mcp__google-drive__getGoogleDocContent, mcp__google-drive__getDocumentInfo, mcp__google-docs__readDocument, mcp__google-docs__readSpreadsheet, mcp__google-docs__getSpreadsheetInfo, mcp__atlassian__jira_create_issue, mcp__atlassian__jira_update_issue, mcp__atlassian__jira_get_issue, WebFetch
---

# 기획서/스토리보드 → 구조화 MD 변환

기획서, 스토리보드, IF 스펙 문서를 분석하여 AI가 구현 시 참조할 수 있는 구조화된 MD 문서를 생성한다.
설정은 `config.yaml`의 `spec`, `jira` 섹션을 참조한다.

## Usage

```
/analyze-spec                          # 대화형으로 파일 경로/URL 입력
/analyze-spec /path/to/file.pptx       # 로컬 PPT 파일
/analyze-spec https://docs.google.com/presentation/d/xxx/edit   # Google Slides
/analyze-spec https://docs.google.com/document/d/xxx/edit       # Google Docs
/analyze-spec https://confluence.example.com/wiki/spaces/XX/pages/123  # Confluence
```

---

## Step 0: 입력 확인

인자가 없으면 AskUserQuestion으로 질문:
- **질문**: "분석할 문서의 파일 경로 또는 URL을 입력해주세요."
- **안내**: "지원 형식: 로컬 PPT/PPTX, Google Slides, Google Docs, Google Sheets, Confluence 페이지"

---

## Step 1: 입력 타입 감지 및 소스 준비

### 타입 판별

| 패턴 | 타입 |
|------|------|
| `*.pptx` / `*.ppt` (로컬 경로) | `local-pptx` |
| `docs.google.com/presentation/d/{ID}` | `google-slides` |
| `docs.google.com/document/d/{ID}` | `google-docs` |
| `docs.google.com/spreadsheets/d/{ID}` | `google-sheets` |
| `atlassian.net/wiki/` 또는 `confluence` 포함 URL | `confluence` |

### 소스별 준비 작업

#### local-pptx
- 경로 그대로 사용
- LibreOffice로 PDF 변환: `soffice --headless --convert-to pdf --outdir /tmp {pptx_path}`

#### google-slides
1. URL에서 presentation ID 추출 (`/d/{ID}/`)
2. `mcp__google-drive__downloadFile`로 `/tmp/_spec_{timestamp}.pptx`에 다운로드
3. LibreOffice로 PDF 변환

#### google-docs
1. URL에서 document ID 추출 (`/d/{ID}/`)
2. `mcp__google-docs__readDocument` (format=markdown)로 텍스트 추출
3. 결과를 `/tmp/_spec_{timestamp}_docs.md`에 저장

#### google-sheets
1. URL에서 spreadsheet ID 추출
2. `mcp__google-docs__getSpreadsheetInfo`로 시트 목록 확인
3. 각 시트를 `mcp__google-docs__readSpreadsheet`로 읽기
4. 결과를 `/tmp/_spec_{timestamp}_sheets.md`에 저장

#### confluence
1. URL에서 page ID 추출 (`/pages/{ID}`)
2. config.yaml의 `spec.confluence`에서 URL/username 읽기
3. curl로 REST API v2 호출:
   ```bash
   curl -s -u "{username}:{token}" \
     "{confluence_url}/api/v2/pages/{pageId}?body-format=atlas_doc_format"
   ```
4. 하위 페이지 존재 시 children API로 재귀 추출
5. 결과를 `/tmp/_spec_{timestamp}_confluence.md`에 저장

---

## Step 2: 병렬 2-Agent 분석 (모든 소스 공통)

**입력 형식과 무관하게, 항상 동일한 분석 작업을 수행하는 두 Agent를 병렬로 실행한다.**
같은 소스를 두 번 독립 분석하면 한쪽이 놓친 정보를 다른 쪽이 잡을 수 있다.

### 소스 타입별 Agent 추출 방법

#### PPT/Slides (local-pptx, google-slides)

**1) 텍스트 추출 (python-pptx)**

```python
from pptx import Presentation
prs = Presentation('{pptx_path}')
for slide_idx, slide in enumerate(prs.slides):
    for shape in slide.shapes:
        if shape.has_table:
            # 모든 셀 데이터 추출 — Description Table은 정확한 명세
        elif shape.has_text_frame:
            # 텍스트 추출
```

**2) 이미지 시각 분석 (PDF)**
Read 도구로 PDF를 5페이지씩 읽어 시각 분석.

**3) 슬라이드 그룹핑**
- 목차 슬라이드 → 섹션 구분자
- "다음 페이지에 이어서" → 동일 화면 연속
- 동일 화면코드 → 같은 화면

#### Google Docs / Sheets / Confluence

준비 단계에서 저장한 임시 파일을 Read로 읽고 분석.

### Agent 출력 MD 구조

```markdown
# {화면명 또는 문서 제목}

## 개요
## 화면 정보 (해당 시)
## 화면 레이아웃 (해당 시)
## 기능 명세
## 비즈니스 규칙
## 연관 화면 / API
```

### Agent 핵심 규칙

- **추측 금지** — 소스에 없는 정보를 만들지 마라
- 불확실하면 `[확인 필요]`로 표기
- 화면코드, 팝업 코드, API 경로는 반드시 포함
- 유효성 검증 알럿 메시지는 원문 그대로

---

## Step 3: 병합

1. **합집합**: A에만 있는 정보, B에만 있는 정보 모두 포함
2. **충돌 시**: 더 구체적인 쪽 채택
3. **불일치**: `[검수 필요]` 태그 + 양쪽 내용 모두 표기
4. **한쪽만 존재**: `[검수 필요]` 태그 부착

---

## Step 4: 사용자 검수

병합된 MD를 사용자에게 보여주고 검수 요청.

- "확인 완료" → Step 5
- "수정 필요" → 피드백 반영 후 다시 검수

---

## Step 5: 저장 및 Jira 연동

### 5-1. 로컬 저장

config.yaml의 `spec.output_dir`에 저장.
기본값: `docs/specs/{feature-name}.md`

### 5-2. Jira 연동 (config.yaml의 jira.enabled가 true인 경우만)

AskUserQuestion:
- **옵션**: 기존 티켓에 추가 / 새 티켓 생성 / 안 함

#### 기존 티켓에 추가
- 티켓 KEY 입력 → description에 MD 추가 + 파일 첨부

#### 새 티켓 생성
- `jira_create_issue`로 생성 (프로젝트: `jira.project_key`)
- description에 MD 전체 + 파일 첨부

---

## Step 6: 정리 및 결과 보고

임시 파일 삭제 + 결과 요약.

## 제약사항

| 항목 | 필요 조건 |
|------|-----------|
| pptx 텍스트 추출 | `python-pptx` (`pip install python-pptx`) |
| PDF 변환 | `LibreOffice` (`brew install --cask libreoffice`) |
| Google 소스 | `google-docs`, `google-drive` MCP 서버 |
| Confluence | curl + 인증 정보 (config.yaml) |
| Jira 연동 | `atlassian` MCP 서버 |
