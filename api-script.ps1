# Description: This script is used to make a GET request to an API endpoint with basic authentication.
# Usage: powershell -File api-script.ps1

$username="admin"
$password="password"
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


# Partial code for oauth2 authentication
# $uri = "https://api.example.com"

#$body = @{
#"client_id"="value1"
#"client_secret"="value2"
#} | ConvertTo-Json

#$headers = @{
#    Authorization = "bearer $accesstoken"
#    "Content-Type"="application/json"
#}
#Invoke-RestMethod -Uri $uri -Headers $headers -Method Get


