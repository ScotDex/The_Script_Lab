
# Variables and user entry for QR code generation
$texttoEncrypt = Read-Host "Please enter the URL you want to encode in the QR code:"
Add-Type -AssemblyName System.Web 
$encodedText = [System.Web.HttpUtility]::UrlEncode($texttoEncrypt)
$qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=$encodedText"

# Output path for the QR code image
$outputPath = "$env:USERPROFILE\Desktop\$encodedText.png"

# error handling for URL and file operations
try {
    Invoke-WebRequest -Uri $qrUrl -OutFile $outputPath -UseBasicParsing
    Write-Host "`nQR code saved to: $outputPath" -ForegroundColor Green
} catch {
    Write-Error "Failed to generate QR code. $_"
}
