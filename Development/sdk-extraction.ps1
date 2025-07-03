$uri = "https://eve-static-data-export.s3-eu-west-1.amazonaws.com/tranquility/sde.zip"
$output = "$env:userprofile/sde.zip"
Invoke-WebRequest -Uri $uri -OutFile $output
Expand-Archive -Path $output -DestinationPath ".\sde"
