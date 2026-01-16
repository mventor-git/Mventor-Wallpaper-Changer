Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms


$userInput = [Microsoft.VisualBasic.Interaction]::InputBox("Enter your custom Watermark Name (e.g., MVENTOR):", "Mventor Personalization", "MVENTOR")

if ([string]::IsNullOrWhiteSpace($userInput)) {
    Write-Host "No name entered. Installation cancelled." -ForegroundColor Red
    exit
}


$scriptPath = Join-Path $PSScriptRoot "Scripts\SetWall.ps1"

if (Test-Path $scriptPath) {
   
    $content = Get-Content $scriptPath
    

    $newContent = $content -replace '\$text\s*=\s*".*"', "`$text = `"$userInput`""
    
  
    $newContent | Set-Content $scriptPath -Encoding UTF8
    Write-Host "Watermark updated to: $userInput" -ForegroundColor Green
}


$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c start /min `"$PSScriptRoot\Scripts\Hotkeys.ahk`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "MventorWallpaperChanger" -Force

[System.Windows.Forms.MessageBox]::Show("Success! Your custom name '$userInput' is set.`nProgram will start with Windows.", "Mventor Installed")