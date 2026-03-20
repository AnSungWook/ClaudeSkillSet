---
name: server
description: 백엔드 서비스 기동/중지/빌드/상태 관리. Use /server to start, stop, build, or check status.
user-invocable: true
disable-model-invocation: false
allowed-tools: Bash, Read, Glob, Grep, AskUserQuestion
---

# Server Manager

백엔드 서비스를 로컬에서 기동/중지/빌드/상태 확인한다.
환경 설정은 `config.yaml`의 `server` 섹션을 참조한다.

## Usage

```
/server {module} up        # 서비스 기동
/server {module} down      # 서비스 중지
/server {module} restart   # 재기동
/server {module} build     # 빌드 + 테스트 + API 문서 생성
/server status             # 전체 상태 확인
```

## Arguments Parsing

Parse `$ARGUMENTS`:
- `{module} up` → start service
- `{module} down` → stop service
- `{module} restart` → stop then start
- `{module} build` → build + test + docs
- `status` → check all services

## Configuration

이 스킬은 `.claude/skills/config.yaml`의 `server` 섹션을 읽어 동작한다.

### 필수 설정

```yaml
server:
  pre_tasks:
    - name: "코드 생성"
      command: "..."
      skip_for: []
  jvm_opts: ""
  spring_profile: local
  modules:
    - name: api
      port: 8080
      path: "/path/to/module"
      start: "..."
      stop: "..."
      build: "..."
      health: "http://localhost:8080/actuator/health"
      docs:
        rest_docs: "..."
        swagger: "..."
  log_dir: /tmp
```

## Execution

### Step 0: 설정 로드

config.yaml에서 `server` 섹션을 읽고, `$ARGUMENTS`에서 지정한 module을 `server.modules`에서 찾는다.
모듈을 찾을 수 없으면 사용 가능한 모듈 목록을 보여주고 중단.

### `up` — 서비스 기동

#### 1. 포트 점유 확인

```bash
lsof -i :{module.port} -sTCP:LISTEN >/dev/null 2>&1
```

이미 점유 중이면 안내 후 건너뛴다.

#### 2. 인프라 확인

`/db status`를 통해 인프라 서비스가 실행 중인지 확인.
미실행 시: `⚠️ 인프라 미실행. /db up 을 먼저 실행하세요.` → 중단

#### 3. 사전 작업 (pre_tasks)

`server.pre_tasks` 목록을 순회하며 실행.
해당 모듈이 `skip_for`에 포함되어 있으면 건너뛴다.

```bash
cd {module.path}
{pre_task.command}
```

실패 시 로그 출력 후 중단.

#### 4. 서비스 기동

```bash
cd {module.path}
nohup {module.start} > {log_dir}/afnbp-{module.name}-boot.log 2>&1 &
echo $! > {log_dir}/afnbp-{module.name}-boot.pid
```

`server.jvm_opts`가 있으면 start 명령에 포함.

#### 5. 헬스체크

```bash
for i in $(seq 1 40); do
    if curl -sf {module.health} > /dev/null 2>&1; then
        echo "✅ {module.name} healthy on port {module.port}"
        break
    fi
    sleep 3
done
```

타임아웃 시: `tail -50 {log_dir}/afnbp-{module.name}-boot.log`

### `down` — 서비스 중지

```bash
{module.stop}
sleep 2
```

### `restart` — 재기동

`down` → `up` 순차 실행.

### `build` — 빌드 + 테스트 + API 문서 생성

#### 1. 인프라 확인

DB 연결이 필요한 빌드/테스트를 위해 인프라 상태 확인.
미실행 시 중단.

#### 2. 사전 작업 (pre_tasks)

`up`과 동일하게 `server.pre_tasks` 실행.

#### 3. 빌드 + 테스트

```bash
cd {module.path}
{module.build} 2>&1 | tee {log_dir}/afnbp-{module.name}-build.log
```

빌드 실패 시:
- 에러 라인 추출하여 보고
- 컴파일 에러 / 테스트 실패 구분
- **다음 단계 진행하지 않음**

#### 4. REST Docs 생성 (설정된 경우)

`module.docs.rest_docs`가 정의되어 있으면 실행:

```bash
cd {module.path}
{module.docs.rest_docs} 2>&1 | tee {log_dir}/afnbp-{module.name}-restdocs.log
```

미정의 시 건너뛴다.
실패 시 에러 보고, 다음 단계 계속.

#### 5. Swagger 스펙 생성 (설정된 경우)

`module.docs.swagger`가 정의되어 있으면 실행:

```bash
cd {module.path}
{module.docs.swagger} 2>&1 | tee {log_dir}/afnbp-{module.name}-swagger.log
```

미정의 시 건너뛴다.

#### 6. 결과 리포트

```
## 빌드 결과: {module.name}

| 단계 | 결과 | 비고 |
|------|------|------|
| 사전 작업 | ✅/❌/⏭️ | |
| 빌드 (컴파일) | ✅/❌ | |
| 테스트 | ✅/❌ | {통과}/{전체} 건 |
| REST Docs | ✅/❌/⏭️ | 미설정 시 스킵 |
| Swagger 스펙 | ✅/❌/⏭️ | 미설정 시 스킵 |
```

### `status` — 전체 상태 확인

`server.modules` 전체를 순회하며 포트/헬스체크 확인.

| 서비스 | 포트 | 상태 | 헬스 |
|--------|------|------|------|
| {name} | {port} | ✅ UP / ❌ DOWN | |

## Error Handling

- config.yaml 없음 → 설정 안내 후 중단
- 모듈 못 찾음 → 사용 가능한 모듈 목록 출력
- 인프라 미실행 → `/db up` 안내 후 중단
- 빌드 실패 → 에러 라인 추출, REST Docs/Swagger 스킵
- 헬스체크 타임아웃 → 로그 마지막 50줄 출력
