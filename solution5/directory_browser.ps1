param(
    [string]$StartPath = (Get-Location).Path
)

function Format-Size {
    param([long]$Bytes)
    if ($null -eq $Bytes) { return "" }
    if ($Bytes -lt 1024) { return "$Bytes B" }
    $kb = $Bytes / 1KB
    if ($kb -lt 1024) { return "{0:N2} KB" -f $kb }
    $mb = $Bytes / 1MB
    if ($mb -lt 1024) { return "{0:N2} MB" -f $mb }
    $gb = $Bytes / 1GB
    return "{0:N2} GB" -f $gb
}

function Get-FileCount {
    param([string]$Path)
    try {
        $files = Get-ChildItem -LiteralPath $Path -File -Force -ErrorAction Stop
        return $files.Count
    } catch {
        return 0
    }
}

function Get-MinMaxFiles {
    param([string]$Path)
    try {
        $files = Get-ChildItem -LiteralPath $Path -File -Force -ErrorAction Stop
    } catch {
        $files = @()
    }

    if ($files.Count -eq 0) {
        return @{ Min = $null; Max = $null }
    }

    $sorted = $files | Sort-Object Length
    $min = $sorted | Select-Object -First 1
    $max = $sorted | Select-Object -Last 1

    return @{ Min = $min; Max = $max }
}

$current = (Get-Item -LiteralPath $StartPath -ErrorAction SilentlyContinue)
if (-not $current) {
    Write-Error "Startovní cesta nebyla nalezena: $StartPath"
    exit 1
}

while ($true) {
    Clear-Host
    Write-Host "Interaktivní prohlížeč adresářů - aktuální cesta:" -ForegroundColor Cyan
    Write-Host "  $($current.FullName)" -ForegroundColor Yellow
    Write-Host ""

    $currentFileCount = Get-FileCount -Path $current.FullName
    Write-Host "Počet souborů v aktuálním adresáři: $currentFileCount" -ForegroundColor Green
    Write-Host ""

    $minmax = Get-MinMaxFiles -Path $current.FullName
    if ($null -eq $minmax.Min -and $null -eq $minmax.Max) {
        Write-Host "V aktuálním adresáři nejsou žádné soubory." -ForegroundColor DarkGray
    } else {
        if ($minmax.Min) {
            $minText = "{0} ({1})" -f $minmax.Min.Name, (Format-Size $minmax.Min.Length)
            Write-Host "Nejmenší soubor: $minText" -ForegroundColor Green
        } else {
            Write-Host "Nejmenší soubor: (žádný)" -ForegroundColor DarkGray
        }
        if ($minmax.Max) {
            $maxText = "{0} ({1})" -f $minmax.Max.Name, (Format-Size $minmax.Max.Length)
            Write-Host "Největší soubor: $maxText" -ForegroundColor Magenta
        } else {
            Write-Host "Největší soubor: (žádný)" -ForegroundColor DarkGray
        }
    }

    Write-Host ""

    try {
        $dirs = Get-ChildItem -LiteralPath $current.FullName -Directory -Force | Sort-Object Name
    } catch {
        $dirs = @()
    }

    if ($dirs.Count -eq 0) {
        Write-Host "Žádné podsložky v tomto adresáři." -ForegroundColor DarkGray
    } else {
        Write-Host "Seznam podsložek (pro volbu čísla):"
        $index = 1
        foreach ($d in $dirs) {
            Write-Host ("  [{0}] {1}" -f $index, $d.Name)
            $index++
        }
    }

    Write-Host ""
    Write-Host "Volby: zadejte číslo pro vstup do složky, U pro o úroveň výš, Q pro ukončení."
    $input = Read-Host "Vaše volba"

    if ([string]::IsNullOrWhiteSpace($input)) { continue }

    switch ($input.ToUpper()) {
        'Q' {
            return
        }
        'U' {
            if ($current.Parent) {
                $current = $current.Parent
            } else {
                Write-Host "Jste v kořenovém adresáři - nelze jít výš." -ForegroundColor DarkYellow
                Start-Sleep -Seconds 1
            }
            continue
        }
        default {
            if ($input -as [int]) {
                $sel = [int]$input
                if ($sel -ge 1 -and $sel -le $dirs.Count) {
                    $chosen = $dirs[$sel - 1]
                    $current = Get-Item -LiteralPath $chosen.FullName
                } else {
                    Write-Host "Neplatné číslo. Zadejte číslo z rozmezí 1..$($dirs.Count)." -ForegroundColor DarkRed
                    Start-Sleep -Seconds 1
                }
            } else {
                Write-Host "Neznámá volba: $input" -ForegroundColor DarkRed
                Start-Sleep -Seconds 1
            }
        }
    }
}

Write-Host "Program ukončen." -ForegroundColor Green