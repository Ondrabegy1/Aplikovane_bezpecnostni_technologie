### Vytvořte skript, který zjistí aktuální teplotu v Brně ve stupních celsia. Tuto teplotu zapíše na konec souboru teploty.txt, který bude na ploše. Dále v powershellu vytvořte úlohu, která tento skript bude spouštět každou hodinu.

Vytvoříme si skript pro získání teploty z API (viz script_temperature.ps1). Pro ověření funkčnosti ho spustíme pomocí příkazu:

```
.\script_temperature.ps1
```

tím získáme aktuální teplotu pro Brno (např. **2025-11-14 16:25:18 - Teplota v Brně: 6.7 °C**). Výsledek se nám zapíše do souboru teploty.txt, jenž se nachází na ploše. Nyní chceme tento proces zautomatizovat pomocí Plánovače úloh. Toho docílíme pomocí zadání následujícího skriptu do powershellu:

```
$task = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Ondra\Desktop\Škola\Aplikovane_bezpecnostni_technologie\solution7\script_temperature.ps1"'

schtasks /Create /SC HOURLY /MO 1 /TN "Zápis teplot" /TR "$task" /F
```

nyní máme tuto úlohu naplánovanou. V případě změny cesty pro skript ji upravíme podle potřeby.

***Nyní máme vytvořenou úlohu pro získání aktuální teploty v Brně, která bude provedena každou hodinu.***