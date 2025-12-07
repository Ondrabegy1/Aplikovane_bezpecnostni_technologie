param(
    [string]$url,
    [int]$delka
)

# Nápověda
if (-not $url -or -not $delka) {
    Write-Host "Použití:" -ForegroundColor Cyan
    Write-Host "powershell -ExecutionPolicy Bypass -File script_webscraping.ps1 -url <URL> -delka <cislo>" -ForegroundColor Green
    Write-Host "Příklad:" -ForegroundColor Cyan
    Write-Host "powershell -ExecutionPolicy Bypass -File script_webscraping.ps1 -url https://sites.google.com/view/powershell2025/z%C3%A1po%C4%8Det -delka 5" -ForegroundColor Green
    exit
}

try {
    Write-Host "[*] Stahuji obsah stranky: $url" -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    $content  = $response.Content
    Write-Host "[+] Stranka uspesne nactena." -ForegroundColor Green

    Write-Host "[*] Zpracovavam text..." -ForegroundColor Cyan
    $text = [regex]::Replace($content, "<[^>]*>", " ")

    # Regex - jen písmena bez diakritiky
    $pattern = "\b[a-zA-Z]{$delka}\b"

    $words = [regex]::Matches($text, $pattern) | ForEach-Object { $_.Value.ToLower() }

    # Odstranění duplicit
    $uniqueWords = $words | Sort-Object -Unique

    Write-Host "`n[+] Nalezena slova o delce $delka znaku:" -ForegroundColor Green -BackgroundColor DarkGray
    Write-Host "================================================" -ForegroundColor Green
    foreach ($word in $uniqueWords) {
        Write-Host "  $word" -ForegroundColor White
    }
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "[*] Celkem: $($uniqueWords.Count) unikatnich slov" -ForegroundColor Cyan
}
catch {
    Write-Host "[!] Chyba pri nacitani stranky: $($_.Exception.Message)" -ForegroundColor Red -BackgroundColor Black
}
