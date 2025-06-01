# Notes on Jira authentication:
# - The script uses basic authentication with a username and API token.
# Limited use case in this instance, but useful for future reference.
# This script retrieves the status of a Jira issue using the Jira REST API.

# Jira instance details
$Username = ""
$apiToken = ""
$credentialBytes = [System.Text.Encoding]::ASCII.GetBytes("$Username':$apiToken")
$EncodedCredentials = [System.Convert]::ToBase64String($credentialBytes)
$JiraUrl = "https://your-jira-instance.atlassian"

# Define headers
$Headers = @{
    "Authorization" = "Basic $encodedCredentials"
    "Content-Type"  = "application/json"
}

# Fetch the issue details
try {
    $IssueResponse = Invoke-RestMethod -Uri $IssueUrl -Method Get -Headers $Headers

    # Extract status from the response
    $IssueStatus = $IssueResponse.fields.status.name

    Write-Output "Issue: $IssueKey"
    Write-Output "Status: $IssueStatus"
} catch {
    Write-Output "Error retrieving issue details: $_"
}
