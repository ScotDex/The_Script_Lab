Add-Type -AssemblyName System.Windows.Forms

Write-Host "Mouse mover starter, Ctrl+C to kill" -ForegroundColor Green

while ($true) {
    $currentPos = [System.Windows.Forms.Cursor]::Position

    $newX = $currentPos.X +10
    $newY = $currentPos.Y

    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($newX,$newY)

    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($currentPos.X, $currentPos.Y)

    Start-Sleep -Seconds 5
}