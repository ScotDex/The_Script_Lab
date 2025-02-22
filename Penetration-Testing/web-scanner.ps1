<#
.SYNOPSIS
    Scans a target URL for common security risks and vulnerabilities.

.DESCRIPTION
    This script performs a security scan on a specified target URL by checking for the presence of common sensitive files and endpoints, 
    verifying the existence of important security headers, checking for weak CORS policies, and testing for open redirects.

.PARAMETER TargetURL
    The base URL of the target website to be scanned.

.PARAMETER Endpoints
    An array of common sensitive files and endpoints to check for exposure.

.PARAMETER Headers
    HTTP headers to include in the requests, such as User-Agent.

.PARAMETER Findings
    An array to store the results of the scan, including exposed endpoints and missing security headers.

.PARAMETER MissingHeaders
    An array to store the names of missing security headers.

.PARAMETER SecurityHeaders
    An array of important security headers to check for.

.PARAMETER RedirectTestURL
    A URL used to test for open redirects.

.EXAMPLE
    .\synanetics.ps1
    This command runs the script and scans the default target URL (https://synanetics.com) for security risks.

#>
$TargetURL = ""
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
    Invoke-WebRequest -Uri $RedirectTestURL -Headers $Headers -TimeoutSec 5 -MaximumRedirection 0
} catch {
    if ($_.Exception.Response.StatusCode -eq 302) {
        Write-Host "[!] Possible Open Redirect at $RedirectTestURL" -ForegroundColor Red
        $MissingHeaders += "[!] Open Redirect Found: $RedirectTestURL"
    }
}

# Save Findings to File
$Findings | Out-File -FilePath "WebScan_Report.txt"
Write-Host "`n[*] Scan Completed. Report saved to WebScan_Report.txt" -ForegroundColor Cyan