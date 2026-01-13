[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$dataDir = Join-Path $scriptDir "Data"

$files = "security1.evtx","security2.evtx"

$ignored = "SYSTEM","NETWORK SERVICE","LOCAL SERVICE","ANONYMOUS LOGON","WDAGUtilityAccount","defaultuser0","Guest", "LOCAL MANAGEMENT"

$sum = 0

foreach ($file in $files) {
    $fullPath = Join-Path $dataDir $file

    if (Test-Path $fullPath) {
        Write-Host "`n--- Zpracovávám: $file ---" -ForegroundColor Cyan

        try {
            $events = Get-WinEvent -Path $fullPath -ErrorAction Stop
        } catch {
            Write-Host " -> Žádná data nebo chyba čtení." -ForegroundColor Gray
            continue
        }

        $relevant = $events | Where-Object {
            $id = $_.Id
            $name = $null

            if ($id -eq 4624) {
                $logonType = $_.Properties[8].Value
                if ($logonType -in 2, 10) { $name = $_.Properties[5].Value }
            }
            elseif ($id -eq 4647) { $name = $_.Properties[1].Value }
            elseif ($id -in 4720,4722,4723,4724,4725,4726,4732,4728) { $name = $_.Properties[0].Value }

            $name -and 
            ($name -notmatch "\$$") -and 
            ($ignored -notcontains $name) -and 
            ($name -notmatch "^UMFD") -and 
            ($name -notmatch "^DWM")
        }

        $sorted = $relevant | Sort-Object TimeCreated

        if ($sorted) {
            $sorted | Select-Object TimeCreated, Id, @{Name="Uživatel"; Expression={
                if ($_.Id -eq 4624) { $_.Properties[5].Value }
                elseif ($_.Id -eq 4647) { $_.Properties[1].Value }
                elseif ($_.Id -in 4720,4722,4723,4724,4725,4726,4728,4732) { $_.Properties[0].Value }
                else { "Neznámý" }
            }}, @{Name="Akce"; Expression={
                switch ($_.Id) {
                    4624 { "Přihlášení (Interaktivní)" }
                    4647 { "Odhlášení" }
                    4720 { "Vytvoření účtu" }
                    4722 { "Povolení účtu" }
                    4724 { "Změna hesla" }
                    4732 { "Přidání do skupiny" }
                    4728 { "Přidání do glob. skupiny" }
                    default { "Jiná uživ. aktivita ($($_.Id))" }
                }
            }} | Format-Table -AutoSize

            $count = ($sorted | Measure-Object).Count
        } else {
            $count = 0
            Write-Host " -> Žádné uživatelské události." -ForegroundColor Gray
        }

        Write-Host "Počet validních událostí v $file : $count" -ForegroundColor Yellow
        $sum += $count
    }
}

Write-Host "`n----------------------------------"
Write-Host "Celkový počet událostí skutečných uživatelů: $sum" -ForegroundColor Green
Write-Host "----------------------------------"

Read-Host "Stiskni ENTER pro ukončení..."