### Vytvořte skript, který vypíše co nejpodrobnější seznam nainstalovaného softwaru ve Windows. Najděte alespoň 3 různé zdroje informací o instalovaném softwaru, ale nepoužívejte rozhraní WMI/CIM. Veškerý nalezený software spojte do jednoho seznamu ze kterého odstraníte duplicity.

Vytvoříme si skript pro získání nainstalovaného softwaru ve Windows (viz. script_windows.ps1). Pro ověření funkčnosti ho spustíme pomocí příkazu:

```
.\script_windows.ps1
```

tím získáme seznam instalovaného softwaru ze 3 různých zdrojů (konkr. registr Uninstall, event log a Get-Package).

***Nyní máme v konzoli vypsaný seznam nainstalovaného softwaru ve Windows ze 3 různých zdrojů***