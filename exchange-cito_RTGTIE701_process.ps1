# Description: This script is used to process the data from the SQL Server and copy the PDF files to the destination folder.
<#
.SYNOPSIS
Processes a log file to identify and copy specific PDF files based on log entries.

.DESCRIPTION
This script reads a log file, parses its content, and identifies PDF files that match specific criteria. 
It generates a PowerShell script to copy the identified PDF files from a source directory to a destination directory.

.PARAMETER $Log
The path to the log file that contains information about the PDF files to process.

.PARAMETER $Destination
The destination directory where the identified PDF files will be copied.

.PARAMETER $Temp
The temporary directory used to store the generated PowerShell script.

.PARAMETER $PDF_In
The directory containing the input PDF files to search for matches.

.PARAMETER $PDF_Out
The directory for output PDF files (not used in the current script logic).

.PARAMETER $Script
The path to the temporary PowerShell script that will be generated to perform the copy operation.

.NOTES
- The script reads the log file line by line and processes lines between specific markers ("Guid" and "*Rows(s) Affected").
- For each relevant line, it extracts the PDF file reference, checks if the file exists, and searches for matching files in the input directory.
- If exactly one matching file is found, a copy command is added to the generated script.

.EXAMPLE
# Run the script to process the log file and generate the copy script:
.\EXCHANGE_CITO_RTGTIE701_Processe.ps1

# The generated script can then be executed to perform the copy operations:
.\CopyPDF.ps1

#>
try {
    cls
    $Log = "C:\Synanetics\SQL\EXCHANGE_CITO_RTGTIE701.log"
    $Destination = "C:\Synanetics\Scripts\Files"
    $Temp = "C:\Synanetics\Scripts\Temp"


    $PDF_In = "C:\Synanetics\Scripts\Files\PDF\In"
    $PDF_Out = "C:\Synanetics\Scripts\Files\PDF\Out"



    $Script = "$Temp\CopyPDF.ps1"
    if (Test-Path $Script) {Remove-Item $Script}

    if ($null -ne $reader) {
        $reader.Close()
        $reader.Dispose()
    }
    $reader = New-Object System.IO.StreamReader($Log)
    $readline = $False
    if ($reader -ne $null) {
        while (!$reader.EndOfStream) {
            $input = $reader.ReadLine().Split("`t")
            if ($input[0] -eq "Guid") {
                $readline = $True
            } elseif ($input[0] -like "*Rows(s) Affected") {
                $readline = $False
            } elseif ($readline) {
                if ($input -ne $null) {
                    $pdf = $input[1]
                  #  $pdf
              
                    $fileRef  = $pdf.Split("_")[0].Split("\")[-1]
                    
                    $pdfExists = Test-Path $pdf
                    

                    $search = "$fileRef*"
                    $search

                    
                    $FileCount = 0
               
                    Get-ChildItem  $PDF_In  | Where-Object {$_.Name -like "$search" } | ForEach {
                    "Found"
                        $FileCount++
                        $ArchiveFile = $_.FullName
                    }
                    if ($FileCount -eq 1) {
                       "Copy"
                       # $target = "$Destination\$fileRef"
                        $copyText = "Copy-Item -Path $ArchiveFile -Destination $Pdf"
                       
                        Add-Content -Path $Script $copyText
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