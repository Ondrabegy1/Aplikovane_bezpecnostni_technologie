### Vytvořte skript, který z webové stránky extrahuje všechna jedinečná slova o stanovené délce. Parametry pro spouštění skriptu budou URL a delka. Pokud při spuštění skriptu nebudou zadány, vypíše se stručná nápověda o způsobu použití.

Vytvoříme si skript pro webscraper, který bude mít proměnlivé parametry pro URL a délku (viz. script_webscraper.ps1). Pro ověření funkčnosti ho spustíme pomocí příkazu:

```
.\script_webscraping.ps1
```

kde se nám vypíše syntax pro příkaz. Do powershellu zadáme příklad:

```
powershell -ExecutionPolicy Bypass -File script_webscraping.ps1 -url https://sites.google.com/view/powershell2025/z%C3%A1po%C4%8Det -delka 5
```

v konzoli můžeme dále vidět vypsaná slova ze zadané stránky o dané velikosti, kterou jsme zadali do příkazu.

***Nyní máme vypsaná všechna slova o požadované délce z požadované stránky.***