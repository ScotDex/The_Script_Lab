function Get-AllFolderSizes {
    param([string]$Path = "C:\") # edit to decide which drive you want to scan

    Write-Host "Scanning all folders in $Path... This may take a while." -ForegroundColor Cyan

    $folders = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue # add -recurse if you want to scan all subfolders
    $folderSizes = [System.Collections.ArrayList]::new()

    # Define the RunspacePool
    $RunspacePool = [runspacefactory]::CreateRunspacePool(1, [environment]::ProcessorCount)
    $RunspacePool.Open()
    $totalFolders = $folders.Count
    $processed = 0
    $Jobs = @()

    foreach ($folder in $folders) {
        $Runspace = [powershell]::Create().AddScript({
            param ($FolderPath)

            $size = Get-ChildItem -Path $FolderPath -Recurse -ErrorAction SilentlyContinue |
                    Where-Object { -not $_.PSIsContainer } |
                    Measure-Object -Property Length -Sum
            
            [PSCustomObject]@{
                Folder = $FolderPath
                SizeGB = [math]::Round($size.Sum / 1GB, 2)
            }
        }).AddArgument($folder.FullName)

        $Runspace.RunspacePool = $RunspacePool
        $Jobs += @{Pipe = $Runspace; Status = $Runspace.BeginInvoke() }
    }

    # Collect results
    foreach ($Job in $Jobs) {
        $result = $Job.Pipe.EndInvoke($Job.Status)
        if ($result) { $folderSizes.Add($result) | Out-Null }
        $Job.Pipe.Dispose()
        $processed++

        # Update Progress Bar (work in progress)
        $percentComplete = ($processed / $totalFolders) * 100
        $elapsedTime = (Get-Date) - $startTime
        $estimatedTotalTime = if ($processed -gt 0) { ($elapsedTime.TotalSeconds / $processed) * $totalFolders } else { 0 }
        $remainingTime = [math]::Round(($estimatedTotalTime - $elapsedTime.TotalSeconds) / 60, 2)

        Write-Host "`nCurrently Processing: $($Job.Folder)" -ForegroundColor Yellow
        Write-Host "Scanned: $processed of $totalFolders folders ($([math]::Round($percentComplete, 2))%)"
        Write-Host "Elapsed Time: $([math]::Round($elapsedTime.TotalSeconds, 2)) seconds"
        Write-Host "Estimated Time Remaining: $remainingTime minutes`n"

        Write-Progress -Activity "Scanning C:\ Drive" -Status "$processed of $totalFolders folders scanned" -PercentComplete $percentComplete
    }

    # Close RunspacePool
    $RunspacePool.Close()
    $RunspacePool.Dispose()

    # Sort and display results
    $folderSizes | Sort-Object -Property SizeGB -Descending | Format-Table -AutoSize
}

# Run the function
Get-AllFolderSizes