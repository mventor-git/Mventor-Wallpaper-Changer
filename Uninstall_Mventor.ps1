if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$taskName = "MventorAutoRun"

try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "Mventor removed from background tasks." -ForegroundColor Cyan
} catch {
    Write-Host "Task not found." -ForegroundColor Yellow
}
pause