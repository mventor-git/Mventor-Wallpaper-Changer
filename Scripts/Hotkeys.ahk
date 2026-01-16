#NoTrayIcon
#SingleInstance Force

#If WinActive("ahk_class Progman") || WinActive("ahk_class WorkerW") || WinActive("ahk_class Shell_TrayWnd")

!w::
    Run, powershell.exe -ExecutionPolicy Bypass -File "C:\MyRice\Scripts\SetWall.ps1" -ForceUpdate 0, , Hide
return

!f::
    Run, powershell.exe -ExecutionPolicy Bypass -File "C:\MyRice\Scripts\SetWall.ps1" -ForceUpdate 1, , Hide
return

#If