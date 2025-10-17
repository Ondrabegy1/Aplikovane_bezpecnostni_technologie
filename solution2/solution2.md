### Modifikujte profil Powershellu tak, aby se po spuštění vypsala žlutou barvou informace o aktuální "execution policy" a zelenou barvou cesta k tomuto profilu.

Do powershellu zadáme příkaz:

```
$PROFILE
```

tím zjistíme cestu k aktuálnímu profilu. Pokud daný soubor neexistuje, zadáme:

```
New-Item -Path $PROFILE -ItemType File -Force
```

tím se nám vytvoří soubor Microsoft.PowerShell_profile.ps1. Následně zadáme:

```
notepad $PROFILE
```

tím se nám otevře soubor Microsoft.PowerShell_profile.ps1 v poznámkovém bloku. Do otevřeného souboru zadáme:

```
# --- Zobrazení informací po startu ---

Write-Host "Aktuální execution policy: $(Get-ExecutionPolicy)" -ForegroundColor Yellow
Write-Host "Cesta k profilu: $PROFILE" -ForegroundColor Green
```
***Nyní když ukončíme a znovu spustíme Powershell, vypíšeme se nám informace o aktuální "execution policy" žlutě a cesta k profilu zeleně.***

___

### Vytvořte alias np (notepad.exe) a ct (control.exe). Exportujte je do formátu JSON. Potom oba aliasy smažte a obnovte je z JSON souboru.

Do powershellu zadáme příkaz:

```
New-Alias np notepad.exe
New-Alias ct control.exe
```

tím jsme vytvořili nové aliasy pro otevření poznámkového bloku a ovládacího panelu. Pro ověření zadáme:

```
Get-Alias np, ct
```

a jestli je všechno v pořádku, nyní převedeme dané aliasy na objekt a uložíme je v souboru JSON. To uděláme zadáním:

```
Get-Alias np, ct | Select-Object Name, Definition | ConvertTo-Json | Out-File "$env:USERPROFILE\aliasy.json"
```

Nyní se nám vytvořil JSON soubor s názvem aliasy.json s cestou C:\Users\<uživatel>\. Nyní aliasy smažeme v powershellu pomocí příkazu:

```
Remove-Item Alias:np
Remove-Item Alias:ct
```

pro ověření, že jsou smazány zadáme:

```
Get-Alias np, ct
```

Pokud jsou opravdu smazány, nyní je obnovíme z JSON souboru aliasy.json pomocí:

```
$aliasy = Get-Content "$env:USERPROFILE\aliasy.json" | ConvertFrom-Json
foreach ($a in $aliasy) {
    New-Alias -Name $a.Name -Value $a.Definition
}
```

a zkontrolujeme jejich přítomnost pomocí:

```
Get-Alias np, ct
```

***Tímto způsobem jsme získali aliasy z JSON souboru.***