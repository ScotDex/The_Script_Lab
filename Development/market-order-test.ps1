

$tritaniumId = 34
$regionId = 10000002
$jitaStationId = 60003760

# For the above look at how I can get a json file with the data of all stations and regions and cross reference it with the IDs above.
# User input for region and station IDs can be replaced with a lookup from a JSON file containing all regions and stations.


# Function to fetch market orders
function Get-MarketOrders {
    param (
        [string]$orderType  # 'buy' or 'sell'
    )

    $orders = @()
    $page = 1

    do {
        $url = "https://esi.evetech.net/latest/markets/$regionId/orders/?order_type=$orderType&type_id=$tritaniumId&page=$page"

        # Print URL for debugging
        Write-Host "Fetching ${orderType} page ${page}: ${url}"

        try {
            $response = Invoke-RestMethod -Uri $url -Method Get
        } catch {
            Write-Warning "Failed to fetch page ${page}: $(${_})"
            break
        }

        if (-not $response) { break }

        # Filter Jita 4-4
        $filtered = $response | Where-Object { $_.location_id -eq $jitaStationId }
        $orders += $filtered

        # If less than 1000 orders, it was the last page
        if ($response.Count -lt 1000) { break }

        $page++
    } while ($true)

    return $orders
}

# Fetch buy and sell orders
$buyOrders = Get-MarketOrders -orderType "buy"
$sellOrders = Get-MarketOrders -orderType "sell"

# Sort and display
$topBuys = $buyOrders | Sort-Object price -Descending | Select-Object -First 5
$topSells = $sellOrders | Sort-Object price | Select-Object -First 5

Write-Host "`nTop 5 Jita Buy Orders for Tritanium:`n"
$topBuys | Format-Table price, volume_remain, duration, issued

Write-Host "`nTop 5 Jita Sell Orders for Tritanium:`n"
$topSells | Format-Table price, volume_remain, duration, issued

# Streamline above code for potential future use
# Baseline module for API interaction?