# Description: This script is used to delete the RTGXCHAlerts.log and RTGXCHAlerts_Unsupported.log files.
$SQLFiles = @("C:\Synanetics\SQL\RTGXCHAlerts.log", "C:\Synanetics\SQL\RTGXCHAlerts_Unsupported.log")

Try {
    Clear-Host
    ForEach ($SQLFile in $SQLFiles) {
        if (Test-Path -Path $SQLFile) {
            Try {
                Remove-Item $SQLFile -ErrorAction Stop
                Write-Output "$SQLFile has been deleted."
            } Catch {
                Write-Error "Failed to delete $SQLFile $_"
            }
        } else {
            Write-Output "$SQLFile does not exist."
        }
    }
} Catch {
    Write-Error "An error occurred: $_"
} Finally {
    Write-Output "Cleanup script execution completed."
}