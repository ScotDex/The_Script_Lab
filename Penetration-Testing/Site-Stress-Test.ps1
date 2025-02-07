<#
.SYNOPSIS
    Performs a stress test on a specified target URL by sending multiple HTTP GET requests concurrently.

.DESCRIPTION
    This script sends a specified number of HTTP GET requests to a target URL using multiple threads to simulate a stress test.
    It measures the time taken for each request and logs the result.

.PARAMETER targetURL
    The URL to which the HTTP GET requests will be sent.

.PARAMETER requestCount
    The total number of HTTP GET requests to be sent during the stress test. Default is 1000.

.PARAMETER MaxThreads
    The maximum number of concurrent threads to be used for sending requests. Default is 20.

.NOTES
    The script uses runspaces to achieve concurrency and measures the duration of each request.
    If a request fails, it logs the failure and continues with the next request.

.EXAMPLE
    .\stresstest.ps1 -targetURL "http://example.com" -requestCount 500 -MaxThreads 10
    This example sends 500 HTTP GET requests to "http://example.com" using up to 10 concurrent threads.

#>
$targetURL = ""
$requestCount = 1000
$MaxThreads = 20

$RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads)
$RunspacePool.Open()
$Jobs = @()

for ($i = 1; $i -le $requestCount; $i++) {
    $Runspace = [powershell]::Create().AddScript({
        param ($targetURL, $i)
        try {
            $StartTime = Get-Date
            Invoke-WebRequest -Uri $targetURL -Method Get -UseBasicParsing -TimeoutSec 10
            $EndTime = Get-Date
            $duration = ($EndTime - $StartTime).totalmilliseconds
            Write-Host "Request $i completed in $duration ms"
        } catch {
            $duration = 0
            Write-Host "Request $i failed"
        }
    }).AddArgument($targetURL).AddArgument($i)

    $Runspace.RunspacePool = $RunspacePool
    $Jobs += @{pipe = $Runspace; status = $Runspace.BeginInvoke()}
}

# Write-Host "Waiting for all requests to complete..."
foreach ($Job in $Jobs) {
    $Job.Pipe.EndInvoke($Job.Status)
    $Job.Pipe.Dispose()
}

$RunspacePool.Close()
$RunspacePool.Dispose()
# Write-Host "Stress test completed."