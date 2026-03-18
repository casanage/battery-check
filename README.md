# Battery Quick Check (Windows)

노트북 배터리 상태를 **클릭 한 번**으로 확인할 수 있는 초간단 실행 파일 조합입니다.

- `BatteryHealthQuickCheck.cmd` 더블클릭
- 자동으로 `powercfg /batteryreport` 생성
- 메시지 박스로 핵심 지표 표시
  - 현재 잔량
  - 상태
  - 최대 충전 가능 용량(Full Charged Capacity)
  - 설계 용량(Designed Capacity)
  - 건강도 추정치
  - 사이클 수(지원 모델만)
- 권장 교체 기준 안내
  - 건강도 80% 미만 또는 사이클 800회 이상
- 오류가 발생해도 창이 즉시 닫히지 않고 안내 문구 후 대기합니다.

## 파일 구성

- `BatteryHealthQuickCheck.cmd` : 사용자 실행용(더블클릭)
- `BatteryHealthQuickCheck.ps1` : 실제 로직

## 사용 방법

1. 두 파일을 같은 폴더에 둡니다.
2. `BatteryHealthQuickCheck.cmd`를 더블클릭합니다.
3. 메시지 창 확인 후, 데스크탑에 생성된 `battery-report-YYYYMMDD_HHMMSS.html` 파일을 열어 상세 내역을 봅니다.

## 참고

- 일부 노트북은 WMI에서 사이클 수를 제공하지 않을 수 있습니다. 이 경우 `확인 불가`로 표시됩니다.
- 관리자 권한 없이 실행 가능합니다.
- 추가 설치(파이썬 등) 없이 Windows 기본 구성 요소(`powershell`, `powercfg`)만 사용합니다.

## EXE로 묶고 싶은 경우 (선택)

추가로 원하시면 나중에 이 스크립트를 단일 exe로 패키징하는 방법(예: 내부 배포용)도 안내해드릴 수 있습니다.
