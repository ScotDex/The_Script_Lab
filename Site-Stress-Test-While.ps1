<#
.SYNOPSIS
    This script performs a stress test on a specified web site by sending multiple concurrent requests in a loop.

.DESCRIPTION
    The script uses PowerShell runspaces to create a pool of threads for sending HTTP GET requests to a target URL.
    It continuously sends 5000 requests per cycle using a maximum of 500 concurrent threads.

.PARAMETER targetURL
    The URL of the web site to be stress tested.

.PARAMETER MaxThreads
    The maximum number of concurrent threads to be used for sending requests. Default is 20, but it is overridden to 500.

.NOTES
    The script runs indefinitely in a while loop until manually stopped.
    It uses Invoke-WebRequest to send HTTP GET requests and handles any exceptions silently.

.EXAMPLE
    .\web-site-stress-test-while-loop.ps1 -targetURL "http://example.com"
    This command runs the stress test on "http://example.com" using the default settings.
#>

$targetURL = ""
$MaxThreads = 20

$RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads)
$RunspacePool.Open()
$Jobs = @()

$MaxThreads = 500
$RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads)
$RunspacePool.Open()

while ($true) {
    $Jobs = @()
    for ($i = 1; $i -le 5000; $i++) {  # 5000 requests per cycle
        $Runspace = [powershell]::Create().AddScript({
            param ($targetURL, $i)
            try {
                Invoke-WebRequest -Uri $targetURL -Method Get -UseBasicParsing -TimeoutSec 10
            } catch {}
        }).AddArgument($targetURL).AddArgument($i)
        
        $Runspace.RunspacePool = $RunspacePool
        $Jobs += @{pipe = $Runspace; status = $Runspace.BeginInvoke()}
    }

    foreach ($Job in $Jobs) {
        $Job.Pipe.EndInvoke($Job.Status)
        $Job.Pipe.Dispose()
    }
}