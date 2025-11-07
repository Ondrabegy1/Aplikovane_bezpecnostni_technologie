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