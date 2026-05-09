#Requires -Version 5.1
<#
.SYNOPSIS
  Stages a clean copy of the HD submission tree and optionally creates a ZIP.

.DESCRIPTION
  Safe defaults: copy only files needed to rebuild and redeploy.
  Excludes common junk (see $ExcludeDirNames / patterns).

.PARAMETER RepoRoot
  Project root (parent of k8s-hd-custom and src). Default: two levels above this script.

.PARAMETER OutputDir
  Staging folder for the export. Default: submission/final-zip/export-staging

.PARAMETER ZipPath
  If set, compresses OutputDir to this .zip path.

.PARAMETER IncludeKubernetesManifests
  Include upstream kubernetes-manifests/ (reference baseline).

.PARAMETER IncludeDocs
  Include docs/ (upstream documentation).

.PARAMETER IncludeArchive
  Include archive/ (non-essential notes).

.EXAMPLE
  .\submission\final-zip\prepare-final-zip.ps1 -ZipPath .\submission\final-zip\sit727-hd-submission.zip
#>

[CmdletBinding()]
param(
  [string]$RepoRoot = "",
  [string]$OutputDir = "",
  [string]$ZipPath = "",
  [switch]$IncludeKubernetesManifests,
  [switch]$IncludeDocs,
  [switch]$IncludeArchive
)

$ErrorActionPreference = "Stop"

if (-not $RepoRoot) {
  $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}
if (-not $OutputDir) {
  $OutputDir = Join-Path $PSScriptRoot "export-staging"
}

Write-Host "Repo root: $RepoRoot"
Write-Host "Output:    $OutputDir"

if (Test-Path $OutputDir) {
  Remove-Item -Recurse -Force $OutputDir
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

# Directories we always copy if present
$copyDirs = @(
  "k8s-hd-custom",
  "src",
  "presentation-assets",
  "submission"
)

# Optional
if ($IncludeKubernetesManifests) { $copyDirs += "kubernetes-manifests" }
if ($IncludeDocs) { $copyDirs += "docs" }
if ($IncludeArchive) { $copyDirs += "archive" }

# Root files
$rootFiles = @(
  "README-HD-PROJECT.md",
  "README.md",
  ".gitignore"
)

foreach ($f in $rootFiles) {
  $p = Join-Path $RepoRoot $f
  if (Test-Path $p) {
    Copy-Item -Path $p -Destination (Join-Path $OutputDir $f) -Force
    Write-Host "Copied $f"
  }
}

# Directory names to exclude anywhere under copied trees (robocopy /XD)
$ExcludeDirNames = @(
  "node_modules",
  "__pycache__",
  ".pytest_cache",
  ".git",
  "bin",
  "obj",
  "vendor",
  "export-staging"
)

function Copy-TreeFiltered {
  param([string]$Source, [string]$Dest)
  if (-not (Test-Path $Source)) {
    Write-Warning "Skip missing: $Source"
    return
  }
  $xd = @()
  foreach ($name in $ExcludeDirNames) {
    $xd += "/XD"
    $xd += $name
  }
  $args = @($Source, $Dest, "/E", "/NFL", "/NDL", "/NJH", "/NJS", "/nc", "/ns", "/np") + $xd
  & robocopy @args | Out-Null
  $code = $LASTEXITCODE
  if ($code -ge 8) {
    throw "robocopy failed for $Source (exit $code)"
  }
}

foreach ($d in $copyDirs) {
  $src = Join-Path $RepoRoot $d
  $dst = Join-Path $OutputDir $d
  Write-Host "Copying $d ..."
  Copy-TreeFiltered -Source $src -Dest $dst
}

Write-Host ""
Write-Host "Staging complete: $OutputDir"

if ($ZipPath) {
  if (Test-Path $ZipPath) { Remove-Item -Force $ZipPath }
  Compress-Archive -Path (Join-Path $OutputDir "*") -DestinationPath $ZipPath -Force
  Write-Host "ZIP created: $ZipPath"
}

Write-Host ""
Write-Host "Next: verify contents, then submit the ZIP or folder per ZIP-CONTENTS.md."
