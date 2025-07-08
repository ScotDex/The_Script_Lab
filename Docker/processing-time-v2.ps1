<#
.SYNOPSIS
    Calculates and reports the average processing time between messages in a log file.

.DESCRIPTION
    This script reads a specified log file, extracts ISO-formatted timestamps from lines containing 
    "MESSAGEREADER: New message received", calculates the time differences between consecutive messages, 
    and outputs the average time between messages. The results are written to a CSV file on the user's desktop.

.PARAMETER logfilepath
    The path to the log file to be processed. Must be set before running the script.

.PARAMETER csvOutput
    The path to the CSV file where the report will be saved. Defaults to the user's desktop.

.OUTPUTS
    Writes processing time information to the console and appends a summary object to a CSV file.

.NOTES
    - The script expects log entries to contain a "time" field in ISO format.
    - If the log file does not exist, it will be created.
    - If there are fewer than two messages, no average will be calculated.

.EXAMPLE
    # Set the log file path and run the script
    $logfilepath = "C:\Logs\mylog.txt"
    .\processing-time-v2.ps1

#>


$logfilepath = ""
$csvOutput = "$env:USERPROFILE\Desktop\ProcessingTimeReport.csv"


if (-not (Test-Path -Path $logFilePath)) {
    New-Item -ItemType File -Path $logFilePath -Force
}

# Read the log file
$lines = Get-Content -Path $logfilepath

$timestamps = @()

# Look for lines with "New message received" and extract ISO timestamps
foreach ($line in $lines) {
    if ($line -match "MESSAGEREADER: New message received" -and $line -match '"time":"([^"]+)"') {
        $timestampStr = $matches[1]
        try {
            $dt = [datetime]::Parse($timestampStr)
            $timestamps += $dt
        }
        catch {
            Write-Warning "Failed to parse: $timestampStr"
        }
    }
}

# Calculate time differences
for ($i = 1; $i -lt $timestamps.Count; $i++) {
    $start = $timestamps[$i - 1]
    $end = $timestamps[$i]
    $delta = $end - $start

    Write-Output "Message $($i - 1) to $i{}: $($delta.TotalSeconds) seconds"
}

if ($timestamps.Count -gt 1) {
    $totalSeconds = 0
    for ($i = 1; $i -lt $timestamps.Count; $i++) {
        $totalSeconds += ($timestamps[$i] - $timestamps[$i - 1]).TotalSeconds
    }
    $averageSeconds = $totalSeconds / ($timestamps.Count - 1)
    Write-Output "Average time between messages: $averageSeconds seconds"

    [PSCustomObject]@{
        LogFileName          = [System.IO.Path]::GetFileName($logFilePath) + " - name here"
        AverageTimeInSeconds = $averageSeconds
        TotalMessages        = $timestamps.Count
    } | Export-Csv -Path $csvOutput -NoTypeInformation -Encoding UTF8 -Append

}
else {
    Write-Output "Not enough messages to calculate time differences."
}







