# Generates icons/icon-192.png and icons/icon-512.png with a dark background
# and centred "BB" text. Re-run anytime to regenerate.
Add-Type -AssemblyName System.Drawing

function New-AppIcon {
    param(
        [int]$Size,
        [string]$OutPath
    )

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    # Dark background (matches manifest theme/background colors)
    $bg = [System.Drawing.Color]::FromArgb(26, 26, 26)
    $g.Clear($bg)

    # Subtle inner accent square (slight depth, stays well inside maskable safe zone)
    $accentColor = [System.Drawing.Color]::FromArgb(36, 36, 36)
    $accentBrush = New-Object System.Drawing.SolidBrush($accentColor)
    $pad = [int]($Size * 0.12)
    $inner = [int]($Size - ($pad * 2))
    $accentRect = New-Object System.Drawing.Rectangle $pad, $pad, $inner, $inner
    $g.FillRectangle($accentBrush, $accentRect)
    $accentBrush.Dispose()

    # "BB" text in white, sized to sit well within the maskable safe zone
    $fontSize = [int]($Size * 0.32)
    try {
        $font = New-Object System.Drawing.Font("Arial Black", $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    } catch {
        $font = New-Object System.Drawing.Font("Arial", $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    }

    $brush = [System.Drawing.Brushes]::White
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $format.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap

    $rect = New-Object System.Drawing.RectangleF 0, 0, ([float]$Size), ([float]$Size)
    $g.DrawString("BB", $font, $brush, $rect, $format)

    $g.Dispose()
    $font.Dispose()
    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()

    Write-Host "Wrote $OutPath ($Size x $Size)"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$iconsDir = Join-Path $scriptDir "icons"
if (-not (Test-Path $iconsDir)) {
    New-Item -ItemType Directory -Path $iconsDir | Out-Null
}

New-AppIcon -Size 192 -OutPath (Join-Path $iconsDir "icon-192.png")
New-AppIcon -Size 512 -OutPath (Join-Path $iconsDir "icon-512.png")

Write-Host "Done."
