# This script downloads the latest EVE Online Static Data Export (SDE) from the official URL and extracts it to a specified directory.
# It requires PowerShell 5.0 or later to run.
$Url = "https://eve-static-data-export.s3-eu-west-1.amazonaws.com/tranquility/sde.zip"
$DownloadPath = "C:\Downloads\SDE"

if (-not (Test-Path -Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath | Out-Null
}

try {
    Invoke-WebRequest -Uri $Url -OutFile $DownloadPath\sde.zip
}
catch {
    Write-Error "Failed to retrieve the web page: $_"
    exit 1
}
# Unzip the downloaded file
try {
    Expand-Archive -Path "$DownloadPath\sde.zip" -DestinationPath $DownloadPath -Force
} catch {
    Write-Error "Failed to unzip the file: $_"
    exit 1
}   
# Clean up the zip file after extraction
Remove-Item -Path "$DownloadPath\sde.zip" -Force
Write-Host "Download completed. Files saved to $DownloadPath"