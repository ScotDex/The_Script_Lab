# Description: This script is used to make a GET request to an API endpoint with basic authentication.
# Usage: powershell -File api-script.ps1

$username = $env:API_USERNAME
$password = $env:API_PASSWORD
$credentials = "{$username}:{$password}"
$credentialBytes = [System.Text.Encoding]::ASCII.GetBytes($credentials)
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentialBytes))
$basicAuthHeader = "Basic " + $base64AuthInfo

$urlbase = "https://api.example.com"
# $uri = $urlbase + "/endpoint"

$headers = @{ 
    Authorization=$basicAuthHeader
    "Content-Type"="application/json"
}
Invoke-RestMethod -Uri "$urlbase/" -Headers $headers -Method Get
