# [프로젝트명] - Context

## 무엇을 만드는가
한두 문장. 어느 PC에서 돌고, 무엇을 받아 무엇을 내보내는지. (예: 센서 → 계산 → UDP/Hub 송신)

핵심 사용자:
- **현장 운영자**: (예: run.bat 더블클릭으로 실행, 화면 없이 status.bat로 확인)
- **연동 프로그램**: (예: Unity HUD, Unreal 시뮬레이터)

## 핵심 도메인 개념
- **용어1**: 뜻.
- **용어2**: 뜻.

## 아키텍처 개요
- **실행 형태**: CLI 도구 / GUI(tkinter·PyQt) / FastAPI 서버 (포트)
- **진입점**: `main.py` → `src/<package>/...`
- **외부 장치**: 장치명, SDK, 연결 방식. 장치 없을 때 동작.
- **외부 연동 (계약)**
  - 상대 프로그램, 프로토콜(UDP/WebSocket/HTTP), 포트, 메시지 스키마 버전
  - 계약 문서: `docs/message_contract.md` (코드와 다르면 문서가 맞다)
- **런타임 데이터**: `C:\ezwith\data\{project}\config.json`, 캐시·로그 위치

## 실행
```powershell
run.bat                 # 기본 인자
run.bat --no-ui ...     # 인자 지정
```

## 결정 기록
- YYYY-MM-DD: 결정 내용과 이유.

## 미해결 이슈 / 미구현
- 항목. 현재 상태와 막힌 이유.
