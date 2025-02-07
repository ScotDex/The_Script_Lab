<#
.SYNOPSIS
    This script automates the backup and deployment of SSL certificates for a Docker container.
    Just looking at potentially automating SSL certificate updates for a Docker container.
.DESCRIPTION
    The script performs the following tasks:
    1. Sets the execution policy to bypass for the current process.
    2. Defines paths and variables for SSL directories, Docker container, and backup folder.
    3. Creates a backup folder with a timestamp.
    4. Copies existing .env, docker-compose.yml, jwt, and ssl files to the backup folder.
    5. Checks for new SSL certificates in a specified Google Cloud Storage bucket.
    6. Downloads the latest SSL certificates from the bucket to a temporary directory.
    7. Compares the downloaded certificates with the existing ones.
    8. If new certificates are detected, replaces the old ones and restarts the Docker container.
    9. If no changes are detected, skips the restart.

.PARAMETER bucketName
    The name of the Google Cloud Storage bucket where the SSL certificates are stored.

.PARAMETER localSslDir
    The local directory where the SSL certificates are mounted.

.PARAMETER tempSslDir
    The temporary directory for downloading the SSL certificates.

.PARAMETER dockerContainer
    The name of the Docker container to restart after updating the SSL certificates.

.PARAMETER scriptPath
    The path of the current script.

.PARAMETER backupFolder
    The path of the backup folder where existing files are copied.

.PARAMETER timestamp
    The current date and time in "yyyyMMdd_HHmmss" format, used for naming the backup folder.

.EXAMPLE
    .\master-script.ps1
    This will execute the script and perform the backup and SSL certificate update process.

.NOTES
    Ensure that the Google Cloud SDK is installed and configured with the necessary permissions to access the specified bucket.
    Adjust the localSslDir variable to match the actual mounted SSL directory on your system.
#>


# Bypass the execution policy for the current process to allow the script to run without restrictions
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

$bucketName = "your-ssl-bucket"
$localSslDir = "C:\docker\ssl"  # Adjust this to your actual mounted SSL directory
$tempSslDir = "C:\Temp\ssl_download"
$dockerContainer = "fhir-appliance"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFolder = Join-Path -Path $scriptPath -ChildPath "BackupFolder $timestamp"


New-Item -ItemType Directory -Path $backupFolder -Force

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath '.env' ) -destination $backupFolder

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'docker-compose.yml' ) -destination $backupFolder

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'jwt' ) -destination $backupFolder -Recurse

Copy-Item -Path (Join-Path -Path $scriptPath -ChildPath 'ssl' ) -destination $backupFolder -Recurse

Write-Host "Backup of Existing Certificates complete and docker .env and compose file, inspect in $backupFolder"

# Ensure temp directory exists
if (!(Test-Path $tempSslDir)) {
    New-Item -ItemType Directory -Path $tempSslDir | Out-Null
}

# Check if Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker is not installed. Please install Docker and try again." -ForegroundColor Red
    exit 1
}

# Check if Docker container is running
$containerStatus = docker inspect -f '{{.State.Running}}' $dockerContainer 2>$null
if ($containerStatus -ne "true") {
    Write-Host "❌ Docker container '$dockerContainer' is not running. Please start the container and try again." -ForegroundColor Red
    exit 1
}

Write-Host "🔍 Checking for new SSL certificates from GCP..."

# Download latest SSL certs from GCP Storage
& gcloud storage cp "gs://$bucketName/fullchain.pem" "$tempSslDir\fullchain.pem" --quiet
# Compare file sizes to check if certs have changed
$remoteSize = (Get-Item "$tempSslDir\fullchain.pem").Length
$localSize = (Get-Item "$localSslDir\fullchain.pem").Length

if ($remoteSize -ne $localSize) {
    Write-Host "⚡ New SSL certificate detected! Overwriting..."
    $remoteHash = (Get-FileHash "$tempSslDir\fullchain.pem" -Algorithm SHA256).Hash
    $localHash = (Get-FileHash "$localSslDir\fullchain.pem" -Algorithm SHA256).Hash

    if ($remoteHash -ne $localHash) {
        # Replace certificates
        Move-Item -Path "$tempSslDir\fullchain.pem" -Destination "$localSslDir\fullchain.pem" -Force
        Move-Item -Path "$tempSslDir\privkey.pem" -Destination "$localSslDir\privkey.pem" -Force

        Write-Host "🔄 Restarting Docker container: $dockerContainer..."
        docker restart $dockerContainer

        Write-Host "✅ SSL update complete!" -ForegroundColor Green
    } else {
        Write-Host "✅ No changes detected. Skipping restart." -ForegroundColor Cyan
} else {
    Write-Host "✅ No changes detected. Skipping restart." -ForegroundColor Cyan
}
    Write-Host "⚡ New SSL certificate detected! Overwriting..."
    
    # Replace certificates
    Move-Item -Path "$tempSslDir\fullchain.pem" -Destination "$localSslDir\fullchain.pem" -Force
    Move-Item -Path "$tempSslDir\privkey.pem" -Destination "$localSslDir\privkey.pem" -Force

    Write-Host "🔄 Restarting Docker container: $dockerContainer..."
    docker restart $dockerContainer

    Write-Host "✅ SSL update complete!" -ForegroundColor Green
} else {
    Write-Host "✅ No changes detected. Skipping restart." -ForegroundColor Cyan
}

