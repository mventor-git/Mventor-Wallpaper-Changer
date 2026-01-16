param([int]$ForceUpdate = 0)

$ErrorActionPreference = 'SilentlyContinue'
$baseDir = Split-Path -Parent $PSScriptRoot
$dataDir = Join-Path $baseDir "Data"
$backupDir = Join-Path $baseDir "Backup"

if (!(Test-Path $dataDir)) { New-Item -ItemType Directory -Path $dataDir }

$currentPath = Join-Path $dataDir "current_bg.jpg"
$nextPath = Join-Path $dataDir "next_bg.jpg"
$lastCheckFile = Join-Path $dataDir "last_update.txt"

function Add-Watermark($filePath) {
    if (!(Test-Path $filePath)) { return }
    try {
        Add-Type -AssemblyName System.Drawing
        $bmp = [System.Drawing.Image]::FromFile($filePath)
        $baseBmp = New-Object System.Drawing.Bitmap(1920, 1080)
        $graphics = [System.Drawing.Graphics]::FromImage($baseBmp)
        
        $graphics.InterpolationMode = "HighQualityBicubic"
        $graphics.SmoothingMode = "AntiAlias"
        $graphics.TextRenderingHint = "ClearTypeGridFit" 
        
        $graphics.DrawImage($bmp, 0, 0, 1920, 1080)
        
        $text = "M V E N T O R"
        $font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $textSize = $graphics.MeasureString($text, $font)
        
        $posX = (1920 - $textSize.Width) / 2
        $posY = 1080 - 85 

        $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
        $graphics.DrawString($text, $font, $shadowBrush, $posX + 1, $posY + 1)
        
        $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
        $graphics.DrawString($text, $font, $textBrush, $posX, $posY)
        
        $graphics.Dispose(); $bmp.Dispose()
        $tempPath = $filePath + ".tmp.jpg"
        $baseBmp.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $baseBmp.Dispose()
        Move-Item $tempPath $filePath -Force
    } catch { }
}

function Set-Wallpaper($path) {
    if (Test-Path $path) {
        $win32 = 'using System.Runtime.InteropServices; public class Win32 { [DllImport("user32.dll", CharSet = CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'
        if (-not ([Ref].Assembly.GetType("Win32"))) { Add-Type -TypeDefinition $win32 }
        [Win32]::SystemParametersInfo(0x0014, 0, $path, 0x01)
    }
}

if ($ForceUpdate -eq 1) {
    try {
        $apiUrl = "https://wallhaven.cc/api/v1/search?q=dark+abstract+minimalism&categories=100&purity=100&sorting=random&atleast=1920x1080&seed=$(Get-Random)"
        $res = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 10
        Invoke-WebRequest -Uri $res.data[0].path -OutFile $currentPath -TimeoutSec 15
        Add-Watermark $currentPath
        Set-Wallpaper $currentPath
    } catch {
        $backupFile = Get-ChildItem $backupDir -Include *.jpg, *.png | Get-Random
        Copy-Item $backupFile.FullName $currentPath -Force
        Add-Watermark $currentPath
        Set-Wallpaper $currentPath
    }
} else {
    if (Test-Path $nextPath) {
        Copy-Item $nextPath $currentPath -Force
        Set-Wallpaper $currentPath
    }
    
    $lastUpdate = if (Test-Path $lastCheckFile) { Get-Date (Get-Content $lastCheckFile) } else { (Get-Date).AddHours(-5) }
    $timePassed = (New-TimeSpan -Start $lastUpdate -End (Get-Date)).TotalHours
    
    if ($timePassed -ge 4) {
        try {
            $apiUrl = "https://wallhaven.cc/api/v1/search?q=dark+abstract+minimalism&categories=100&purity=100&sorting=random&atleast=1920x1080&seed=$(Get-Random)"
            $res = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 10
            Invoke-WebRequest -Uri $res.data[0].path -OutFile $nextPath -TimeoutSec 15
            Get-Date | Out-File $lastCheckFile
        } catch {
            $backupFile = Get-ChildItem $backupDir -Include *.jpg, *.png | Get-Random
            Copy-Item $backupFile.FullName $nextPath -Force
        }
    } else {
        $backupFile = Get-ChildItem $backupDir -Include *.jpg, *.png | Get-Random
        Copy-Item $backupFile.FullName $nextPath -Force
    }
    Add-Watermark $nextPath
}