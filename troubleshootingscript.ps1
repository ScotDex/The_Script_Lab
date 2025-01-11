# Network Troubleshooting Script

# Flush the DNS resolver cache
ipconfig /flushdns

# Re-register DNS names
ipconfig /registerdns

# Release all current DHCP-assigned IP addresses
ipconfig /release

# Renew all DHCP-assigned IP addresses
ipconfig /renew

# Reset Winsock catalog (network protocol settings)
netsh winsock reset catalog

# Reset IPv4 settings
netsh int ipv4 reset reset.log

# Reset IPv6 settings
netsh int ipv6 reset reset.log

# Optional: Prompt the user to restart for changes to fully take effect
Write-Host "It is recommended to restart your computer for all changes to take effect."
$response = Read-Host "Do you want to restart now? (Y/N)"
if ($response -eq "Y") {
    Restart-Computer
}
