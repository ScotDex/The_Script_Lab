# Description: This script reads a CSV file and generates SQL statements for inserting data into a database table.
try {
    Clear-Host

    $csv = Read-Host -Prompt "Enter the full path to the CSV file (e.g., C:\Users\MDM-Document-Summary.csv)"

    if ($null -ne $reader) {
        $reader.Close()
        $reader.Dispose()
    }

    $reader = New-Object System.IO.StreamReader($csv)
    if ($reader -ne $null) {
        while (!$reader.EndOfStream) {
            $linecount++
            $line = $reader.ReadLine()
            $input = $line.Split(",")
            if ($input[0] -eq "Y") { 

                $CareSetting = $input[5]
                $DocumentGroup = $input[6]
                $DocumentName = $input[3]
                $DocumentRuleSet = Read-Host "Enter Document Rule Set for $DocumentName"
                $DocumentType = $input[7]
                
                if ($input[13] -eq "Y") {$Email = "1"}
                else  {$Email = "0"}

                if ($input[11] -eq "Y") {$Fraxinus = "1"}
                else  {$Fraxinus = "0"}

                if ($input[9] -eq "Y") {$GP = "1"}
                else  {$GP = "0"}

                $Letter = 0 #Don't know where this comes from


                $DocumentSNOMEDCTCode = $input[10]
                if ($DocumentSNOMEDCTCode -eq "N") {$Share2Care = "0"}
                else  {$Share2Care = "1"}


                $SourceApplication = $input[7]

                
                $sql = "INSERT INTO RWWXCH_Document_Table_Local.DocumentConfiguration "
                $sql = $sql + "(CareSetting, DateAdded, DocumentGroup, DocumentName, DocumentRuleSet, DocumentType, Email, Fraxinus, GP, Letter, Share2Care, SourceApplication, DocumentSNOMEDCTCode)"
                $sql = $sql + " VALUES "
                $sql = $sql + "('$CareSetting', GETDATE(), '$DocumentGroup', '$DocumentName', '$DocumentRuleSet', '$DocumentType', $Email, $Fraxinus, $GP, $Letter, $Share2Care, '$SourceApplication', '$DocumentSNOMEDCTCode')"
                $sql
                
                $sqlStatements += $sql
            }
        }
    }

    $outputFile =".\Generated_SQL_Statements.txt"
    $sqlStatements | Out-File -FilePath $outputFile -Encoding utf8

    Write-Host "SQL Statements have been generated and saved to $outputFile" -ForegroundColor Red
  

} Catch {
    "Error at line $linecount"
    $_
} Finally {
    if ($reader -ne $null) {
        $reader.Close()
        $reader.Dispose()
    }

}