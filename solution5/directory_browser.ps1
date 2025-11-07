param(
    [string]$StartPath = (Get-Location).Path
)

function Get-FileCount {
    param([string]$Path)
    try {
        $files = Get-ChildItem -LiteralPath $Path -File -Force -ErrorAction Stop
        return $files.Count
    } catch {
        return 0
    }
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

    try {
        $dirs = Get-ChildItem -LiteralPath $current.FullName -Directory -Force | Sort-Object Name
    } catch {
        $dirs = @()
    }

    if ($dirs.Count -eq 0) {
        Write-Host "Žádné podsložky v tomto adresáři." -ForegroundColor DarkGray
    } else {
        $summary = @()
        foreach ($d in $dirs) {
            $count = Get-FileCount -Path $d.FullName
            $summary += [PSCustomObject]@{
                Name  = $d.Name
                Path  = $d.FullName
                Count = $count
            }
        }

        $minCount = ($summary | Measure-Object -Property Count -Minimum).Minimum
        $maxCount = ($summary | Measure-Object -Property Count -Maximum).Maximum

        $minDirs = $summary | Where-Object { $_.Count -eq $minCount }
        $maxDirs = $summary | Where-Object { $_.Count -eq $maxCount }

        Write-Host "Nejmenší podsložka(y) podle počtu souborů (zobrazeny NÁZVY, bez počtu):" -ForegroundColor Green
        foreach ($m in $minDirs) {
            Write-Host "  - $($m.Name)"
        }

        Write-Host ""
        Write-Host "Největší podsložka(y) podle počtu souborů (zobrazeny NÁZVY, bez počtu):" -ForegroundColor Magenta
        foreach ($M in $maxDirs) {
            Write-Host "  - $($M.Name)"
        }

        Write-Host ""
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