param(
    [Parameter(Mandatory=$true)][string]$FilePath,
    [string]$Arch = "C:\Users\jsbui\Documents\Visual_codes\ZZZ_Auto\Arch",
    [string]$PostPro = "C:\Users\jsbui\Documents\Visual_codes\ZZZ_Auto\PostPro",
    [string]$Processor = "C:\Users\jsbui\Documents\Visual_codes\ZZZ_Auto\dummy_production.py",
    [int]$MaxWaitSec = 600,
    [int]$PollInterval = 2,
    [string]$LogFile = "C:\Users\jsbui\Documents\Visual_codes\ZZZ_Auto\watcher.log"
)

function Write-Log {
    param([string]$m)
    $t = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$t`t$m" | Out-File -FilePath $LogFile -Append -Encoding utf8
}

function Wait-FileReady {
    param($path, $maxWaitSec, $interval)
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    if (-not (Test-Path $path)) { return $false }

    while ($sw.Elapsed.TotalSeconds -lt $maxWaitSec) {
        try {
            $stream = [System.IO.File]::Open($path,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::Read,
                [System.IO.FileShare]::None)
            $stream.Close()
            return $true
        } catch {
            Start-Sleep -Seconds $interval
        }
    }
    return $false
}

try {
    $fileName = [System.IO.Path]::GetFileName($FilePath)
    Write-Log "START processing: $FilePath"

    if (-not (Test-Path $FilePath)) {
        Write-Log "File not found: $FilePath"
        exit 2
    }

    if (-not (Wait-FileReady -path $FilePath -maxWaitSec $MaxWaitSec -interval $PollInterval)) {
        Write-Log "TIMEOUT waiting file ready: $FilePath"
        exit 3
    }

    foreach ($d in @($Arch, $PostPro)) {
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
    }

    $destArch = Join-Path $Arch $fileName
    Move-Item -Path $FilePath -Destination $destArch -Force
    Write-Log "Moved to Arch: $destArch"

    $outFile = Join-Path $PostPro $fileName
    $python = "python"  # asegúrate que python esté en PATH
    $args = "`"$Processor`" `"$destArch`" `"$outFile`""
    $proc = Start-Process -FilePath $python -ArgumentList $args -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Log "Processor failed with exit code $($proc.ExitCode)"
        throw "Processor error"
    }

    Write-Log "SUCCESS processing $fileName"
} catch {
    Write-Log "ERROR processing $FilePath - $_"
    exit 1
}