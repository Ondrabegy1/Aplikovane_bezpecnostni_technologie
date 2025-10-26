### K řešení následujících úloh použijte CIM rozhraní. Zjistěte vlastnosti třídy umožňující spravovat tiskárny. Změňte umístění faxu.

Do powershellu zadáme příkaz:

```
Get-CimClass -ClassName *Printer*
```

tím získáme všechny třídy obsahující slovo "Printer". Nás ovšem zajímají vlastnosti třídy umožňující spravovat tiskárny (konkrétně Win32_Printer). Pro zjištění vlastností zadáme příkaz:


```
Get-CimClass -ClassName Win32_Printer | Select-Object -ExpandProperty CimClassProperties
```

Tím dostaneme všechny vlastnosti tiskáren. Např. StatusInfo, Location, SystemName a podobně. Nyní chceme změnit umístění (Location) faxu. Vybral jsem si, že fax chci umístit do kanceláře 101. To uděláme pomocí následujícího příkazu:

```
Set-CimInstance -ClassName Win32_Printer -Filter "Name='Fax'" -Property @{Location='Kancelář 101'}
```

***Nyní máme nastavenou lokaci pro fax na Kancelář 101.***

___

### V informačních systémech MO se disk C: nazývá "Systém" a disk D: "Data". Zjistěte, jak se nazývá váš disk C: a případně ho přejmenujte na "Systém".

Do powershellu zadáme příkaz:

```
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object DeviceID, VolumeName
```

Tím zjistíme označení pro disk C:. Následně ho můžeme přejmenovat. Do powershellu zadáme tento skript:

```
$disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
if ($disk.VolumeName -ne 'Systém') {
    Set-CimInstance -InputObject $disk -Property @{VolumeName='Systém'}
}
```

***Tímto skriptem jsme změnili označení pro disk C: na Systém, pokud se již tak nejmenoval (viz. podmínka).***

___

### Vypište seznam nepoužitých účtů (účtů, ke kterým se nikdo nikdy nepřihlásil) a seznam uzamčených účtů. Použijte vhodný cmdlet a poté totéž udělejte pomocí CIM rozhraní.

Do powershellu zadáme příkaz:

```
#Pomocí cmdlet
Get-LocalUser | Where-Object { -not $_.LastLogon }

#Pomocí CIM rozhraní
Get-CimInstance -ClassName Win32_UserAccount | Where-Object { -not $_.LastLogon }
```

pro získání seznamu nepoužitých účtů podle preferované varianty. Toho jsme dosáhli pomocí dotazu na účty, které nemají zápis pro vlastnost LastLogon (posledního přihlášení). Dále zadáme:

```
#Pomocí cmdlet
Get-LocalUser | Where-Object { $_.Enabled -eq $false }

#Pomocí CIM rozhraní
Get-CimInstance -ClassName Win32_UserAccount | Where-Object { $_.Disabled -eq $true }
```

pro získání seznamu uzamčených účtů podle preferované varianty. Toho jsme dosáhli pomocí dotazu na účty, které mají zápis True pro vlastnost Disabled

***Nyní jsme získaly seznamy pro nepoužité a uzamčené účty.***