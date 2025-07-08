Write-Host "DNS Record Auditor - Write your URL here" -ForegroundColor Red
$Domain = Read-Host
$Domain = $Domain -replace '^https?://', ''
$Domain = $Domain.TrimEnd("/")

$CsvPath = "$env:USERPROFILE\Desktop\DNS-Report-$($Domain.Replace('.', '_')).csv"
$DnsResults = @()

function Get-DNSRecordType {
    param (
        [string]$Domain,
        [string]$RecordType
    )
    try {
        $records = Resolve-DnsName -Name $Domain -Type $RecordType -ErrorAction Stop

        foreach ($rec in $records) {
            $script:DnsResults += [pscustomobject]@{
                Domain    = $Domain
                Type      = $rec.Type
                Name      = $rec.Name
                IPAddress = $rec.IPAddress
                NameHost  = $rec.NameHost
                MailEx    = $rec.MailExchange
            }
        }
    } catch {
        # Log failure as empty record with error note
        $script:DnsResults += [pscustomobject]@{
            Domain    = $Domain
            Type      = $RecordType
            Name      = $Domain
            IPAddress = $null
            NameHost  = $null
            MailEx    = "Lookup failed"
        }
    }
}

# Run lookups
"A", "AAAA", "MX", "NS", "TXT", "SOA", "CNAME" | ForEach-Object {
    Get-DNSRecordType -Domain $Domain -RecordType $_
}

# Export to CSV
$DnsResults | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
Write-Host "`CSV report written to: $CsvPath" -ForegroundColor Green

# Optional: Open it
Start-Process $CsvPath
