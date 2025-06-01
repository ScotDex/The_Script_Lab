# This script tests the connectivity to a specified endpoint using ping and traceroute.
# It also creates a CSV file on the user's desktop to log the results.

Write-Host "Enter the IP address or hostname of the endpoint you want to test:" -ForegroundColor Green
$endpointIP = Read-Host
$csvOutput = "$env:USERPROFILE\Desktop\ConnectivityResult.csv"
$result = Test-Connection -ComputerName $endpointIP -Count 4 -ErrorAction SilentlyContinue 

if (-not (Test-Path -Path $csvOutput)) {
    New-Item -ItemType File -Path $csvOutput -Force
}

if ($result) {
    $result
    Write-Host "Ping to $endpointIP was successful." -ForegroundColor Green
    Write-Host "Running traceroute to $endpointIP..." -ForegroundColor Green
    Test-NetConnection -ComputerName $endpointIP -TraceRoute
} else {
    Write-Host "Ping to $endpointIP failed." -ForegroundColor Red
}

$result | Export-Csv -Path $csvOutput -NoTypeInformation -Encoding UTF8 -Append
