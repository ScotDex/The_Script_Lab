$discordWebhookUrl = "https://discord.com/api/webhooks/1371239173369106452/Es5EH6bG2phUyIvGvlWKDDGKX5lxNFJv7cZSRqfr-Do1UGdvYU-aD1UdUTK2YNiEZG9l"
$message = "@everyone I have returnethd, DOOM Dark-Ages in 2 min https://www.twitch.tv/scottishdex"
$payload = @{
    content = $message
}
$jsonPayload = $payload | ConvertTo-Json
Invoke-RestMethod -Uri $discordWebhookUrl -Method Post -Body $jsonPayload -ContentType 'application/json'
