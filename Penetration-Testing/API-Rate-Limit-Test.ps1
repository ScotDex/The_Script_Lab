$TargetURL = "halo.tsg.com"
$Endpoints = @("/api/v1/", "/api/v2/", "/login", "/register", "/admin", "/users", "/search", "/health", "/status")

foreach ($Endpoint in $Endpoints) {
    $FullURL = "$TargetURL$Endpoint"
    try {
        $Response = Invoke-WebRequest -Uri $FullURL -UseBasicParsing -TimeoutSec 5
        if ($Response.StatusCode -eq 200) {
            Write-Host "[+] Found: $FullURL" -ForegroundColor Green
        } else {
            Write-Host "[-] No response: $FullURL"
        }
    } catch {
        Write-Host "[-] Failed: $FullURL"
    }
}
