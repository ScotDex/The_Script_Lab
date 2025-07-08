<#
.SYNOPSIS
    Converts the latest EVE Online fleet loot log text file to a CSV file on the user's desktop.

.DESCRIPTION
    This script locates the most recent "Loot - *.txt" file in the EVE Online Fleetlogs directory,
    converts its tab-delimited content to CSV format, and saves the resulting file to the user's desktop.
    The output CSV file is named after the input text file, with a .csv extension.

.PARAMETER None
    The script does not accept parameters; it automatically determines the current user and file paths.

.NOTES
    - Assumes the EVE Online Fleetlogs directory and loot log files exist.
    - Requires appropriate permissions to read from the Fleetlogs directory and write to the desktop.

.EXAMPLE
    # Run the script to convert the latest loot log to CSV:
    .\loot-sheet-retrieval.ps1

    # Output:
    CSV file generated: C:\Users\<UserName>\Desktop\Loot - <date>.csv

#>
# Get the username of the current user
$userName = $env:USERNAME

# Get the path to the user's desktop directory
$desktopPath = "C:\Users\$userName\Desktop"

# Set the path to the directory where your text files are located
$directoryPath = "C:\Users\$userName\Documents\EVE\logs\Fleetlogs\"

# Get the latest text file in the directory
$latestFile = Get-ChildItem -Path $directoryPath -Filter "Loot - *.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Check if a file was found
if ($latestFile) {
    # Set the path to the latest input text file
    $txtFilePath = $latestFile.FullName

    # Generate the output CSV file name based on the input file name
    $csvFileName = $latestFile.Name -replace '\.txt$', '.csv'
    $csvFilePath = Join-Path -Path $desktopPath -ChildPath $csvFileName

    # Read the content of the text file and convert it to CSV
    Get-Content -Path $txtFilePath | ConvertFrom-Csv -Delimiter "`t" | Export-Csv -Path $csvFilePath -NoTypeInformation

    Write-Host "CSV file generated: $csvFilePath"
} else {
    Write-Host "No text files found in the directory: $directoryPath"
}
