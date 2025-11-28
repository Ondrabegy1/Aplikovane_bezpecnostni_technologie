### Vytvořte skript, který bude pomocí invoke-webrequest simulovat útok hrubou silou na aplikaci DVWA. DVWA vyžaduje, abyste se přihlásili (např. jako "admin" s heslem "password") a získali platné PHPSESSID. Dále je třeba nastavit úroveň obtížnosti na low (v cookie je parametr security=low). Nakonec útočíte typicky na adrese http://localhost/dvwa/vulnerabilities/brute/.

Vytvoříme si skript, který bude simulovat útok hrubou silou (viz. script_DVWA.ps1). Pro ověření funkčnosti ho spustíme pomocí příkazu:

```
.\script_DVWA.ps1
```

v konzoli můžeme vidět postup tohoto skriptu. Od získání CSRF tokenu, dále přes přihlášení do samotné aplikace až po následný útok hrubou silou a zjištění správného hesla.

*Pozn: zádrhel dost často bývá v potřebě nalezení druhého CSRF tokenu pro změnu security*

***Nyní máme v konzoli vypsané správné heslo pro přihlášení k účtu admin.***