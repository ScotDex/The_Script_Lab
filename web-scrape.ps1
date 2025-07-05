param(
    [string]$url = "https://www.trekcore.com/audio/",
    [string]$downloadPath = "C:\Downloads\TrekCoreAudio",
    [string]$Pattern = ".+\.mp3$"
)

# Ensure the download path exists
if (-not (Test-Path -Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath | Out-Null
}

try {
    $web = Invoke-WebRequest -Uri $url -UseBasicParsing
}
catch {
    Write-Error "Failed to retrieve the web page: $_"
    exit 1
}

#extract links to audio files
$mp3Links = @()

# Try structured links first
if ($web.Links) {
    $mp3Links += $web.Links |
        Where-Object { $_.href -match $Pattern } |
        ForEach-Object { ($_ | Select-Object -ExpandProperty href) }
}

# Fallback: parse raw content with regex
if (-not $mp3Links) {
    $mp3Links += ($web.Content -split "`n") |
        Select-String -Pattern $Pattern |
        ForEach-Object {
            ($_ -match 'href="(.*?\.mp3)"') | Out-Null
            $matches[1]
        }
}

# Download each file
foreach ($link in $mp3Links) {
    $fileName = Split-Path -Path $link -Leaf
    $destination = Join-Path $DownloadPath $fileName

    # Handle relative URLs
    if ($link -notmatch '^https?://') {
        $uri = [uri]::new($Url, $link)
        $link = $uri.AbsoluteUri
    }

    Write-Host "Downloading $fileName..."
    try {
        Invoke-WebRequest -Uri $link -OutFile $destination
    } catch {
        Write-Warning "Failed to download $link"
    }
}