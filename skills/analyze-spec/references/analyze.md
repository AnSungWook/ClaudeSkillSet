# 기획서/스토리보드 분석 상세

## Step 0: 입력 확인

인자가 없으면 AskUserQuestion: "분석할 문서의 파일 경로 또는 URL을 입력해주세요."

## Step 1: 입력 타입 감지 및 소스 준비

| 패턴 | 타입 |
|------|------|
| `*.pptx` / `*.ppt` | `local-pptx` |
| `docs.google.com/presentation/d/{ID}` | `google-slides` |
| `docs.google.com/document/d/{ID}` | `google-docs` |
| `docs.google.com/spreadsheets/d/{ID}` | `google-sheets` |
| `atlassian.net/wiki/` | `confluence` |

### local-pptx
LibreOffice로 PDF 변환: `soffice --headless --convert-to pdf --outdir /tmp {path}`

### google-slides
`mcp__google-drive__downloadFile`로 pptx 다운로드 → LibreOffice PDF 변환

### google-docs
`mcp__google-docs__readDocument`(format=markdown) → `/tmp/_spec_{ts}_docs.md`

### google-sheets
`mcp__google-docs__getSpreadsheetInfo` → 각 시트 `readSpreadsheet` → `/tmp/_spec_{ts}_sheets.md`

### confluence

**사전 확인:** `.mcp.json`에 `atlassian` MCP 서버 등록 여부 확인. 없으면 사용자에게 안내.

1. URL에서 page ID 추출 (`/pages/{ID}`)
2. curl로 `body-format=storage` 호출 (storage가 HTML 본문 포함, atlas_doc_format은 매크로만 반환하는 경우 있음)
3. 하위 페이지 존재 시 children API로 재귀 추출
4. **각 페이지를 개별 JSON 파일로 저장** (`/tmp/_conf_page_{pageId}.json`) 후 python으로 일괄 파싱
   - curl pipe + python heredoc 충돌 방지를 위해 반드시 파일 저장 → 별도 파싱 2단계 분리
   - bash for loop: `for ID in id1 id2 id3` 형태 사용 (변수에 담으면 하나의 문자열 처리됨)
5. 파싱 결과를 `/tmp/_spec_{ts}_confluence.md`에 통합

---

## Step 2: 병렬 2-Agent 분석

같은 소스를 두 Agent가 독립 분석 → 한쪽이 놓친 정보를 다른 쪽이 잡음.

### PPT/Slides: 텍스트(python-pptx) + 시각(PDF 5페이지씩 Read)
### Google Docs/Sheets/Confluence: MD 파일 Read 후 분석

### Agent 출력 MD 구조

```markdown
# {제목}
## 개요
## 화면 정보 / 화면 레이아웃
## 기능 명세 (조회 조건, 조회 결과)
## 비즈니스 규칙
## 연관 화면 / API
```

### 핵심 규칙
- **추측 금지** — 소스에 없는 정보를 만들지 마라
- 불확실하면 `[확인 필요]`로 표기
- Description Table 내용은 정확한 명세

---

## Step 3: 병합 + 신뢰도 산정

1. **합집합**: A/B 모두 포함
2. **충돌**: 더 구체적인 쪽 채택
3. **불일치/한쪽만 존재**: `[검수 필요]` 태그

### (1) 신뢰도 표 (필수)

```markdown
> **분석 신뢰도: {종합}%**
> | 항목 | 신뢰도 | 근거 |
> |------|--------|------|
> | {소스} | **{N}%** | {추출 방식} |
> | 감점 | **-{N}%** | [확인 필요] {N}건 |
> | 상태 | **DRAFT** | |
```

**기준:** PPT+PDF=85%, Confluence/Docs=90%, 이미지전용=60%, Sheets=88%. [확인 필요] -1%/건, 불일치 수정 -2%/건.

### (2) 검수 집중 구간 가이드 (필수)

```markdown
> **검수 집중 구간**
> | 우선순위 | 구간 | 이유 |
> | 높음 | ... | 원문 누락, 충돌, 비즈니스 영향 |
> | 중간 | ... | 모호, 외부 참조, 네이밍 불일치 |
> | 낮음 | ... | 포맷, 미정 값 |
```

---

## Step 4: 사용자 검수

AskUserQuestion: "분석 결과를 확인해주세요. 수정할 부분이 있나요?"
수정 필요 시 피드백 반영 → 재검수. "확인 완료"까지 반복.

## Step 5: 로컬 저장

기본값: `docs/specs/{feature-name}_DRAFT.md`. 검수 완료 시 `_DRAFT` 제거.

## Step 6: 정리 및 결과 보고

임시 파일(`/tmp/_spec_*`, `/tmp/_conf_page_*`) 삭제.

```
## 분석 완료
- **소스**: {URL}
- **신뢰도**: {N}%
- **[검수 필요]**: {N}건
- **저장 경로**: `{path}`

다음: /analyze-spec check-schema | /analyze-spec sync-jira
```
