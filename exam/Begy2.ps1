Clear-Host
Write-Host "Načítám text hry Othello z othello.txt..." -ForegroundColor Cyan

try {
    $text = Get-Content "othello.txt" -Raw -Encoding UTF8
} catch {
    Write-Error "Chyba při čtení souboru: $($_.Exception.Message)"
    exit
}

$cleanText = $text.ToLower() -replace '[^a-z]', ''
if ($cleanText.Length -eq 0) { 
    Write-Error "Žádná data."; 
    exit 
}

$stats = $cleanText.ToCharArray() | Group-Object | Sort-Object Count -Descending
$maxCount = ($stats | Measure-Object -Property Count -Maximum).Maximum
$graphHeight = 20 

Write-Host "`nGRAF ČETNOSTI ZNAKŮ (Osa X: Znaky, Osa Y: Četnost)" -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Yellow

for ($row = $graphHeight; $row -ge 1; $row--) {
    $line = ""
    foreach ($item in $stats) {
        $barHeight = ([math]::Round(($item.Count / $maxCount) * $graphHeight))
        if ($barHeight -ge $row) {
            $line += " █ "
        } else {
            $line += "   "
        }
    }
    Write-Host $line -ForegroundColor Cyan
}

Write-Host ("-" * ($stats.Count * 3)) -ForegroundColor Gray

$axisLine = ""
foreach ($item in $stats) {
    $axisLine += " {0} " -f $item.Name.ToUpper()
}
Write-Host $axisLine -ForegroundColor Yellow

Write-Host "`nPřesné počty:" -ForegroundColor Yellow
foreach ($item in $stats) {
    Write-Host "$($item.Name.ToUpper()) : $($item.Count)"
}