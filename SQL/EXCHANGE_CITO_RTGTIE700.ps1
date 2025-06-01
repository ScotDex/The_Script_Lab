<#
.SYNOPSIS
Processes a log file to identify and copy specific files based on log entries.

.DESCRIPTION
This script reads a log file located at "C:\Synanetics\SQL\EXCHANGE_CITO_RTGTIE700.log" and processes its content to identify specific files. 
It checks for the existence of files referenced in the log and attempts to locate them in an archive directory. 
If a matching file is found, it generates a PowerShell script to copy the file to a destination directory.

.PARAMETERS
None.

.INPUTS
None.

.OUTPUTS
None.

.NOTES
- The script uses a temporary file ("Copy.ps1") to store the generated copy commands.
- It ensures proper cleanup of resources like the StreamReader object.
- The script handles exceptions and ensures the StreamReader is disposed of in the `Finally` block.

.EXAMPLE
# Run the script to process the log file and generate the copy script:
.\EXCHANGE_CITO_RTGTIE700.ps1

# After running, check the generated "Copy.ps1" script for the copy commands.

#>

try {
    Clear-Host
    $Log = "C:\Synanetics\SQL\EXCHANGE_CITO_RTGTIE700.log"
    $Destination = "C:\Synanetics\Scripts\Files\MTDD"
    $Temp = "C:\Synanetics\Scripts\Temp"

    $Script = "$Temp\Copy.ps1"
    if (Test-Path $Script) {Remove-Item $Script}

    if ($null -ne $reader) {
        $reader.Close()
        $reader.Dispose()
    }
    $reader = New-Object System.IO.StreamReader($Log)
    $readline = $False
    if ($null -ne $reader) {
        while (!$reader.EndOfStream) {
            $lineInput = $reader.ReadLine().Split("`t")
            if ($lineInput[0] -eq "Guid") {
                $readline = $True
            } elseif ($lineInput[0] -like "*Rows(s) Affected") {
                $readline = $False
            } elseif ($readline) {
                if ($null -ne $lineInput) {
                    $pdf = $lineInput[1]
                    $fileRef  = $pdf.Split("_")[0].Split("\")[-1]
                    $pdfExists = Test-Path $pdf
                    if (!$pdfExists) {
                        "$pdf  $pdfExists"

                        $search = "$fileRef*"

                        $Archive = "\\uhdbfs\healthshare\Meditech\Live\Archive\"
                        $FileCount = 0
                        Get-ChildItem  $Archive  | Where-Object {$_.Name -like "$search" } | ForEach-Object {
                            $FileCount++
                        }
                        if ($FileCount -eq 1) {
                       
                            $target = "$Destination\$fileRef"
                            $copyText = "Copy-Item -Path $ArchiveFile -Destination $target"
                            Add-Content -Path $Script $copyText
                        }

                    }
                       
                }
            }

        }
    }

} Catch { 
    $_
} Finally {
    if ($null -ne $reader) {
        $reader.Close()
        $reader.Dispose()
    }

}