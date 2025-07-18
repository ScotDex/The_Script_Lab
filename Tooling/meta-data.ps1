$sourcePath = "C:\Path\To\Source\meta-data.ps1"
$destinationPath = "C:\Path\To\Destination\meta-data.ps1"

if (-Not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath -Force
}


# Add necessary assemblies for image processing
Add-Type -AssemblyName system.drawing

Get-ChildItem -Path $SourcePath -Include *.jpg, *.jpeg, *.png, *.bmp, *.gif, *.tiff -Recurse | ForEach-Object {
    $image = [System.Drawing.Image]::FromFile($_.FullName)

    # Clone the image to a new bitmap without metadata
    $newImage = New-Object System.Drawing.Bitmap $image

    # Build destination file path
    $destFile = Join-Path -Path $DestinationPath -ChildPath $_.Name

    # Save image without metadata (re-encoding removes EXIF)
    $newImage.Save($destFile, $image.RawFormat)

    # Dispose objects to release file locks
    $image.Dispose()
    $newImage.Dispose()

    Write-Host "Processed: $($_.Name)"
}