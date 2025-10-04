param(
    [string]$WatchPath = "C:\Users\jsbui\Documents\Visual_codes\ZZZ_Auto\PrePro",
    [string]$ProcessScript = "C:\Users\jsbui\Documents\Visual_codes\ZZZ_Auto\process-file.ps1",
    [string]$LogFile = "C:\Users\jsbui\Documents\Visual_codes\ZZZ_Auto\watcher.log"
)

function Write-Log {
    param($m)
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))`t$m" | Out-File -FilePath $LogFile -Append -Encoding utf8
}

if (-not (Test-Path $WatchPath)) { New-Item -ItemType Directory -Path $WatchPath | Out-Null }
if (-not (Test-Path $ProcessScript)) { Write-Log "ERROR: process script not found"; exit 2 }

Write-Log "Watcher starting on $WatchPath"

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $WatchPath
$watcher.Filter = "*.txt"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

$procScript = $ProcessScript
$log = $LogFile

Register-ObjectEvent $watcher Created -Action {
    try {
        $full = $EventArgs.FullPath
        $name = $EventArgs.Name
        Write-Log "Archivo detectado: $full"

        Start-Sleep -Seconds 1

        & $procScript -FilePath $full
        Write-Log "Archivo procesado: $name"
    }
    catch {
        Add-Content -Path $log -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ERROR en evento Created: $_"
    }
}

Write-Log "Watcher running..."
Write-Host "Watcher corriendo en $WatchPath, presiona Ctrl+C para salir."

while ($true) { Start-Sleep -Seconds 5 }
