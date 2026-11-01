# [프로젝트명] - Context

## 무엇을 만드는가
한두 문장. 어떤 체험/시뮬레이션인지, 어느 PC에서 어떤 출력으로 나가는지.

핵심 사용자:
- **체험자**: (예: 레이싱 휠로 운전한다)
- **현장 운영자**: (예: 컨트롤 패널로 시나리오를 시작한다)

## 핵심 도메인 개념
- **용어1**: 뜻.
- **용어2**: 뜻.

## 아키텍처 개요
- **Unreal 프로젝트** (UE 5.x, 모듈 `ProjectName`)
  - 메인 레벨: `Content/Main.umap`
  - 주요 클래스: `A...Pawn`, `U...Component`, `U...Subsystem`
- **플러그인**: 어떤 플러그인을 왜 쓰는지 한 줄씩.
- **입력 장치**: 키보드 / 휠·페달(RawInput) → Enhanced Input Action
- **외부 연동 (Runtime Contract)**
  - 상대 프로그램, 프로토콜(UDP/WebSocket), 포트, 토픽, 메시지 버전
  - publish 조건과 clear 조건 (예: 선택창 열림 → `state/xxx.active=true`, 닫힘 → `false`)

## 결정 기록
- YYYY-MM-DD: 결정 내용과 이유.

## 미해결 이슈 / 미구현
- 항목. 현재 상태와 막힌 이유.
