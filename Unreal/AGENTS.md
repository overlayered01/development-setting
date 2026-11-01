# Unreal 프로젝트 규칙 (AGENTS.md)

공통 규칙은 상위 `../AGENTS.md`. 이 파일은 Unreal 전용이다.
프로젝트를 다른 곳에 복사하면 아래 **공통 요약**만으로도 동작하도록 핵심을 중복해 둔다.

## 공통 요약

- 답변·커밋 메시지·UI 문구는 한국어.
- 작업 전 플랜 → 확인 → 실행. 커밋은 명시적 요청 시에만.
- 배경·결정 사항은 `PROJECT_CONTEXT.md` 참고. 계약 문서가 코드보다 우선.
- 수치 하드코딩 금지. config / `UPROPERTY(EditAnywhere)` / DataAsset으로 뺀다.
- 런타임 설정·콘텐츠는 `C:\ezwith\data\{ProjectName}\`.
- 작업 종료 전 README·AGENTS.md가 실제와 다른지 확인하고 갱신.

## 토큰 절약 (읽지 않는 경로)

- `Binaries/`, `Intermediate/`, `Saved/`, `DerivedDataCache/`, `Build/`, `.vs/`, `.npm-cache/`
- `Plugins/*/Binaries/`, `Plugins/*/Intermediate/`
- 서드파티 플러그인의 `*.md`(PCGEx 등)는 그 플러그인을 수정하거나 라이선스를 확인할 때만.
- `.uasset`, `.umap`은 바이너리다. 내용은 UE MCP로 조회하고 파일을 직접 열지 않는다.

## 저장소 구조

- repo root(`xxx.unreal/`) 아래에 Unreal 프로젝트 폴더(`ProjectName/`)가 한 단계 더 있다.
  `ProjectName/` 안에서 작업 중이어도 `git rev-parse --show-toplevel`로 git root를 먼저 확인한다.

```
xxx.unreal/                      # git root
  AGENTS.md  CLAUDE.md  PROJECT_CONTEXT.md  README.md
  .mcp.json                      # ue-mcp (커밋 제외)
  doc/                           # 설계·핸드오프 문서
  ProjectName/
    ProjectName.uproject
    Config/                      # DefaultEngine.ini, DefaultInput.ini ...
    Content/                     # 프로젝트 에셋 (__ExternalActors__ 포함)
    Source/ProjectName/          # C++ 모듈. 테스트는 *Tests.cpp
    Plugins/
      UE_MCP_Bridge/             # MCP 연동 (에디터 전용)
      ...                        # 서드파티 플러그인
```

## 초기 세팅 체크리스트

- Unreal Engine 5.6 또는 5.7 + Visual Studio (C++ 빌드 환경).
- `.uproject` 모듈: `ProjectName` (Runtime), `AdditionalDependencies`에 `Engine`, `UMG`.
- 플러그인: `PythonScriptPlugin`, `EnhancedInput`, `UE_MCP_Bridge`, 필요 시 `ChaosVehiclesPlugin`, `RawInput`, `Niagara`, `PCG`, `StateTree`.
- `UE_MCP_Bridge` 플러그인을 `Plugins/`에 복사하고 `.mcp.json`을 `.mcp.json.sample`에서 만들어 `.uproject` 경로를 채운다.
- `.gitignore`를 repo root와 `ProjectName/` 양쪽에 둔다 (루트: `.claude/`, `.mcp.json`).
- 외부 입력 장치(휠·페달 등)는 RawInput + Enhanced Input Action으로 바인딩.

## 도구: UE MCP 우선

- 에디터 상태 확인, 레벨·액터·컴포넌트·블루프린트·에셋 조회/수정은 UE MCP(`ue-mcp` + `UE_MCP_Bridge`)로 먼저 시도한다.
- 실행: `.mcp.json`의 `npx -y ue-mcp <uproject 경로>`. 에디터가 켜져 있어야 브리지가 응답한다.
- C++ 수정 후 빌드는 PowerShell에서:
  ```powershell
  & "D:\Program Files\Unreal\UE_5.7\Engine\Build\BatchFiles\Build.bat" ProjectNameEditor Win64 Development -Project="<절대경로>\ProjectName.uproject" -WaitMutex
  ```
- MCP가 연결되지 않거나 불가능한 작업만 파일 직접 수정·커맨드렛을 쓰고, 그 이유를 결과에 남긴다.

## Unreal 규칙

### 에셋 / 맵

- `.umap`, `.uasset`은 사용자·에디터 변경일 수 있다. 자동 되돌리기 금지.
- 현재 작업과 무관한 map/content 변경은 건드리지 않는다.
- `*_BuiltData.uasset`은 커밋하지 않는다.
- 플러그인 소스는 커밋 대상일 수 있지만 플러그인 빌드 산출물은 제외.

### C++

- 클래스 접두사는 프로젝트 약어로 통일 (예: `AAIDVEventActor`, `UAIDVWorldStateComponent`).
- 테스트는 같은 모듈 안 `*Tests.cpp`에 Automation Test로 둔다. 로직을 바꾸면 테스트도 같이 고친다.
- 게임플레이 로직은 Actor보다 Component / Subsystem으로 나눠 레벨 의존을 줄인다.
- 외부 통신(UDP/WebSocket/Hub) 계약은 `PROJECT_CONTEXT.md`의 Runtime Contract 절에 기록하고, 포트·토픽·메시지 버전을 바꾸면 문서를 먼저 고친다.

### 런타임 계약

- 다른 PC/프로그램(Unity HUD, Python 서비스 등)과 주고받는 상태는 `state/...` 식의 토픽과 TTL로 정의한다.
- 상대가 stale 판정할 수 있도록 상태 변화 즉시 publish하고, 종료 시 false/clear를 반드시 보낸다.
- 같은 interaction의 press/release 순서와 id를 유지한다.

## 자주 쓰는 확인

```powershell
git rev-parse --show-toplevel
git status --short
Get-Content ProjectName\ProjectName.uproject
```

에디터에서 확인할 것: Output Log 에러 없음, 메인 레벨(`Content/Main.umap`) 로드, 입력 장치 바인딩, 외부 연동 상태 publish/clear.
