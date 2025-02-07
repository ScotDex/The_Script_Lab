<#
.SYNOPSIS
  Creates a backup of existing certificates and Docker environment files.

.DESCRIPTION
  This script sets the execution policy to RemoteSigned, creates a timestamped backup folder, 
  and copies the .env file, docker-compose.yml file, and the 'jwt' and 'ssl' directories 
  into the backup folder.

.PARAMETER None
  This script does not take any parameters.

.OUTPUTS
  None

.NOTES
  The script creates a backup folder with a timestamp in its name and copies the specified files 
  and directories into it. The backup folder is located in the same directory as the script.

.EXAMPLE
  To run the script, execute the following command in PowerShell:
  .\replication-script.ps1

  This will create a backup folder and copy the necessary files and directories into it.

#>

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

try {
    $scriptPath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

    $backupFolder = Join-Path -Path $scriptPath -ChildPath "BackupFolder $timestamp"

    if (-Not (Test-Path -Path $backupFolder)) {
        New-Item -ItemType Directory -Path $backupFolder -Force
    }

    $filesToCopy = @('.env', 'docker-compose.yml', 'jwt', 'ssl')

    foreach ($file in $filesToCopy) {
        $sourcePath = Join-Path -Path $scriptPath -ChildPath $file

        if (Test-Path -Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination $backupFolder -Recurse -Force
        } else {
            Write-Warning "The path $sourcePath does not exist and will not be copied."
        }
    }

    Write-Host "Backup of Existing Certificates complete and docker .env and compose file, inspect in $backupFolder"
} catch {
    Write-Error "An error occurred: $_"
}