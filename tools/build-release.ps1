<#
.SYNOPSIS
    Builds the Release Package (lrueckert-DmgMeter.zip) for the Steam Workshop.

.DESCRIPTION
    Creates lrueckert-DmgMeter.zip in the repo root containing
    mods-unpacked/lrueckert-DmgMeter/ with only the files the game needs:
    all .gd, .tscn and .tres files plus manifest.json and README.md.
    The working tree is packaged as-is; uncommitted changes only produce a warning.
    Afterwards it opens Brotato's Steam Workshop content folder in Explorer.

.PARAMETER WorkshopPath
    Folder to open after building. Defaults to Brotato's (app 1942280) Workshop content folder.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\build-release.ps1
#>

param(
    [string]$WorkshopPath = 'C:\Program Files (x86)\Steam\steamapps\workshop\content\1942280'
)

$ErrorActionPreference = 'Stop'

$ModId = 'lrueckert-DmgMeter'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ZipPath = Join-Path $RepoRoot "$ModId.zip"
$ZipPrefix = "mods-unpacked/$ModId/"
$RootFiles = @('manifest.json', 'README.md')
$Extensions = @('.gd', '.tscn', '.tres')
$ExcludedDirs = @('.git', '.vscode', 'docs', 'tools')

$manifestPath = Join-Path $RepoRoot 'manifest.json'
try {
    $manifest = Get-Content -Raw -Encoding UTF8 $manifestPath | ConvertFrom-Json
} catch {
    throw "manifest.json is not valid JSON: $($_.Exception.Message)"
}
$manifestId = "$($manifest.namespace)-$($manifest.name)"
if ($manifestId -ne $ModId) {
    throw "manifest.json namespace-name is '$manifestId', expected '$ModId'."
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    $dirty = @(git -C $RepoRoot status --porcelain)
    if ($dirty.Count -gt 0) {
        Write-Warning "Packaging uncommitted changes:"
        $dirty | ForEach-Object { Write-Warning "  $_" }
    }
}

$files = @($RootFiles | ForEach-Object { Get-Item (Join-Path $RepoRoot $_) })
$files += Get-ChildItem -Path $RepoRoot -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($RepoRoot.Length + 1)
    $topDir = $relative.Split([IO.Path]::DirectorySeparatorChar)[0]
    ($Extensions -contains $_.Extension.ToLowerInvariant()) -and ($ExcludedDirs -notcontains $topDir)
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

if (Test-Path $ZipPath) { Remove-Item $ZipPath }
$zip = [IO.Compression.ZipFile]::Open($ZipPath, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in $files) {
        # Zip entries must use forward slashes so Godot finds them on every platform.
        $relative = $file.FullName.Substring($RepoRoot.Length + 1).Replace('\', '/')
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, $file.FullName, $ZipPrefix + $relative, [IO.Compression.CompressionLevel]::Optimal
        ) | Out-Null
    }
} finally {
    $zip.Dispose()
}

Write-Host "Built $ModId v$($manifest.version_number): $ZipPath ($($files.Count) files)"

if (Test-Path -LiteralPath $WorkshopPath) {
    Invoke-Item -LiteralPath $WorkshopPath
} else {
    Write-Warning "Workshop folder not found: $WorkshopPath"
}
