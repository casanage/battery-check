[CmdletBinding()]
param(
    [switch]$OpenReport
)

$ErrorActionPreference = 'Stop'

function Get-BatteryData {
    $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    if (-not $battery) {
        return $null
    }

    $cycleCount = $null
    try {
        $cycleObj = Get-CimInstance -Namespace root\wmi -ClassName BatteryCycleCount -ErrorAction SilentlyContinue
        if ($cycleObj) {
            $cycleCount = [int]$cycleObj.CycleCount
        }
    }
    catch {
        $cycleCount = $null
    }

    $designed = $null
    $full = $null
    $healthPercent = $null

    try {
        $staticData = Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction SilentlyContinue
        if ($staticData) {
            $designed = [double]$staticData.DesignedCapacity
        }
    }
    catch {
        $designed = $null
    }

    try {
        $fullData = Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction SilentlyContinue
        if ($fullData) {
            $full = [double]$fullData.FullChargedCapacity
        }
    }
    catch {
        $full = $null
    }

    if ($designed -and $full -and $designed -gt 0) {
        $healthPercent = [math]::Round(($full / $designed) * 100, 1)
    }

    [PSCustomObject]@{
        EstimatedChargeRemaining = $battery.EstimatedChargeRemaining
        BatteryStatus            = $battery.BatteryStatus
        DesignedCapacity         = $designed
        FullChargedCapacity      = $full
        HealthPercent            = $healthPercent
        CycleCount               = $cycleCount
    }
}

function Get-ReplacementMessage {
    param(
        [double]$HealthPercent,
        [int]$CycleCount
    )

    $healthThreshold = 80
    $cycleThreshold = 800

    $healthBad = $false
    $cycleBad = $false

    if ($HealthPercent -ne $null -and $HealthPercent -lt $healthThreshold) {
        $healthBad = $true
    }

    if ($CycleCount -ne $null -and $CycleCount -ge $cycleThreshold) {
        $cycleBad = $true
    }

    if ($healthBad -or $cycleBad) {
        return "배터리 교체를 고려하세요. (권장 기준: 건강도 ${healthThreshold}% 미만 또는 사이클 ${cycleThreshold}회 이상)"
    }

    return "현재는 즉시 교체 권장 상태는 아닙니다. (참고 기준: 건강도 ${healthThreshold}% 미만 또는 사이클 ${cycleThreshold}회 이상)"
}

try {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $reportPath = Join-Path $desktop "battery-report-$stamp.html"

    powercfg /batteryreport /output "$reportPath" | Out-Null

    $batteryData = Get-BatteryData
    if (-not $batteryData) {
        throw '배터리 정보를 찾지 못했습니다. (데스크탑 PC이거나 배터리 장치 비활성화 가능)'
    }

    $statusMap = @{
        1 = '방전 중'
        2 = 'AC 연결 / 충전 아님'
        3 = '완전 충전'
        4 = '저전력'
        5 = '심각한 저전력'
        6 = '충전 중'
        7 = '충전 중 (상태 불명)'
        8 = '충전됨'
        9 = '미정의'
        10 = '부분 충전'
        11 = '부분 충전 (고전압)'
    }

    $statusText = $statusMap[[int]$batteryData.BatteryStatus]
    if (-not $statusText) {
        $statusText = "코드 $($batteryData.BatteryStatus)"
    }

    $healthText = if ($batteryData.HealthPercent -ne $null) { "$($batteryData.HealthPercent)%" } else { '확인 불가' }
    $cycleText = if ($batteryData.CycleCount -ne $null) { "$($batteryData.CycleCount)회" } else { '확인 불가 (기기 미지원 가능)' }
    $designText = if ($batteryData.DesignedCapacity -ne $null) { "{0:N0} mWh" -f $batteryData.DesignedCapacity } else { '확인 불가' }
    $fullText = if ($batteryData.FullChargedCapacity -ne $null) { "{0:N0} mWh" -f $batteryData.FullChargedCapacity } else { '확인 불가' }

    $replaceMessage = Get-ReplacementMessage -HealthPercent $batteryData.HealthPercent -CycleCount $batteryData.CycleCount

    $message = @"
배터리 리포트 생성 완료

[핵심 요약]
- 현재 잔량: $($batteryData.EstimatedChargeRemaining)%
- 상태: $statusText
- 최대 충전 가능 용량: $fullText
- 설계 용량: $designText
- 건강도(추정): $healthText
- 사이클 수: $cycleText

$replaceMessage

리포트 위치:
$reportPath
"@

    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show($message, '배터리 퀵체크', 'OK', 'Information') | Out-Null

    if ($OpenReport) {
        Start-Process $reportPath
    }
}
catch {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("실행 중 오류가 발생했습니다.`n$($_.Exception.Message)", '배터리 퀵체크 오류', 'OK', 'Error') | Out-Null
    exit 1
}
