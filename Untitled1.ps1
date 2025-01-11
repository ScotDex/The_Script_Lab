function Test-Port {
    param (
        [string]$Computername = "localhost",
        [int]$Ports = @(1, 1024),
        [int]$Timeout = 1000)
    


    foreach ($port in $Ports) {
        try {
            Write-Progress -Activty "Scanning Ports on $Computername" -Status "Scanning port $port" -PercentComplete (($port / $Ports.Count) * 100)
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $connect = $tcpClient.BeginConnect($ComputerName, $port, $null, $null)
            $wait = $connect.AsyncWaitHandle.WaitOne($Timeout, $false)
            if (!$wait) {
                # Timeout
                Write-Verbose "Port $port on $ComputerName is closed (timeout)."
                $tcpClient.Close()
              } else {
                # Connection established
                $tcpClient.EndConnect($connect)
                Write-Host "Port $port on $ComputerName is OPEN" -ForegroundColor Green
                $tcpClient.Close()
              }
            } catch {
              Write-Verbose "Port $port on $ComputerName is closed (connection refused)."
            }
          }
}