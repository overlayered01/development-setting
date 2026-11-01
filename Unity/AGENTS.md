# Unity 프로젝트 규칙 (AGENTS.md)

공통 규칙은 상위 `../AGENTS.md`. 이 파일은 Unity 전용이다.
프로젝트를 다른 곳에 복사하면 아래 **공통 요약**만으로도 동작하도록 핵심을 중복해 둔다.

## 공통 요약

- 답변·커밋 메시지·UI 문구는 한국어.
- 작업 전 플랜 → 확인 → 실행. 커밋은 명시적 요청 시에만.
- 배경·결정 사항은 `PROJECT_CONTEXT.md` 참고. 계약 문서가 코드보다 우선.
- 수치 하드코딩 금지. config 또는 `[SerializeField]`.
- 런타임 설정·콘텐츠는 `C:\ezwith\data\{productName}\` (config.json, state.json, 영상·이미지).
- 작업 종료 전 README·AGENTS.md가 실제와 다른지 확인하고 갱신.

## 토큰 절약 (읽지 않는 경로)

- `Library/`, `Temp/`, `Logs/`, `Obj/`, `Build/`, `Builds/`, `UserSettings/`, `.vs/`, `.vscode/`, `_Recovery/`
- Unity 생성 파일 `*.csproj`, `*.sln`, `*.slnx`
- 서드파티 에셋 폴더(`AVProVideo/`, `TextMesh Pro/`, `Plugins/` 등)는 직접 관련 있을 때만.

## 도구: Unity MCP 우선

- Unity 에디터 상태 확인, 씬·GameObject·프리팹·컴포넌트·머티리얼·임포트 설정 작업은 Unity MCP로 먼저 시도한다.
- 패키지: `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main`
- 작업 시작 시 active instance와 editor state를 먼저 확인한다.
- 씬 구조는 YAML을 추측하지 말고 MCP hierarchy 조회로 확인한다.
- C# 수정 후에는 MCP console/editor state로 컴파일 오류와 도메인 리로드를 확인한다.
- MCP가 연결되지 않거나 불가능한 작업만 파일 직접 수정·batchmode를 쓰고, 그 이유를 결과에 남긴다.

## 프로젝트 구조

```
Assets/
  App/                 # 프로젝트 코드·에셋은 전부 여기 (서드파티와 분리)
    Scenes/
    Scripts/
      Config/          # Config.cs, ConfigLoader.cs
      Editor/          # EditorUtils.cs 하나만 유지
      Network/ Hardware/ Show/ State/ UI/ ...  # 역할별 폴더
    Prefabs/  UI/  Fonts/  Images/  Audio/  Video/
    Config/config.sample.json
    Reference/         # 외부 계약 문서(프로토콜 md 등)
    Tests/Editor/      # EditMode 테스트
  StreamingAssets/
  InputSystem_Actions.inputactions
docs/                  # 설계·하드웨어 프로토콜 문서
tools/                 # 테스트용 python 스크립트 등
PROJECT_CONTEXT.md  README.md  AGENTS.md  CLAUDE.md
```

## 초기 세팅 체크리스트

- Unity 6 (6000.x) + URP. 2D 전용이어도 URP 유지.
- 패키지: Input System, UniTask (`https://github.com/Cysharp/UniTask.git?path=src/UniTask/Assets/Plugins/UniTask`), Unity MCP, TextMeshPro, Test Framework.
- 자주 쓰는 에셋: AVPro Video(HAP 재생), DOTween, Unity-Logs-Viewer.
- Player Settings: `Run In Background` 켬, 필요 시 `Allow downloads over HTTP = Always`(평문 HTTP CMS).
- Active Input Handling = Input System Package (New).
- `.gitignore`, `.gitattributes`(Unity YAML merge)를 루트에 둔다.
- `Assets/App/Scripts/Config/ConfigLoader`가 `C:\ezwith\data\{productName}\config.json`을 읽고, 없으면 `config.sample.json`을 복사해 만든다.

## Unity 규칙

### Input / Application

- 구 Input System(`UnityEngine.Input`) 사용 금지. New Input System만.
- `Application.runInBackground = true` 필수 (진입점 `Awake`에서).
- 전역 키 후킹(`SetWindowsHookEx`) 사용 금지.

### Canvas / 레이아웃

- Hierarchy 하단 자식일수록 앞에 그려진다. FadeOverlay·팝업·툴팁은 마지막 자식 (`SetAsLastSibling()`).
- 디자인 해상도 기준으로 뷰를 만들고, 실제 출력 해상도가 다르면 루트 하나만 스케일한다. 실제 크기는 config에서 바꾼다.
- 런타임 텍스트는 TextMeshPro만. legacy `UnityEngine.UI.Text` 0개.
- 씬에 저장된 UI를 코드로 재생성하지 않는다. 참조는 직렬화 필드로 연결.

### 콘텐츠 / 데이터

- 영상·카드 이미지 등은 프로젝트 밖 `C:\ezwith\data\{productName}\`에서 로드.
- 카테고리·개수·이름은 폴더/config에서 결정. 코드에 하드코딩하지 않는다.
- 식별자는 인덱스가 아니라 코드 문자열(예: `A01-02`)로 참조.

### Editor 스크립트

- 일회성 유틸(MenuItem, InitializeOnLoad 등)은 `Assets/App/Scripts/Editor/EditorUtils.cs` 하나를 유지하고 내용만 교체. 파일 생성·삭제 반복 금지.
- 이유: 파일 생성·삭제마다 도메인 리로드 → Inspector 타이밍과 겹치면 `EditorStyles` NullReferenceException으로 에디터 파손 (Unity 6.x).
- 테스트는 `Assets/App/Tests/Editor/*.cs` EditMode. 로직을 바꾸면 테스트도 같이 고친다.

### 하드웨어 / 네트워크

- 시리얼·TCP 송신은 컨트롤러별 **단일 큐**를 거쳐 config의 간격(`frameGapMs`) 이상으로 내보낸다.
- 외부 서버(Hub) 값은 TTL 이후 stale로 취급하고, stale 값을 최신값처럼 표시하지 않는다.
- 외부 프로토콜 DTO 파일은 상대 쪽 파일을 그대로 복사해 쓴다 (네임스페이스 포함, 임의 수정 금지).

## 코딩 컨벤션

- **네이밍**: private `_camelCase` + `[SerializeField]` / public `PascalCase` / const `PascalCase`
- **네임스페이스**: `[ProjectName].[Category]` (예: `KiaPickupLounge.Hardware`)
- **비동기**: UniTask 전용. bare `Task` 금지 (`Task.Delay`는 씬 언로드 후에도 계속 돈다). 새 코드에 코루틴 금지.
- **라이프사이클**: `Awake` 초기화 / `OnEnable`·`OnDisable` 리스너 등록·해제 / `OnDestroy`·`OnApplicationQuit`에서 포트·소켓 정리
- **DOTween**: `SetLink(gameObject)` 필수 (오브젝트 파괴 시 자동 종료)
- **싱글턴**: `Instance` 정적 프로퍼티는 앱 진입점과 네트워크 서비스에만 허용. 뷰 간 참조는 직렬화 필드.
- **주석**: 클래스 상단 `<summary>`에 역할·프로토콜·주의점을 한국어로 적는다.

## 편집 정책

- 사용자·에디터가 만든 scene/prefab/asset 변경을 되돌리지 않는다.
- `.meta`는 해당 에셋과 함께 유지한다 (에셋 참조 보존).
- `Library/`, `Temp/`, `Logs/`, `UserSettings/`, 빌드 산출물은 커밋 대상이 아니다.

## 자주 쓰는 확인

```powershell
git status --short
Get-Content ProjectSettings\ProjectVersion.txt
Get-Content Packages\manifest.json
Get-Content C:\ezwith\data\<productName>\config.json
```

에디터에서 확인할 것: Console 에러 없음, Game View 디자인 해상도에서 UI 겹침 없음, 외부 연결 미연결·재연결·stale 표시 정상, EditMode 테스트 통과.
