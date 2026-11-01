# Flutter 프로젝트 규칙 (AGENTS.md)

공통 규칙은 상위 `../AGENTS.md`. 이 파일은 Flutter 전용이다.
E:\Work에는 아직 Flutter 프로젝트가 없어, Unity·Python 규칙과 일반 Flutter 관례를 바탕으로 작성했다. 첫 프로젝트를 끝내면 이 파일을 실제 경험으로 갱신한다.
프로젝트를 다른 곳에 복사하면 아래 **공통 요약**만으로도 동작하도록 핵심을 중복해 둔다.

## 공통 요약

- 답변·커밋 메시지·UI 문구는 한국어. 코드 식별자는 영어.
- 작업 전 플랜 → 확인 → 실행. 커밋은 명시적 요청 시에만.
- 배경·결정 사항은 `PROJECT_CONTEXT.md` 참고. 계약 문서(프로토콜 md)가 코드보다 우선.
- 수치·포트·경로 하드코딩 금지. 설정 파일 또는 상수 클래스.
- 작업 종료 전 README·AGENTS.md가 실제와 다른지 확인하고 갱신.

## 토큰 절약 (읽지 않는 경로)

- `build/`, `.dart_tool/`, `.idea/`, `.vscode/`, `*.g.dart`, `*.freezed.dart` (생성 코드)
- `android/`, `ios/`, `windows/` 플랫폼 폴더는 네이티브 설정을 바꿀 때만.
- `pubspec.lock`은 의존성 충돌을 조사할 때만.

## 프로젝트 구조

```
xxx.flutter/                   # git root
  AGENTS.md  CLAUDE.md  PROJECT_CONTEXT.md  README.md
  pubspec.yaml  analysis_options.yaml
  lib/
    main.dart                  # 앱 진입점 (초기화·전체화면·wakelock만)
    app/                       # MaterialApp, 라우팅, 테마
    core/
      config/                  # AppConfig 로드 (assets/config.json → 로컬 저장 덮어쓰기)
      network/                 # TCP/WebSocket 클라이언트, 재접속
      protocol/                # 메시지 DTO (상대 쪽 계약 파일을 그대로 옮긴다)
    features/<feature>/        # 기능별: data / domain / presentation
    shared/                    # 공용 위젯·유틸
  assets/
    config.sample.json
    images/  fonts/
  docs/                        # 프로토콜·설계 문서
  test/                        # 단위·위젯 테스트
```

## 초기 세팅 체크리스트

- Flutter stable 최신. `flutter create --org com.easywith --platforms android,windows <name>`.
- `analysis_options.yaml`에 `flutter_lints` + 추가 규칙 (템플릿 참고).
- 패키지(필요한 것만): `flutter_riverpod`(상태), `go_router`(라우팅), `freezed`+`json_serializable`(DTO), `shared_preferences`(로컬 설정), `wakelock_plus`(화면 꺼짐 방지), `web_socket_channel` 또는 `dart:io Socket`(통신), `logger`.
- 태블릿 현장 앱이면: 전체화면(`SystemUiMode.immersiveSticky`), 가로/세로 고정, wakelock 켬, 뒤로가기 비활성.
- `assets/config.sample.json`에 서버 호스트·포트·디자인 해상도. 앱 안 설정 화면에서 덮어쓸 수 있게.
- `.gitignore`를 루트에 둔다 (`.claude/`, `.mcp.json` 포함).

## Flutter 규칙

### 상태 / 구조

- 상태 관리는 Riverpod 하나로 통일. `setState`는 위젯 내부 UI 상태에만.
- 위젯은 표시만, 로직은 Notifier/Service로. 위젯에서 소켓·파일을 직접 다루지 않는다.
- feature 폴더 간 직접 import 금지. 공유는 `core/`·`shared/`로.
- 생성 코드(`*.g.dart`, `*.freezed.dart`)는 손으로 고치지 않는다. `dart run build_runner build -d`.

### 네트워크 / 프로토콜

- 서버(메인PC)와의 계약은 `docs/*_PROTOCOL.md`가 기준. DTO 파일은 상대 쪽과 동일하게 유지하고 임의 필드 추가 금지.
- 연결은 자동 재접속(backoff), 끊김·stale 상태를 화면에 표시한다.
- 재전송은 같은 `request_id`로 멱등 처리. 수신 burst는 최신 1건만 반영.
- 메시지 처리는 UI 스레드를 막지 않는다. 큰 파싱은 `compute`.

### UI

- 디자인 해상도 기준으로 레이아웃을 만들고 실제 기기 크기에는 스케일 또는 `LayoutBuilder`로 대응.
- 색·크기·간격은 테마/상수 클래스. 위젯 안에 매직 넘버 금지.
- 텍스트는 프로젝트 폰트 에셋 사용. 시스템 폰트 의존 금지.
- 로딩·오류·빈 상태를 모든 화면에 둔다.

### 테스트

- 프로토콜 파싱·상태 전이는 단위 테스트 필수. 화면은 핵심 흐름만 위젯 테스트.
- 실행: `flutter test`

## 자주 쓰는 확인

```powershell
git status --short
flutter --version
flutter pub get
flutter analyze
flutter test
flutter run -d windows        # 데스크톱으로 빠른 확인
flutter devices               # 태블릿 연결 확인
```
