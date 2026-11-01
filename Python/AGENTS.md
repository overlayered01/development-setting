# Python 프로젝트 규칙 (AGENTS.md)

공통 규칙은 상위 `../AGENTS.md`. 이 파일은 Python 전용이다.
프로젝트를 다른 곳에 복사하면 아래 **공통 요약**만으로도 동작하도록 핵심을 중복해 둔다.

## 공통 요약

- 답변·커밋 메시지·로그 문구는 한국어. 코드 식별자는 영어.
- 작업 전 플랜 → 확인 → 실행. 커밋은 명시적 요청 시에만.
- 배경·결정 사항은 `PROJECT_CONTEXT.md` 참고. 계약 문서(`docs/*_contract.md`)가 코드보다 우선.
- 수치·포트·경로 하드코딩 금지. `config.json` 또는 환경 변수.
- 런타임 설정은 `C:\ezwith\data\{project-name}\config.json`. 없으면 코드의 기본값으로 생성.
- 작업 종료 전 README·AGENTS.md가 실제와 다른지 확인하고 갱신.

## 토큰 절약 (읽지 않는 경로)

- `.venv*/`, `venv/`, `site-packages/`, `__pycache__/`, `.pytest_cache/`, `.ruff_cache/`, `.mypy_cache/`
- `artifacts/`, `.cache/`, `out/`, `outputs/`, `logs/` (모델·산출물·로그)
- SDK·NumPy 등 벤더 라이선스 Markdown, `knowledge/**`·`personas/**` 같은 RAG 데이터는 그 내용이 목적일 때만.
- `README.md`는 설치·API·환경 변수 등 특정 heading이 필요할 때만 일부를 읽는다.
- `history.md` 같은 대화 기록성 문서는 작업 컨텍스트로 넣지 않는다.

## 프로젝트 구조

```
xxx.python/                    # git root
  AGENTS.md  CLAUDE.md  PROJECT_CONTEXT.md  README.md
  pyproject.toml               # 의존성·pytest·ruff 설정 (requirements.txt는 호환용)
  .env.example                 # 환경 변수 샘플 (.env는 커밋 제외)
  config.sample.json           # 런타임 설정 샘플
  main.py                      # 실행 진입점 (CLI 인자 파싱만)
  run.bat / stop.bat           # 현장 실행 스크립트 (.venv 자동 선택, UTF-8)
  src/<package_name>/          # 실제 코드
    config.py                  # 설정 로드 (C:\ezwith\data\... → 기본값)
    ...
  scripts/                     # 설치·셋업·운영 보조 스크립트
  tests/                       # pytest (test_*.py, conftest.py)
  docs/                        # 계약 문서, 설계 문서
```

- 작은 유틸(단일 파일)은 `main.py` 하나로 둬도 된다. 그 이상이면 `src/` 패키지로.

## 초기 세팅 체크리스트

- Python 3.11 이상 (`requires-python`에 명시). 가상환경은 프로젝트 안 `.venv/`.
- `pyproject.toml`에 의존성·`[tool.pytest.ini_options]`(`testpaths`, `pythonpath=["src"]`)·`[tool.ruff]` 작성.
- 설치: `python -m venv .venv` → `.\.venv\Scripts\pip install -e .[dev]`
- `run.bat`: `chcp 65001`, `PYTHONUTF8=1`, `.venv\Scripts\python.exe`가 있으면 우선 사용, 인자 없으면 기본 인자.
- 서버형(FastAPI)은 `start_*.bat` / `stop_*.bat` / `status_*.bat` 세 개. PID는 `logs/*.pid`, 헬스체크는 `/api/status` 또는 `/health`.
- `.gitignore`에 `.venv`, 캐시, `logs/`, `artifacts/`, `.env`, 런타임 생성 json.

## Python 규칙

### 설정 / 실행

- 설정 우선순위: CLI 인자 > 환경 변수 > `C:\ezwith\data\{project}\config.json` > 코드 기본값.
- 환경 변수는 프로젝트 접두사 대문자(`AIDV_HUB_HOST`). `.env.example`에 전부 나열.
- 런타임 생성 파일(캘리브레이션 결과, 캐시 json)은 `config/` 또는 `C:\ezwith\data\...`에 두고 커밋하지 않는다.
- 실제 장치(Tobii, 마이크, 시리얼) 기준으로 동작한다. 장치가 없을 때 fake 데이터를 만들지 않는다. mock은 테스트와 `--mock` 플래그로만.

### 네트워크 / 외부 연동

- 다른 PC·프로그램과의 계약(포트, 토픽, 메시지 스키마 버전 `xxx.v1`)은 `docs/message_contract.md`에 두고 코드보다 우선한다.
- 상태는 TTL을 두고 stale을 명시한다. 수신 burst는 latest-wins로 한 번만 처리.
- 재시도는 같은 `request_id`로 짧은 backoff, 최대 3회. 재전송은 멱등 처리.
- 로그는 `logs/` 아래 회전 로그 (기본 8 MiB, 백업 3개). 타임라인성 로그는 `*.jsonl` 한 줄 JSON.

### 코드 스타일

- ruff: `line-length=100`, `select=["E","F","I","UP","B"]`. 타입 힌트 사용.
- 모듈은 역할별 파일로 나눈다 (`*_client.py`, `*_adapter.py`, `*_worker.py`, `*_contract.py`).
- 무거운 작업(TTS 합성, 임베딩, 모델 추론)은 별도 프로세스/worker로 분리하고 메인 프로세스를 막지 않는다.
- 캐시는 개수·용량 상한(LRU)을 둔다. 무제한 캐시 금지.
- 타이머·루프는 종료 시 먼저 정지하고 소켓·장치를 닫는다.

### 테스트

- `tests/`에 pytest. 새 런타임 동작을 추가하면 가까운 테스트를 같이 둔다.
- 테스트가 운영 로그·설정을 오염시키지 않도록 `conftest.py`에서 임시 경로를 지정한다.
- 실행: `.\.venv\Scripts\python.exe -m pytest -q`

## 자주 쓰는 확인

```powershell
git status --short
.\.venv\Scripts\python.exe -m pytest -q
.\.venv\Scripts\python.exe -m ruff check .
Get-Content C:\ezwith\data\<project>\config.json
```

서버형이면 추가로: `status_*.bat` 또는 `/api/status`, `logs/*.err.log` 마지막 50줄.
