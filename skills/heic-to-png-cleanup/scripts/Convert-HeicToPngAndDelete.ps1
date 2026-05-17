[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceDir,

    [string]$OutputDir,

    [switch]$Overwrite
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-ExistingDirectory {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Directory does not exist: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path
}

function Find-Magick {
    $cmd = Get-Command magick -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    $candidates = @()
    $programFiles = ${env:ProgramFiles}
    if ($programFiles) {
        $candidates += Get-ChildItem -LiteralPath $programFiles -Directory -Filter "ImageMagick-*" -ErrorAction SilentlyContinue |
            ForEach-Object { Join-Path $_.FullName "magick.exe" }
    }

    $localPrograms = Join-Path $env:LOCALAPPDATA "Programs"
    if (Test-Path -LiteralPath $localPrograms -PathType Container) {
        $candidates += Get-ChildItem -LiteralPath $localPrograms -Directory -Filter "ImageMagick-*" -ErrorAction SilentlyContinue |
            ForEach-Object { Join-Path $_.FullName "magick.exe" }
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }
    }

    throw "ImageMagick magick.exe was not found. Install ImageMagick or add magick.exe to PATH."
}

function Test-PathWithinDirectory {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Directory
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $fullDirectory = [System.IO.Path]::GetFullPath($Directory)
    if (-not $fullDirectory.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $fullDirectory += [System.IO.Path]::DirectorySeparatorChar
    }
    return $fullPath.StartsWith($fullDirectory, [System.StringComparison]::OrdinalIgnoreCase)
}

$sourceRoot = Resolve-ExistingDirectory -Path $SourceDir
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $sourceRoot "converted"
}

if (-not (Test-Path -LiteralPath $OutputDir -PathType Container)) {
    if ($PSCmdlet.ShouldProcess($OutputDir, "create output directory")) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }
}

if (-not (Test-Path -LiteralPath $OutputDir -PathType Container)) {
    throw "Output directory is not available: $OutputDir"
}

$outputRoot = (Resolve-Path -LiteralPath $OutputDir).Path
$magick = Find-Magick
$files = Get-ChildItem -LiteralPath $sourceRoot -File |
    Where-Object { $_.Extension -in @(".heic", ".HEIC", ".heif", ".HEIF") } |
    Sort-Object Name

$converted = 0
$deleted = 0
$skipped = 0
$failed = 0
$failures = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
    $outputPath = Join-Path $outputRoot ($file.BaseName + ".png")

    if ((Test-Path -LiteralPath $outputPath -PathType Leaf) -and -not $Overwrite) {
        $existing = Get-Item -LiteralPath $outputPath
        if ($existing.Length -gt 0) {
            Write-Host "SKIP existing output: $($file.Name) -> $($existing.Name)"
            $skipped++
            if (Test-PathWithinDirectory -Path $file.FullName -Directory $sourceRoot) {
                if ($PSCmdlet.ShouldProcess($file.FullName, "delete original after verified existing PNG")) {
                    Remove-Item -LiteralPath $file.FullName -Force
                    $deleted++
                }
            }
            continue
        }
    }

    try {
        if ($PSCmdlet.ShouldProcess($file.FullName, "convert to $outputPath")) {
            & $magick $file.FullName $outputPath
            if ($LASTEXITCODE -ne 0) {
                throw "ImageMagick exited with code $LASTEXITCODE"
            }
        }

        if (-not (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
            throw "Expected output was not created: $outputPath"
        }
        $output = Get-Item -LiteralPath $outputPath
        if ($output.Length -le 0) {
            throw "Output file is empty: $outputPath"
        }

        $converted++
        if (-not (Test-PathWithinDirectory -Path $file.FullName -Directory $sourceRoot)) {
            throw "Refusing to delete file outside source directory: $($file.FullName)"
        }
        if ($PSCmdlet.ShouldProcess($file.FullName, "delete original after successful conversion")) {
            Remove-Item -LiteralPath $file.FullName -Force
            $deleted++
        }
        Write-Host "OK $($file.Name) -> $($output.Name)"
    }
    catch {
        $failed++
        $message = "$($file.FullName): $($_.Exception.Message)"
        $failures.Add($message)
        Write-Warning $message
    }
}

Write-Host "Summary: converted=$converted deleted=$deleted skipped=$skipped failed=$failed output=$outputRoot"
if ($failures.Count -gt 0) {
    Write-Host "Failures:"
    foreach ($failure in $failures) {
        Write-Host " - $failure"
    }
    exit 1
}
