### Vygenerujte 10 náhodných čísel mezi 10 a 100 vypište je spolu s jejich druhou mocninou. Výpis proveďte do dvou sloupců, kde v prvním bude hodnota čísla a v druhém jeho mocnina. Oba sloupce budou zarovnané, např. první sloupec od první pozice doprava a druhý od šesté pozice doprava.

Do powershellu zadáme skript:

```
$cisla = 1..10 | ForEach-Object { Get-Random -Minimum 10 -Maximum 101 }

foreach ($c in $cisla) {
    "{0,5} {1,10}" -f $c, ($c * $c)
}
```

tím získáme dva sloupce pojmenované "Číslo" a "Mocnina", které obsahují náhodná čísla a jejich mocniny k tomu.

***Nyní máme vygenerevaných 10 náhodných čísel od 10 do 100 a jejich druhou mocninu.***

___

### Setřiďte znaky v textu “Kobyla má malý bok” vzestupně dle abecedy.

Vytvoříme si skript:

```
$text = "Kobyla má malý bok"

$letters = $text.Replace(" ", "").ToLower()

$array_of_strings = $letters.ToCharArray() | ForEach-Object { "$_" }

$sorted = $array_of_strings | Sort-Object -Culture 'cs-CZ'

$result = -join $sorted

Write-Host "Původní text: $text"
Write-Host "Seřazená písmena: $result"
```

ten uložíme a spustíme pomocí příkazu:

```
.\script_ascension.ps1
```

tím se daný skript spustí a vyjde nám výsledek **aaábbkkllmmooyý**.

***Nyní máme seřazený text "Kobyla má malý bok" vzestupně podle abecedy.***

___

### Najděte nejmenší a největší palindrom, který vznikne násobením dvou trojciferných čísel. Nakonec vypište i jak palindrom vznikl.

Vytvoříme si skript:

```
$minPal = $null
$maxPal = $null
$minPair = $null
$maxPair = $null

for ($i = 100; $i -le 999; $i++) {
    for ($j = 100; $j -le 999; $j++) {
        $prod = $i * $j
        $str = $prod.ToString()

        $chars = $str.ToCharArray()
        [Array]::Reverse($chars)
        $rev = $chars -join ''

        if ($str -eq $rev) {
            if (-not $minPal -or $prod -lt $minPal) {
                $minPal = $prod
                $minPair = "$i * $j"
            }
            if (-not $maxPal -or $prod -gt $maxPal) {
                $maxPal = $prod
                $maxPair = "$i * $j"
            }
        }
    }
}

"Nejmenší palindrom: $minPal ($minPair)"
"Největší palindrom: $maxPal ($maxPair)"
```

ten uložíme a spustíme pomocí příkazu:

```
.\script_palindrom.ps1
```

tím se daný skript spustí a vyjde nám výsledek 10201 pro nejmenší palindrom a 906609 pro největší palindrom.

***Nyní máme nalezené oba palindromy, které vzniknou násobením dvou trojciferných čísel.***