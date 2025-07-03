﻿<#
.SYNOPSIS
    EVE Online Network Diagnostics Script

.AUTHOR
    CCP (CCP Games)
.DESCRIPTION
    This PowerShell script performs a series of network diagnostics to test connectivity to EVE Online game, web, and chat servers. It checks ping, traceroute, port availability, and MTU size, and collects Cloudflare and IP geolocation information. Results are saved to a timestamped text file in the script's directory.

.PARAMETER $GAMEservers
    Array of EVE Online game server hostnames.

.PARAMETER $GAMEport
    Port number used by EVE Online game servers.

.PARAMETER $WEBservers
    Array of EVE Online web service hostnames.

.PARAMETER $WEBport
    Port number used by EVE Online web services (HTTPS).

.PARAMETER $CHATservers
    Array of EVE Online chat server hostnames.

.PARAMETER $Chatport
    Port number used by EVE Online chat servers.

.PARAMETER $PINGservers
    Combined array of servers to be pinged (game and chat servers).

.FUNCTIONS
    TestPing
        Pings each server in parallel and calculates packet loss percentage.

    TestTrace
        Performs a traceroute to each server in parallel.

    TestPort
        Tests TCP port connectivity to each server in parallel.

    TestMTU
        Determines the maximum transmission unit (MTU) size for each server.

.NOTES
    - Requires PowerShell 5.0+ and administrative privileges for some network commands.
    - Uses PowerShell workflows and background jobs for parallel execution.
    - Output is saved to a file named "EVE-diag_<timestamp>.txt" in the script's directory.
    - Collects Cloudflare CDN trace and public IP geolocation for additional diagnostics.

.EXAMPLE
    Run the script and follow prompts to perform diagnostics:
        .\eve-network-diagnostics v6.ps1

.OUTPUTS
    - Diagnostic results are displayed in the console and saved to a text file.
    - Includes ping statistics, traceroute paths, port test results, MTU sizes, Cloudflare trace, and IP geolocation.

#>
$GAMEservers = 'tranquility.servers.eveonline.com', 'singularity.servers.eveonline.com'
$GAMEport = "26000"

$WEBservers = 'cis.eveonline.com', 'www.eveonline.com', 'login.eveonline.com', 'launcher.eveonline.com'
$WEBport = '443'

$CHATservers = 'live.chat.eveonline.com'
$Chatport = '5222'

$PINGservers = $GAMEservers + $CHATservers

$pingflow = {
    workflow TestPing {
    
        param (
            $servers,
            $count
        )

        Foreach -Parallel ($servers in $servers) {
            $ping = Test-Connection -ComputerName $servers -Count $count -ErrorAction SilentlyContinue
            $pingslost = ((($ping).Count) / $count * 100)
    
            $result = "$pingsLost" + "%"

            Write-Output "$servers,$result"
        }
    }
}

$traceflow = {
    workflow TestTrace {
    
        param (
            $servers
        )

        Foreach -Parallel ($servers in $servers) {
            $result = (Test-NetConnection $servers -TraceRoute -Hops 20).TraceRoute | Select -Skip 1
            Write-Output "$result $servers"
        }
    }
}



workflow TestPort {
    
    param (
        $servers,
        $port
    )

    Foreach -Parallel ($servers in $servers) {
        $result = Test-NetConnection -ComputerName $servers -RemotePort $port 
        Write-Output $result 
    }
}

workflow TestMTU {
    
    param (
        $servers
    )
    
    Foreach -Parallel ($servers in $servers) {
 
 
        $BufferSizeMax = 1500
        $LastMinBuffer = $BufferSizeMin
        $LastMaxBuffer = $BufferSizeMax
        $MaxFound = "false"

        [int]$BufferSize = ($BufferSizeMax - 0) / 2

        while ($MaxFound -eq "false") {
            try {
                $Response = ping $servers -n 1 -f -l $BufferSize
            
                if ($Response -like "*fragmented*") { throw "MTU to large" }
                      
                if ($Response -like "*could not find host*") {
                    $LastMinBuffer = "NOT RESPONDING"
                    $MaxFound = "true"
                }           
                elseif ($LastMinBuffer -eq $BufferSize) {
                    $MaxFound = "true"
                }
                else {
                    $LastMinBuffer = $BufferSize
                    $BufferSize = $BufferSize + (($LastMaxBuffer - $LastMinBuffer) / 2)
                }

            }
            catch {
                $LastMaxBuffer = $BufferSize
            
                if (($LastMaxBuffer - $LastMinBuffer) -le 3) {
                    $BufferSize = $BufferSize - 1
                }
                else {
                    $BufferSize = $LastMinBuffer + (($LastMaxBuffer - $LastMinBuffer) / 2)
                }
            }
        }
        Write-Output "$servers,$LastMinBuffer"
    }
}

$pingwork = {
    param (
        $servers
    )
    $ping = TestPing $servers 50
    return $ping
}

$tracework = {
    param (
        $servers
    )
    $trace = TestTrace $servers
    return $trace
}

cls
Write-Output  "`n`n`n`nThis script will test your connection to EVE Online and save a file in the same location the script is running from.`n`n"
Read-Host -Prompt "Press Enter to start"


#START
$Date = (Get-Date -uformat "%Y-%m-%d@%H-%M(%Z)")
$Filename = "EVE-diag_" + $Date + ".txt"

$loc = Invoke-RestMethod http://ipinfo.io/json

#CLOUDFLARE INFO
$curljob = (Invoke-WebRequest -Uri "https://eveonline.com/cdn-cgi/trace").Content

#PING START
$pingjob = Start-Job -InitializationScript $pingflow -ScriptBlock $pingwork -ArgumentList (, $PINGservers)

#TRACE START
$tracejob = Start-Job -InitializationScript $traceflow -ScriptBlock $tracework -ArgumentList (, $PINGservers)

cls
Write-Output  "Background PING and TRACE jobs have now started"
Write-Output  "`n`n`n`n`n`n`n`nTesting service avalability:"

#PORT TESTING


$port1 = TestPort $GAMEservers $GAMEport | Select-Object ComputerName, RemoteAddress, RemotePort, TcpTestSucceeded 
$port2 = TestPort $CHATservers $Chatport | Select-Object ComputerName, RemoteAddress, RemotePort, TcpTestSucceeded
$port3 = TestPort $WEBservers $WEBport | Select-Object ComputerName, RemoteAddress, RemotePort, TcpTestSucceeded

$PORTtable = $port1 + $port2 + $port3

Write-Output  $PORTtable
Write-Output  "`nMesuring Windowsizes:"

#MTU TESTING

$mtu1 = TestMTU $GAMEservers
$mtu2 = TestMTU $CHATservers
$mtu3 = , "Connection,Window Size" + $mtu1 + $mtu2
$MTUtablet = convertfrom-csv -InputObject $mtu3 | Format-Table -AutoSize

Write-Output  $MTUtablet
Write-Output  "`nWaiting for pings and traces to complete (this may take a few minutes)"


#PING STOP


Wait-Job -Id $pingjob.id, $tracejob.id | Out-Null

$pingresult = Receive-Job -Id $pingjob.id
$traceresult = Receive-Job -Id $tracejob.id
#Get-Job | Remove-Job

$tracetable = $traceresult | ConvertFrom-String -PropertyNames 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20

$pingresult2 = , "Connections ,Ping Success" + $pingresult
$pingtable = convertfrom-csv -InputObject $pingresult2 | Format-Table -AutoSize




$(

    Write-Output $Filename
    Write-Output $curljob
    Write-Output $loc
    Write-Output $tracetable
    Write-Output $pingtable
    Write-Output $PORTtable
    Write-Output $MTUtablet

) *>&1 > $Filename

Write-Output  "File:" $Filename " created"

Read-Host -Prompt "Press Enter to finish"
