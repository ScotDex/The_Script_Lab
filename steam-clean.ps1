# Set the Steam library path
$steamLibraryPath = "D:\Program Files (x86)\Steam\steamapps\common"

# List of games to exclude from cleanup
$excludeGames = @(
    "Frostpunk 2",
    "EVE Online",
    "Vegas Infinite by PokerStars",
    "The Lab",
    "Warhammer 40,000: Space Marine 2",
    "Marbles on Stream",
    "Half-Life: Alyx",
    "DEATH STRANDING DIRECTOR'S CUT",
    "DEATH STRANDING"
)

# Get all the directories in the Steam common folder
$gameFolders = Get-ChildItem -Path $steamLibraryPath -Directory

# Loop through each game folder
foreach ($folder in $gameFolders) {
    if ($excludeGames -contains $folder.Name) {
        Write-Host "Skipping $($folder.Name) (Excluded)"
    } else {
        Write-Host "Cleaning up $($folder.Name)..."
        
        # Remove residual or unnecessary files/folders here
        # Example: Clean up the logs or cache
        $logFolder = "$folder\logs"
        $cacheFolder = "$folder\cache"
        $secondgamesfolder = "$folder\secondgamesfolder"
        
        if (Test-Path $logFolder) {
            Remove-Item -Path "$logFolder\*" -Recurse -Force
            Write-Host "Cleaned up logs in $($folder.Name)"
        }
        
        if (Test-Path $cacheFolder) {
            Remove-Item -Path "$cacheFolder\*" -Recurse -Force
            Write-Host "Cleaned up cache in $($folder.Name)"
        }

        if (Test-Path $secondgamesfolder) {
            Remove-Item -Path "$secondgamesfolder" -Recurse -Force
            Write-Host "Cleaned up cache in $($folder.Name)"
        }
        
        # Optional: Add other directories or files you want to target
    }
}

Write-Host "Cleanup completed!"
