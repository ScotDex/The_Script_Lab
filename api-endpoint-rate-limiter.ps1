$TargetURL = ""
$Endpoints = @("/api/v1/", "/api/v2/", "/login", "/register", "/admin", "/users", "/search", "/health", "/status")
$LogFile = "API-Rate-Limit-Test.log"
$Delay = 1 # Delay in seconds between requests
$Headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
}

foreach ($Endpoint in $Endpoints) {
    $FullURL = "$TargetURL$Endpoint"
    try {
        $Response = Invoke-WebRequest -Uri $FullURL -Headers $Headers -UseBasicParsing -TimeoutSec 5
        if ($Response.StatusCode -eq 200) {
            Write-Host "[+] Found: $FullURL" -ForegroundColor Green
            Add-Content -Path $LogFile -Value "[+] Found: $FullURL"
        } else {
            Write-Host "[-] No response: $FullURL"
            Add-Content -Path $LogFile -Value "[-] No response: $FullURL"
        }
    } catch {
        Write-Host "[-] Failed: $FullURL"
        Add-Content -Path $LogFile -Value "[-] Failed: $FullURL"
    }
    Start-Sleep -Seconds $Delay
}
