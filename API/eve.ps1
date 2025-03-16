

# $username="admin"
# $password="password"
# $credentials = "{$username}:{$password}"
# $credentialBytes = [System.Text.Encoding]::ASCII.GetBytes($credentials)
# $base64AuthInfo = [Convert]::ToBase64String(($credentialBytes))
# $basicAuthHeader = "Basic " + $base64AuthInfo

# The block of code above is used to create a basic authentication header for any api request

# The code below is used to authenticate with the EVE Online API using OAuth2
# The code is based on the example provided in the EVE Online documentation: https://esi.evetech.net/ui/?version=latest#/Character/get_characters_character_id
$clientID="539efdfedabe4ca19575d01b6ae5ba8e"
$clientSecret="xBMQMOOZVxfQI8RQPSjKEKXvqsdJKybv8UceDZjY"
$redirectUri="https://cce5-31-111-83-157.ngrok-free.app"
$scopes = "publicData"
$state = [Guid]::NewGuid().ToString() # Generate a random state value
$tokenUri = "https://login.eveonline.com/oauth/token"
$authUrl = "https://login.eveonline.com/oauth/authorize?response_type=code&redirect_uri=$redirectUri&client_id=$clientID&scope=$scopes&state=$state"
Write-Host "Please visit this URL to authenticate: $authUrl"

$authorizationCode = "8r0Q7Owge5V4VHzNpm1BaGfmyaS47mRXVTDkomRsi-QzZKC1bramNhFMW1Lo-qpA"


$body = @{
    grant_type    = "authorization_code"
    code          = $authorizationCode
    redirect_uri  = $redirectUri
    client_id     = $clientID
    client_secret = $clientSecret
}
$response = Invoke-RestMethod -Uri $tokenUri -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
$response

$accessToken = $response.access_token
Write-Host "Access Token: $accessToken"

$uri = "https://esi.evetech.net/latest/characters/95282689/"
$characterInfo = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

$characterInfo

$accessToken = $response.access_token

$headers = @{
    Authorization = "Bearer $accessToken"
    "Content-Type"="application/json"
}


$uri = "https://esi.evetech.net/latest/characters/95282689/"
$characterInfo = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

$characterInfo

# Assuming $listener is your active HttpListener object


# $urlbase = "https://api.example.com" # The base url of the api
# $uri = $urlbase + "/endpoint" # The endpoint of the api

# $headers = @{ 
#     Authorization=$basicAuthHeader
#     "Content-Type"="application/json"
# }

# Invoke-RestMethod -Uri "$urlbase/" -Headers $headers -Method Get


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


# param (
#     [Parameter(Mandatory=$true)]
#     [string]$TargetURL,

#     [Parameter(Mandatory=$true)]
#     [hashtable]$Headers,

#     [Parameter(Mandatory=$true)]
#     [string]$Payload
# )

# $Body = @{ "query" = $Payload } | ConvertTo-Json
# Write-Host "[*] Sending large payload to $TargetURL..."
# Invoke-WebRequest -Uri $TargetURL -Method POST -Headers $Headers -Body $Body -TimeoutSec 10


