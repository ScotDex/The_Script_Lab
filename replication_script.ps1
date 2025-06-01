
# This script is designed to back up specific files and directories related to SSL management.
# It creates a backup folder with a timestamp and copies the specified items into it.

try {
  
  # =====================
  # Variables

  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
  $scriptPath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
  $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $backupFolder = Join-Path -Path $scriptPath -ChildPath "BackupFolder $timestamp"

  New-Item -ItemType Directory -Path $backupFolder -Force
 # =====================

$itemsToBackup = @( # List of items to back up - add/remove as needed
    'docker-compose.yml',
    '.env',
    'jwt',
    'ssl'

)

foreach ($item in $itemsToBackup) {
  $source = Join-Path -Path $scriptPath -ChildPath $item
  if (Test-Path -Path $source) {
      $destination = Join-Path -Path $backupFolder -ChildPath $item
      $isDirectory = (Get-Item $source).PSIsContainer

      Copy-Item -Path $source -Destination $destination -Recurse:$isDirectory -ErrorAction Stop

      Write-Host "✅ Backed up '$item'"
  } else {
      Write-Warning "⚠️ '$item' does not exist and was skipped."
  }
} catch {
  Write-Error "❌ An error occurred: $_"
} 
}
finally {
  Write-Host "Backup completed. Backup folder: $backupFolder"
}