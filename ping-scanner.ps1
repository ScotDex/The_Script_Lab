param (
    [string]$ipAddress = "127.0.0.1",
    [int[]]$ports = @(80, 443, 8080)
)

foreach ($port in $ports) {
    $connection = Test-NetConnection -ComputerName $ipAddress -Port $port
    if ($connection.TcpTestSucceeded) {
        Write-Output "Port $port is open on $ipAddress"
    } else {
        Write-Output "Port $port is closed on $ipAddress"
    }
}