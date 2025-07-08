
<#
.SYNOPSIS
    Processes a log file to calculate time differences between message events and exports summary statistics to an Excel file.

.DESCRIPTION
    This script reads a specified log file, extracts ISO timestamps from lines containing "MESSAGEREADER: New message received", 
    calculates the time differences between consecutive messages, and computes the average time between messages. 
    The results are exported to an Excel file as a summary table using the ImportExcel module.

.PARAMETER logfilepath
    The path to the log file to be processed. Must be set before running the script.

.PARAMETER excelOutput
    The path where the Excel summary report will be saved. Defaults to the user's Desktop as "PivotReport.xlsx".

.NOTES
    - Requires the ImportExcel PowerShell module.
    - The log file must contain lines with the pattern: MESSAGEREADER: New message received and a "time" field in ISO format.
    - If the Excel output file does not exist, it will be created.
    - The script outputs warnings for any timestamps that cannot be parsed.

.OUTPUTS
    - Writes time differences and average time between messages to the console.
    - Generates an Excel file with a summary table containing the log file name, average time in seconds, and total messages.

.EXAMPLE
    # Set the log file path and run the script
    $logfilepath = "C:\Logs\messages.log"
    .\processing-time-v1.ps1

#>

Import-Module ImportExcel

$logfilepath = ""
$excelOutput = "$env:USERPROFILE\Desktop\PivotReport.xlsx"

if (-not (Test-Path -Path $excelOutput)) {
    New-Item -ItemType File -Path $excelOutput -Force
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

    $data = @(
        [PSCustomObject]@{
            LogFileName          = [System.IO.Path]::GetFileName($logFilePath) + " - Test Data Table "
            AverageTimeInSeconds = $averageSeconds
            TotalMessages        = $timestamps.Count
        }
    )

    $data | Export-Excel -Path $excelOutput -AutoNameRange -Show -PivotRows $averageSeconds -PivotColumns $totalSeconds -PivotData $timestamps.Count -WorksheetName "Summary" -TableName "SummaryTable" -AutoSize
    Write-Host "Pivot Table Generated and saved to $excelOutput"

}
else {
    Write-Output "Not enough messages to calculate time differences."
}