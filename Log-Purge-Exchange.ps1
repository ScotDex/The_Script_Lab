# Description: This script is used to delete the log files for the Exchange Total Inbound and RTGXCH Total Inbound logs.
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

try {
    Clear-Host
    $Logs = @(
        "C:\Synanetics\SQL\EXCHANGE_TotalInbound.log"
        "C:\Synanetics\SQL\EXCHANGE_TotalInbound_Unsupported.log"
        "C:\Synanetics\SQL\RTGXCH_TotalInbound.log"
        "C:\Synanetics\SQL\RTGXCH_TotalInbound_Unsupported.log"
        "C:\Synanetics\SQL\EXCHANGE_TotalInbound_today.log"
        "C:\Synanetics\SQL\EXCHANGE_TotalInbound_today_Unsupported.log"
        "C:\Synanetics\SQL\RTGXCH_TotalInbound_today.log"
        "C:\Synanetics\SQL\RTGXCH_TotalInbound_today_Unsupported.log"
    )

    ForEach ($Log in $Logs) {
        if (Test-Path $Log) {Remove-Item $Log}
    }

} catch {
    Write-Error "-----------------------ERROR---------------------------"
    Write-Error $_
    Write-Error "-------------------------------------------------------"
} Finally {
    Write-Host "Cleanup script execution completed."
}