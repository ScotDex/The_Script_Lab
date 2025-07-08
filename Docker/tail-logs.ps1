<#
.SYNOPSIS
    Tails and saves the last N lines of logs from a running Docker container to a timestamped file.

.DESCRIPTION
    This script prompts the user for a Docker container name or ID and the number of log lines to retrieve (default is 20).
    It checks if Docker is installed and if the specified container is running.
    The script then saves the last N lines of logs from the container to a UTF-8 encoded, timestamped log file in the script directory.

.PARAMETER ContainerName
    The name or ID of the Docker container to retrieve logs from.

.PARAMETER TailLines
    The number of log lines to retrieve from the container. Defaults to 20 if not specified or invalid input.

.INPUTS
    Prompts the user for the container name or ID and the number of log lines to show.

.OUTPUTS
    Writes the retrieved log lines to a timestamped text file in the script directory.

.NOTES
    - Requires Docker to be installed and available in the system PATH.
    - Only works for running containers.
    - The log file is saved with the format: <ContainerName>-logs-<yyyyMMdd_HHmmss>.txt

.EXAMPLE
    PS> .\tail-logs.ps1
    Please enter the container name or ID: my_container
    Enter number of log lines to show (default is 20): 50
    Saving last 50 lines of logs from 'my_container' to 'my_container-logs-20240607_153000.txt'...
#>
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $scriptDir "$ContainerName-logs-$timestamp.txt"
$containerName = Read-Host "Please enter the container name or ID"


# Prompt user for number of lines to tail
$TailLinesInput = Read-Host "Enter number of log lines to show (default is 20)"
if (-not [int]::TryParse($TailLinesInput, [ref]$null)) {
    $TailLines = 20
} else {
    $TailLines = [int]$TailLinesInput
}



# Error Handling Block
#================

# Check if Docker is installed and available in PATH
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not in PATH."
    exit 1
}
# Validate the container name or ID
$container = docker ps --format "{{.Names}}" | Where-Object { $_ -eq $ContainerName }
if (-not $container) {
    Write-Error "Container '$ContainerName' is not running."
    exit 1
}

#===============


# Saves log sample for examination
Write-Host "Saving last $TailLines lines of logs from '$ContainerName' to '$logFile'..."
docker logs --tail $TailLines $ContainerName | Out-File -Encoding UTF8 $logFile