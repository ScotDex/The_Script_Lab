$logname = "System" # Change this to the desired log name
# You can also use "Application" or "Security" depending on your needs
# For example, to get Application logs, set $logname = "Application"
$exportpath = "C:\Users\Gillen\Desktop\eventlogextraction.html" # Change this to your desired export path
$daysback = 7
# Number of days back to search for events
# You can change this to any number of days you want to look back


###############################

$events = Get-WinEvent -FilterHashtable @{
    LogName   = $logname
    StartTime = (Get-Date).AddDays(-$daysback)
    Level     = 2, 3
} -ErrorAction SilentlyContinue
# Filter for warnings (level 2) and errors (level 3)
if ($events.Count -eq 0) {
    Write-Host "No events found in the last $daysback days for log: $logname"
    exit
}
# If no events are found, exit the script
#############################

$formatted = $events | Select-Object -Property TimeCreated, Id, LevelDisplayName, Message, @{
    Name = "EventData"
    Expression = { ($_.Properties | ForEach-Object { $_.Value }) -join "," }
} | Sort-Object TimeCreated -Descending

# Some visual formatting for HTML Report
# You can customize the styles as per your requirements

$style = @"
<style>
    body {
        font-family: Segoe UI, sans-serif;
        background-color: #fdfdfd;
        color: #333;
        padding: 20px;
    }
    h1 {
        font-size: 1.5em;
        margin-bottom: 20px;
        color: #222;
    }
    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 10px;
    }
    th, td {
        padding: 8px 12px;
        border: 1px solid #ccc;
        text-align: left;
    }
    th {
        background-color: #444;
        color: #fff;
    }
    tr:nth-child(even) {
        background-color: #f2f2f2;
    }
</style>
"@

# Convert the events to HTML and apply the styles
# You can customize the HTML header and footer as per your requirements

$header = "<h1>Event Log Report: $logname (Last $daysback Days)</h1>"
$formatted | ConvertTo-Html -Property TimeCreated, Id, LevelDisplayName, Message, EventData -Title "Event Log Report" -Head $style -PreContent $header |
    Out-File -FilePath $exportpath -Encoding utf8

Write-Host "Exported styled warnings and errors to: $exportpath"

# The script will create an HTML file with the event log data, styled for better readability.
# You can open the HTML file in a web browser to view the formatted report.