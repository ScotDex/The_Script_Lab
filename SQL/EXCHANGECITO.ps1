<#
.SYNOPSIS
    Processes a SQL result log file and generates a CSV output with specific data extracted from the log.

.DESCRIPTION
    This script reads a log file generated from a SQL query, processes the data to extract specific HL7 message segments, 
    and outputs the results to a CSV file. It handles different HL7 segments such as MSH, TXA, and OBX to gather information 
    about documents and their statuses.

.PARAMETER SQLResult
    The path to the SQL result log file to be processed.

.PARAMETER Output
    The path to the CSV file where the processed data will be saved.

.NOTES
    The script checks if the output file already exists and removes it before processing. It counts the number of empty 
    and populated PDF fields and outputs these counts at the end of the script.

.EXAMPLE
    .\EXCHANGECITO.ps1
    This example runs the script and processes the default SQL result log file, saving the output to the default CSV file.

#>

try {
    #cls
    $SQLResult = "C:\Synanetics\SQL\EXCHANGECITO.log"
    $Output = "C:\Synanetics\Scripts\Output\EXCHANGECITO.csv"
    if (Test-Path -Path $Output) {
    "Clear file"
        Remove-Item $Output
    }
                    

    $empty = 0
    $populated = 0
    if ($null -ne $reader) {
        $reader.Close()
        $reader.Dispose()
    }
    $i = 0
    $sessions = @()
    "Open " + $SQLResult
    $reader = New-Object System.IO.StreamReader($SQLResult)
    if ($reader -ne $null) {
        while (!$reader.EndOfStream) {
            
            $input = $reader.ReadLine().Split("`t")

            if (($input[0] -as [int]) -is [int]) {

                
                $session = $input[0]
                $sessions += $session
                $line = $input[1]
                $i++
               
            } else {
                $line = $input[0]
            }
           

            if ($line -eq $null) {Continue}

            $hl7 = $line.Split("|")


            if (($hl7[0] -eq "MSH" -and $Document -ne "" ) -or ($hl7[0] -eq "" -and $Document -ne "" )) {
               # if (!$PDFProcessed) {
                    $Text = $DateTime+","+$Session + "," + $Document + "," + $PDFProcessed
                   
                    
                    Add-Content -Path $Output $Text
               # }
                $Document = ""
                $PDFSent = $False
                $PDFProcessed = $False
                
            }
            if ($hl7[0] -eq "MSH") {
                $DateTime = $hl7[6]
               
            }

            if  ($hl7[0] -eq "TXA") {
                $Document = $hl7[12]
               
            }
            if  ($hl7[0] -eq "OBX" ) {
                $Fields = $hl7[5].Split("^")
                if ($Fields[2] -eq "PDF" ) {
                    if ($Fields[4] -eq "") {
                        $empty++
                        $PDFProcessed = $False
                     } else {
                        $populated++
                        $PDFProcessed = $True

                     }
                }
            
            }
        <#   #>
        }
         
    } else {
        $SQLResult + " not found"
    }

   

     "Populated: " + $populated
     "Empty: " + $empty 
     $total = $populated + $empty 
     "Total: "+ $total

    
 } Catch {
    "Error"   
     $_
} Finally {
    if ($null -ne $reader) {
        $reader.Close()
        $reader.Dispose()
    }
}