$baseUrl = ""
$payloads = @(
    "<script>alert(1)</script>"
)

foreach ($payload in $payloads) {
    $url = $baseUrl + [uri]::EscapeDataString($payload)
    Write-Host "Testing: $payload"

    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✔️  Response 200 OK - Payload sent."
            if ($response.Content -like "*alert(1)*" -or $response.Content -like "*script*") {
                Write-Warning "⚠️  Potentially vulnerable to XSS with: $payload"
            }
        }
    } catch {
        Write-Host "❌ Request failed: $($_.Exception.Message)"
    }

    Start-Sleep -Milliseconds 300
}


Start-Process ".\response.html"


$uri = "https://halo.tsg.com/status"
$body = @{
    email = $env:TEST_EMAIL
    password = $env:TEST_PASSWORD
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType 'application/json' -ErrorAction Stop

