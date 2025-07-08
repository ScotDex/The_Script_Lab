

# It was recently found that multiple enviroments that I came across had customized .env files which subsequently either caused issues 
# or cost time by having to manually rename files to fit the naming convention - as a result this script was created to take the name of the
# .pem file and re-write the .env file - which leads to a uniform naming convention across all environments and saves time and potential human errors.
# To be left available when SSL replacements come along  - test


# Procedure to update the .env file with the name of the .pem file
# This script updates the FHIR_INTEGRATION_API_GATEWAY_HTTPS_CERTIFICATE key in the .env file with the name of the first .pem file found in the current directory.
# So this is currently to replace server .pem files as it stands, potentially looking to expand/change to allow user entry to select parameters to update in the future.
# Usage: Run this script in the directory containing the .env file and the .pem file.

# Get current script directory
$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Get-Location }

# Path to .env
$envPath = Join-Path $scriptDir ".env"
$mapPath = join-path $scriptDir "cert-map.json"

if (-not (Test-Path $mapPath)) {
    write-error "❌ cert-map.json not found in the script directory!"
    exit 1
}

$pemMap = Get-Content $mapPath | ConvertFrom-Json

# Verify all mapped files exist and build update list
$updates = @()

foreach ($pair in $pemMap.PSObject.Properties) {
    $filename = $pair.Name
    $envKey   = $pair.Value
    $fullPath = Join-Path $scriptDir $filename

    if (Test-Path $fullPath) {
        Write-Host "🔁 Will update $envKey => $filename"
        $updates += [PSCustomObject]@{
            EnvKey  = $envKey
            NewPath = $filename
        }
    } else {
        Write-Warning "❌ File '$filename' not found. Skipping..."
    }
}

if ($updates.Count -eq 0) {
    Write-Warning "No matching files found. Nothing to update."
    exit
}

# Read and update .env
$envLines = Get-Content $envPath
$updatedLines = @()

foreach ($line in $envLines) {
    $matched = $false

    foreach ($update in $updates) {
        if ($line -match "^\s*$($update.EnvKey)\s*=") {
            $updatedLines += "$($update.EnvKey)=$($update.NewPath)"
            Write-Host "✅ Updated: $($update.EnvKey) => $($update.NewPath)"
            $matched = $true
            break
        }
    }

    if (-not $matched) {
        $updatedLines += $line
    }
}

# Write updated .env
$updatedLines | Set-Content -Path $envPath
Write-Host "`n✅ .env updated successfully." -ForegroundColor Green


