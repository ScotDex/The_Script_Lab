# Load the .env file to get the expected certificate names
$envFilePath = "C:\path\to\.env"

# Parse the .env file into a hashtable
$envVariables = @{}
Get-Content $envFilePath | ForEach-Object {
    if ($_ -match "^(.*?)=(.*)$") {
        $envVariables[$matches[1]] = $matches[2]
    }
}

# Directory where the SSL certificates are located (adjust the path)
$certDirectory = "C:\path\to\certificates"

# Define the current certificate file names (e.g., fetched remotely)
$currentCertFile = "$certDirectory\current_cert.pem"
$currentKeyFile = "$certDirectory\current_key.pem"

# Get the expected certificate names from the .env variables
$expectedCertName = $envVariables["SSL_CERT_NAME"]
$expectedKeyName = $envVariables["SSL_KEY_NAME"]

# Check if the current certificate and key files exist
if (Test-Path $currentCertFile -and Test-Path $currentKeyFile) {
    Write-Host "Certificate files found. Renaming..."

    # Rename the certificate and key files
    Rename-Item $currentCertFile -NewName "$certDirectory\$expectedCertName.pem"
    Rename-Item $currentKeyFile -NewName "$certDirectory\$expectedKeyName.pem"

    Write-Host "Certificate files renamed to match .env expectations."
} else {
    Write-Host "Error: SSL certificate or key file not found."
    exit 1
}

# Optional: Restart the service or container to apply the new certs
Write-Host "Restarting the service/container to apply the new certificates..."
# Restart-Service -Name "Your-Service-Name"  # Uncomment and adjust as per your environment

Write-Host "Process completed successfully."
