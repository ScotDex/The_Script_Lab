# 2 Sets of scripts which provide an ability to convert a file from base64 to a file and vice versa.
# The first script converts a file from base64 to a file and the second script converts a file to base64. The scripts are designed to be run in PowerShell and include error handling and user prompts for file paths.
# The first script reads a base64 string from a file, converts it to bytes, and writes it to a new file. The second script reads a file, converts its contents to a base64 string, and writes that string to a new file. Both scripts include error handling to manage issues such as invalid file paths or inaccessible files.
# Conversations indicate we never really have to use something like this unless we are testing file integrity, as conversion would involve reviewing patient data
# =======================================================
# Convert a file from Base64
# Variables for file paths
$FilePath = "C:\Path\To\Input\File.txt" # Path to the input file containing the Base64 string
$outputPath = "C:\Path\To\Output\File.doc" # Path to save the output file
{ try {

        $base64String = Get-Content -path $FilePath -Raw
        $fileBytes = [System.Convert]::FromBase64String($base64String)
        [System.IO.File]::WriteAllBytes($outputPath, $fileBytes)

    }
    catch {
        Write-Error "An error occurred: $_"
        Write-Host "Please check the file path and ensure the base64 string is valid."
    }
    finally {
        Write-Host "Process completed."
    }
    
}

# =======================================================

# Convert a file to Base64

# Variables for file paths
try {
    $FilePath = "C:\Path\To\Input\File.txt"
    $outputPath = "C:\Path\To\Output\File.doc"
    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)

    # Process for conversion
    $base64String = [System.Convert]::ToBase64String($fileBytes)
    # Output the Base64 string to a file
    Set-Content -Path $outputPath -Value $base64String
}
catch {
    Write-Error "An error occurred: $_"
    Write-Host "Please check the file path and ensure the input file exists and is accessible."
}
finally {
    Write-Host "Conversion process completed."
}
