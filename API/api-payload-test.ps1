<#
.SYNOPSIS
    Sends a large payload to a specified target URL using an HTTP POST request.

.DESCRIPTION
    This script constructs a large payload of 1MB size and sends it to the specified target URL using an HTTP POST request.
    The payload is sent as a JSON object with a single key "query" containing the large payload.
    The request includes custom headers for User-Agent and Content-Type.

.PARAMETER TargetURL
    The URL to which the payload will be sent.

.PARAMETER Headers
    A hashtable containing the headers to be included in the HTTP request.
    - User-Agent: Specifies the user agent string.
    - Content-Type: Specifies the content type of the request body.

.PARAMETER Payload
    The large payload to be sent in the request body. In this case, it is 1MB of "A".

.PARAMETER Body
    The JSON object containing the payload to be sent in the request body.

.EXAMPLE
    .\test.ps1
    Sends a 1MB payload to the specified target URL with the defined headers.

.NOTES
    Ensure that the target URL is correct and that the server is configured to handle large payloads.
    The script uses a timeout of 10 seconds for the request.
#>
$TargetURL = ""
$Headers = @{ "User-Agent" = "Mozilla/5.0"; "Content-Type" = "application/json" }
$Payload = "A" * 1048576  # 1MB of "A"

$Body = @{ "query" = $Payload } | ConvertTo-Json
Write-Host "[*] Sending large payload..."
Invoke-WebRequest -Uri $TargetURL -Method POST -Headers $Headers -Body $Body -TimeoutSec 10
