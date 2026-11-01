# development-setting

AI(Claude Code 등)로 개발할 때 참조하는 **베이스 프로젝트 + 규칙** 저장소.
규칙은 `E:\Work`의 기존 프로젝트(pickup-lounge, lg-aidv, coba, ces2026 등)에서 추출했다.

## 구조

```
development-setting/
  CLAUDE.md            # @AGENTS.md 참조만
  AGENTS.md            # 공통 규칙 (언어·프로세스·토큰·데이터 경로·git)
  Unity/               # Unity 베이스 프로젝트를 여기에 넣는다
    AGENTS.md          # Unity 규칙 (MCP, 구조, 컨벤션, 체크리스트)
    CLAUDE.md          # @AGENTS.md 참조
    PROJECT_CONTEXT.md # 프로젝트 배경 템플릿
    .gitignore  .gitattributes
    Assets/App/Config/config.sample.json
  Unreal/              # Unreal 베이스 프로젝트를 여기에 넣는다
    AGENTS.md          # Unreal 규칙
    CLAUDE.md          # @AGENTS.md 참조
    PROJECT_CONTEXT.md
    .gitignore  .mcp.json.sample
  Python/              # Python 베이스 프로젝트 (CLI / GUI / FastAPI 서버)
    AGENTS.md          # Python 규칙 (구조, 설정 우선순위, 외부 연동, ruff, pytest)
    CLAUDE.md          # @AGENTS.md 참조
    PROJECT_CONTEXT.md
    .gitignore  pyproject.toml  run.bat
  Flutter/             # Flutter 베이스 프로젝트 (태블릿·데스크톱 현장 앱)
    AGENTS.md          # Flutter 규칙 (기존 프로젝트가 없어 관례 기반, 첫 프로젝트 후 갱신)
    CLAUDE.md          # @AGENTS.md 참조
    PROJECT_CONTEXT.md
    .gitignore  analysis_options.yaml
```

## 사용법

1. **베이스 프로젝트 넣기**: Unity 프로젝트 루트(`Assets/`, `Packages/`, `ProjectSettings/`)를 `Unity/`에,
   Unreal은 `Unreal/<ProjectName>/` 아래에 `.uproject`가 오도록 넣는다. 템플릿 파일들과 같은 층에 둔다.
2. **새 프로젝트 시작**: `Unity/` 또는 `Unreal/` 폴더를 통째로 복사한다.
   - `PROJECT_CONTEXT.md`의 괄호를 채운다.
   - Unreal은 `.mcp.json.sample` → `.mcp.json`으로 복사하고 `.uproject` 경로를 채운다.
   - Unity는 `config.sample.json`의 `{productName}`을 실제 이름으로 바꾼다.
   - Python은 `pyproject.toml`의 `name`과 `run.bat`의 기본 인자를 바꾸고 `.venv`를 만든다.
   - Flutter는 `flutter create`로 만든 프로젝트 위에 템플릿 파일을 덮어 넣는다.
3. **AI로 개발**: 해당 폴더에서 Claude Code를 열면 `CLAUDE.md` → `AGENTS.md`가 자동으로 읽힌다.
   다른 AI 도구(Codex, Cursor 등)는 `AGENTS.md`를 직접 읽는다.

## 규칙 수정

- 공통 규칙은 루트 `AGENTS.md`, 엔진별 규칙은 각 폴더의 `AGENTS.md`만 고친다.
- `CLAUDE.md`에는 규칙을 적지 않는다. 참조와 한두 줄 메모만.
- 엔진별 `AGENTS.md` 상단의 "공통 요약"은 복사된 프로젝트가 단독으로도 동작하도록 둔 것이다. 루트 규칙을 바꾸면 요약도 맞춘다.
