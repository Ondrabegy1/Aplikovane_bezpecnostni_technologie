$desktop = [Environment]::GetFolderPath("Desktop")
$filepath = Join-Path $desktop "teploty.txt"

$url = "https://api.open-meteo.com/v1/forecast?latitude=49.1951&longitude=16.6068&current_weather=true"

try {
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
    $json = $response.Content | ConvertFrom-Json
    $tempC = $json.current_weather.temperature
    if ($null -eq $tempC) {
        throw "Nepodařilo se získat teplotu z JSON."
    }
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp - Teplota v Brně: $tempC °C"
    Add-Content -Path $filepath -Value $line
}
catch {
    $err = $_.Exception.Message
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp - Chyba při získání teploty: $err"
    Add-Content -Path $filepath -Value $line
}
