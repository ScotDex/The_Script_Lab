$text = "Hello, welcome to powershell world!" # what text you want the write to spit out

foreach ($char in $text.ToCharArray()) {
    Write-Host -NoNewline $char
    Start-Sleep -Milliseconds 100 # decide how slow/fast the writing is going to be
}

Write-Host
