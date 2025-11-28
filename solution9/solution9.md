### Vytvořte skript, který bude pravidelně (například každých 20 sekund) monitorovat obsah schránky (clipboardu). Pokud zjistí, že schránka obsahuje vybrané klíčové slovo, např. "password" nebo "token", tak její obsah vypíše do terminálu. Nalezené klíčové slovo ve výpisu barevně zvýrazněte. Pokud nedošlo ke změně obsahu clipboardu, tak už není třeba výpis opakovat.

Vytvoříme si skript pro monitoring obsahu clipboardu (viz. script_keylogger.ps1). Pro ověření funkčnosti ho spustíme pomocí příkazu:

```
.\script_keylogger.ps1
```

tím získáme každých 20 sekund obsah clipboardu, pokud je jeho obsahem výraz "password" nebo "token" (case insensitive). Toto heslo se nám následně vypíše i s časem záznamu. Heslo nebo token se vypíše jen jednou, dokud nedojde ke změně clipboardu.

***Nyní máme v konzoli každých 20 sekund vypsaný clipboard, je-li jeho obsahem "token" nebo "password".***

___

### Nainstalujte si správce hesel (např. KeepasXC) a ověřte, zda je odolný vůči monitorování clipboardu.

Stáhneme si správce hesel KeppasXC. Odkaz na stažení je [ZDE](https://keepassxc.org/download/#windows). Po stažení a instalaci správce hesel si vytvoříme novou databázi pro ukládání hesel. V nové databázi si následně vytvoříme nový záznam pro námi používanou webovou stránku. Zádáme správné hodnoty pro uživatele, heslo a URL adresu. Nyní můžeme tento záznam použít pro automatické vyplňění údajů.

Při tomto automatickém vyplnění či samotném zkopírování hesla si můžeme všimnout, že v pravém dolním rohu okna se zobrazí informace o vyčištění schránky po 10 sekundách od zkopírování či použití hesla. Je možné, že náš skript heslo zachytí. Nicméně je doporučené v tomto případě tento skript zrychlit (ideálně na 5 sekund).

***Nyní máme v konzoli zachycené heslo.***