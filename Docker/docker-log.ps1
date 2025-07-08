
# This script filters a log file for specific error or warning lines and exports them to a CSV file.
$logFilePath = "C:\ProgramData\Docker\docker.log"
$csvOutput = "$env:USERPROFILE\Desktop\filenamehere.csv"
$errorCapture = @("ERROR", "WARNING")
$errorEntries = @()


if (-not (Test-Path -Path $logFilePath)) {
    New-Item -ItemType File -Path $logFilePath -Force
}

Get-Content -path $logFilePath | ForEach-Object {
    $line = $_

    if ($errorCapture | Where-Object { $line -match $_ }) {
        $errorEntries += [PSCustomObject]@{
            Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            LogLine   = $line
        }
    }
}


if ($errorEntries.Count -eq 0) {
    Write-Host "No error or warning lines found in the log file." -ForegroundColor Green
    return
} else {
    $errorEntries | Export-Csv -Path $csvOutput -NoTypeInformation -Encoding UTF8
}

Write-Host "Filtered error lines written to: $csvOutput"