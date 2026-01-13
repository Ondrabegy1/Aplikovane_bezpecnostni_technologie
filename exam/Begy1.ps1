Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$desktopPath = [Environment]::GetFolderPath("Desktop")
$screensPath = Join-Path $desktopPath "Screens"

if (!(Test-Path $screensPath)) {
    New-Item -ItemType Directory -Path $screensPath | Out-Null
}

while ($true) {
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    $graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $filePath = Join-Path $screensPath "screenshot_$timestamp.png"

    $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)

    $graphics.Dispose()
    $bitmap.Dispose()

    Start-Sleep -Seconds 30
}