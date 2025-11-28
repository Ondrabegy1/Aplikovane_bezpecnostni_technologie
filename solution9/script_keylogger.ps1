$watchTerms = @("password", "token")

$previousClip = $null

function Show-MarkedText {
    param(
        [string] $InputString,
        [string[]] $Terms
    )

    if ([string]::IsNullOrEmpty($InputString)) { return }

    $regexPattern = ($Terms | ForEach-Object { [regex]::Escape($_) }) -join "|"
    $found = [regex]::Matches($InputString, $regexPattern, 'IgnoreCase')

    if ($found.Count -eq 0) {
        Write-Host $InputString
        return
    }

    $currentIndex = 0

    foreach ($f in $found) {
        if ($f.Index -gt $currentIndex) {
            $plain = $InputString.Substring($currentIndex, $f.Index - $currentIndex)
            Write-Host -NoNewline $plain
        }

        Write-Host -NoNewline $f.Value -ForegroundColor Yellow
        $currentIndex = $f.Index + $f.Length
    }

    if ($currentIndex -lt $InputString.Length) {
        Write-Host $InputString.Substring($currentIndex)
    } else {
        Write-Host ""
    }
}

Write-Host "Keylogger běží – ukončíš ho pomocí Ctrl+C."
Write-Host "Vyhledávané výrazy: $($watchTerms -join ', ')"
Write-Host ""

while ($true) {
    try {
        $clipData = Get-Clipboard -Raw -ErrorAction Stop
    } catch {
        $clipData = $null
    }

    if ($clipData -ne $previousClip -and -not [string]::IsNullOrWhiteSpace($clipData)) {
        $previousClip = $clipData

        $triggered = $watchTerms | Where-Object { $clipData -match [regex]::Escape($_) }

        if ($triggered) {
            $timestamp = (Get-Date -Format "HH:mm:ss")
            Write-Host ""
            Write-Host "[$timestamp] Sledovaný výraz:" -ForegroundColor Cyan
            Write-Host "----------------------------------------------"

            $clipData -split "`r?`n" | ForEach-Object {
                Show-MarkedText -InputString $_ -Terms $watchTerms
            }

            Write-Host "----------------------------------------------"
        }
    }

    Start-Sleep -Seconds 2
}
