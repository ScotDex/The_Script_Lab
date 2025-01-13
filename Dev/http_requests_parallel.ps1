function Log-Message {
    param (
        [string]
    )
    
    \ = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    \ = "\ - \"
    Add-Content -Path "http_requests_log.txt" -Value \
    Write-Output \
}

function Send-HttpRequest {
    param (
        [string],
        [int]
    )
    
    Log-Message "Sending request \ to \"
    
    try {
        \ = Invoke-WebRequest -Uri \ -Method GET -ErrorAction Stop
        Log-Message "Request \ succeeded: \"
    } catch {
        Log-Message "Request \ failed: \"
    }
}
