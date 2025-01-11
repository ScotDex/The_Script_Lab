$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "Green"
Clear-Host

while ($true) {
    $width = $host.ui.RawUI.WindowSize.Width
    $height = $host.ui.RawUI.WindowSize.Height

    $outputLine = ""
    for ($i = 0; $i -lt $width; $i++) {
        $outputLine += Get-Random -Maximum 10
    }

    Write-Host $outputLine

    Start-Sleep -Milliseconds 100

    # Optionally, clear the screen to refresh the output (uncomment the next line if desired)
    # Clear-Host
}
