---
name: db
description: 로컬 인프라(DB, 캐시 등) 관리. Use /db to start, stop, migrate, or check status.
user-invocable: true
disable-model-invocation: false
allowed-tools: Bash, Read
---

# Infrastructure Manager

프로젝트의 로컬 인프라(DB, 캐시, 스토리지 등)를 관리한다.
환경 설정은 `config.yaml`의 `infra` 섹션을 참조한다.

## Usage

```
/db up                # 전체 서비스 시작
/db down              # 서비스 중지
/db reset             # 초기화 후 재시작 (+ 마이그레이션)
/db migrate           # 마이그레이션만 실행
/db status            # 서비스 상태 확인
```

## Arguments Parsing

Parse `$ARGUMENTS`:
- `up` → start all services
- `down` → stop all services
- `reset` → stop with volumes, restart, migrate
- `migrate` → run migration only
- `status` → check service status

## Configuration

이 스킬은 `.claude/skills/config.yaml`의 `infra` 섹션을 읽어 동작한다.
config.yaml이 없으면 사용자에게 설정 안내 후 중단.

### 필수 설정

```yaml
infra:
  type: docker | remote | local | none
  working_dir: "/path/to/infra"
  commands:
    up: "..."
    down: "..."
    reset: "..."
    status: "..."
  services:
    - name: database
      host: localhost
      port: 5432
      health_check: "..."
  migration:
    tool: flyway | liquibase | prisma | none
    command: "..."
```

## Execution

### Step 0: 설정 로드

config.yaml에서 `infra` 섹션을 읽는다. Read 도구로 `.claude/skills/config.yaml` 파일을 읽어 파싱.

### `up` — 서비스 시작

1. `infra.working_dir`로 이동
2. `infra.commands.up` 실행
3. 각 `infra.services`의 `health_check` 실행하여 상태 확인
4. 결과 테이블 출력

### `down` — 서비스 중지

1. `infra.commands.down` 실행

### `reset` — 초기화 후 재시작

1. `infra.commands.reset` 실행
2. 서비스 헬스체크 통과 대기
3. `infra.migration.command` 실행 (migration.tool이 none이 아닌 경우)

### `migrate` — 마이그레이션만

1. 서비스 실행 중인지 확인
2. `infra.migration.command` 실행

### `status` — 상태 확인

1. `infra.commands.status` 실행 (있을 경우)
2. 각 `infra.services`의 `health_check` 실행

## Result Report

| 서비스 | 호스트:포트 | 상태 |
|--------|-----------|------|
| {name} | {host}:{port} | ✅/❌ |

## Error Handling

- config.yaml 없음 → 설정 안내 후 중단
- infra.type이 none → "인프라 관리 비활성화" 안내
- 명령어 실행 실패 → 에러 로그 출력
- 헬스체크 실패 → 서비스별 상태 보고
