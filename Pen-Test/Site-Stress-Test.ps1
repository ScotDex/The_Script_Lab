# For authorized testing only. See README.md for ethical use guidelines.
$targetURL = "tsg.com"
$requestCount = 10000
$MaxThreads = 505

$RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads)
$RunspacePool.Open()
$Jobs = @()

$progress = 0
$progressIncrement = [math]::round(100 / $requestCount, 2)


for ($i = 1; $i -le $requestCount; $i++) {
    $Runspace = [powershell]::Create().AddScript({
        param ($targetURL, $i)
        try {
            $StartTime = Get-Date
            $response = Invoke-WebRequest -Uri $targetURL -Method Get -UseBasicParsing -TimeoutSec 10
            $EndTime = Get-Date
            $duration = ($EndTime - $StartTime).totalmilliseconds
            Write-Host "Request $i completed in $duration ms"

            # Track response times
            $script:responseTimes += $duration

            # Check if response time exceeds the slow threshold
            if ($duration -gt $script:slowThreshold) {
                Write-Host "Warning: Request $i is slow ($duration ms)."
            }

        } catch {
            # Catching different types of errors
            if ($_.Exception -is [System.Net.WebException]) {
                Write-Host "Request $i failed: WebException - Website might be unreachable."
            } elseif ($_.Exception -is [System.TimeoutException]) {
                Write-Host "Request $i failed: TimeoutException - The request timed out."
            } else {
                Write-Host "Request $i failed: $_"
            }
            $duration = 0
        }
    }).AddArgument($targetURL).AddArgument($i)

    $Runspace.RunspacePool = $RunspacePool
    $Jobs += @{pipe = $Runspace; status = $Runspace.BeginInvoke()}

    # Update progress bar
    $progress = $progress + $progressIncrement
    Write-Progress -PercentComplete $progress -Status "Requesting..." -Activity "Request $i of $requestCount"
}

# Wait for all requests to complete
$completedJobs = 0
foreach ($Job in $Jobs) {
    $Job.Pipe.EndInvoke($Job.Status)
    $Job.Pipe.Dispose()
    $completedJobs++
    
    # Update the progress bar after each job finishes
    $progress = ($completedJobs / $requestCount) * 100
    Write-Progress -PercentComplete $progress -Status "Waiting for requests to complete..." -Activity "Completed $completedJobs of $requestCount"
}

# Finalize progress bar
Write-Progress -PercentComplete 100 -Status "All requests completed." -Activity "Stress test completed"

$RunspacePool.Close()
$RunspacePool.Dispose()

Write-Host "Stress test completed."
