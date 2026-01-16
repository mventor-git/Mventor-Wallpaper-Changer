if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName Microsoft.VisualBasic
$userInput = [Microsoft.VisualBasic.Interaction]::InputBox("Enter your custom Watermark Name:", "Mventor", "MVENTOR")

if ([string]::IsNullOrWhiteSpace($userInput)) { $userInput = "MVENTOR" }

$setWallPath = Join-Path $PSScriptRoot "Scripts\SetWall.ps1"
$hotkeyPath = Join-Path $PSScriptRoot "Scripts\Hotkeys.ahk"

if (Test-Path $setWallPath) {
    (Get-Content $setWallPath) -replace '\$text\s*=\s*".*"', "`$text = `"$userInput`"" | Set-Content $setWallPath
}

$taskName = "MventorAutoRun"
$action = New-ScheduledTaskAction -Execute "AutoHotkey.exe" -Argument "`"$hotkeyPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0

Register-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -TaskName $taskName -User $env:USERNAME -Force

Write-Host "Mventor is now installed and will run stealthily in the background." -ForegroundColor Green
pause