$text = "Kobyla má malý bok"

$letters = $text.Replace(" ", "").ToLower()

$array_of_strings = $letters.ToCharArray() | ForEach-Object { "$_" }

$sorted = $array_of_strings | Sort-Object -Culture 'cs-CZ'

$result = -join $sorted

Write-Host "Původní text: $text"
Write-Host "Seřazená písmena: $result"