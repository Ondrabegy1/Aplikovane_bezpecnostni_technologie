# Instalace z registrů Uninstall
function Get-InstalledFromRegistry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$IncludePerUser = $true
    )

    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    if ($IncludePerUser) {
        $paths += "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        $paths += "HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    }

    foreach ($p in $paths) {
        try {
            Get-ItemProperty -Path $p -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName } |
                Select-Object @{Name='Source';Expression={'Registry'}},
                              DisplayName,
                              DisplayVersion,
                              Publisher,
                              InstallDate,
                              UninstallString,
                              PSPath
        }
        catch {
            # ignorujeme chyby
        }
    }
}

# Instalace z event logu
function Get-InstalledFromEventLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [int]$DaysBack = 30
    )

    $time = (Get-Date).AddDays(-$DaysBack)
    Get-WinEvent -FilterHashtable @{
        LogName = 'Application';
        ProviderName = 'MsiInstaller';
        Id = 1033;
        StartTime = $time
    } -ErrorAction SilentlyContinue |
    ForEach-Object {
        $msg = $_.Message
        if ($msg -match "Product: (.+?) -- Installed") {
            $name = $matches[1].Trim()
        }
        else {
            $name = $msg
        }
        [PSCustomObject]@{
            Source           = 'EventLog'
            DisplayName      = $name
            DisplayVersion   = $null
            Publisher        = $null
            InstallDate      = $_.TimeCreated.ToString("yyyyMMdd")
            UninstallString  = $null
            PSPath           = "EventLogEntryId=$($_.Id)"
        }
    }
}

# Instalace pomocí Get-Package
function Get-InstalledFromPackage {
    [CmdletBinding()]
    param()

    Get-Package -ErrorAction SilentlyContinue |
        Select-Object @{Name='Source';Expression={'Get-Package'}},
                      Name,
                      Version,
                      ProviderName,
                      @{Name='DisplayName';Expression={$_.Name}},
                      @{Name='DisplayVersion';Expression={$_.Version}},
                      @{Name='Publisher';Expression={$_.ProviderName}},
                      @{Name='InstallDate';Expression={$null}},
                      @{Name='UninstallString';Expression={$null}},
                      @{Name='PSPath';Expression={$null}}
}

$regList     = Get-InstalledFromRegistry
$eventList   = Get-InstalledFromEventLog -DaysBack 60
$pkgList     = Get-InstalledFromPackage

$all = $regList + $eventList + $pkgList

$uniq = $all |
    Where-Object { $_.DisplayName } | 
    Sort-Object DisplayName, DisplayVersion |
    Select-Object -Unique DisplayName, DisplayVersion, Publisher, InstallDate, UninstallString, Source

$uniq | Format-Table -AutoSize