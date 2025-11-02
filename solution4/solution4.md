### V registru zjistěte, zda je pro přihlášení uživatele zapnuta klávesa Numlock. Pokud není, tak nastavte odpovídající položku registru na hodnotu 2.

Do powershellu zadáme příkaz:

```
Get-ItemProperty -Path 'HKCU:\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators'
```

tím získáme vlastnosti pro klávesnici z registru, přímo konkrétně hodnotu InitialKeyboardIndicators. Tato hodnota indikuje, zda-li jsou klávesy jako NumLock, CapsLock či ScrollLock zapnuty při přihlášení uživatele. Chceme, aby hodnota byla nastavena na 2. Pokud tomu tak není, zadáme příkaz:

```
Set-ItemProperty -Path 'HKCU:\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -Value '2'
```

a pak znovu zadáme předchozí příkaz pro zjištění a oveření této hodnoty.

***Nyní máme nastavené, že klávesa NumLock bude při přihlášení uživatele spuštěna.***

___

### Vytvořte podklíč registru HKEY_CURRENT_USER, který nazvete Hrátky s PowerShellem. V něm vytvořte hodnoty obsahující jméno vašeho uživatelského účtu, jméno počítače, aktuální datum a verzi PowerShellu. Pro potvrzení provedené akce si všechny tyto informace vypište. 

Do powershellu zadáme příkaz:

```
New-Item -Path 'HKCU:\Hrátky s PowerShellem' -Force
```

Nyní budeme vkládat hodnoty do podklíče. Pokud neznáme naše hodnoty, které chceme uložit, můžeme zadat následující příkazy pro jejich zjištění:

```
#Jméno uživatelského účtu

$user = $env:USERNAME
$user

#Jméno počítače

$computer = $env:COMPUTERNAME
$computer

#Aktuální datum

$date = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
$date

#Verze powershellu

$psver = $PSVersionTable.PSVersion.ToString()
$psver

#Příkazy pro vložení všech hodnot do podklíče Hrátky s PowerShellem

New-ItemProperty -Path 'HKCU:\Hrátky s PowerShellem' -Name 'UserName'      -PropertyType String -Value $user   -Force
New-ItemProperty -Path 'HKCU:\Hrátky s PowerShellem' -Name 'ComputerName'  -PropertyType String -Value $computer -Force
New-ItemProperty -Path 'HKCU:\Hrátky s PowerShellem' -Name 'DateSaved'     -PropertyType String -Value $date   -Force
New-ItemProperty -Path 'HKCU:\Hrátky s PowerShellem' -Name 'PowerShellVer' -PropertyType String -Value $psver  -Force
```

Pro ověření obsahu podklíče vložíme příkaz:

```
Get-ItemProperty -Path 'HKCU:\Hrátky s PowerShellem' | Format-List
```

***Nyní máme vytvořený podklíč "Hrátky s PowerShellem" s požadovanými hodnotami.***

*Pro případné smazání podklíče vložíme příkaz:*

```
Remove-Item -Path 'HKCU:\Hrátky s PowerShellem' -Recurse -Force
```