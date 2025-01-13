# How many threads do you want to use?

$threads = 8

# how long do you want the calculation to work for (in seconds)

$duration = 30

# Readout

Write-Host "Stress test starting - firing with $threads for $duration" -ForegroundColor Yellow

# Start calculations

$tasks = @()
for ($i = 1; $i -le $threads; $i++) {
    $tasks += Start-Job -ScriptBlock {
        $endtime = (get-date).AddSeconds($using:duration)
        while ((Get-Date) -lt $endtime) {
            [math]::Pow(2, 50) > $null  # Perform a CPU-intensive 
calculation
        }
    }
}

$tasks | Wait-Job
Write-Host "Stress Test Complete"