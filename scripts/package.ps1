$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================="
Write-Host " Maria Kindergarten ERP Package Tool"
Write-Host "========================================="
Write-Host ""

# Project Root
$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
Set-Location $ProjectRoot

# Folders
$ReportsFolder = Join-Path $ProjectRoot "reports"
$ReleaseFolder = Join-Path $ProjectRoot "releases"

New-Item -ItemType Directory -Force -Path $ReportsFolder | Out-Null
New-Item -ItemType Directory -Force -Path $ReleaseFolder | Out-Null

# Read version from pubspec.yaml
$Version = "unknown"
$Pubspec = Join-Path $ProjectRoot "pubspec.yaml"

if (Test-Path $Pubspec) {
    $VersionLine = Select-String "^version:" $Pubspec
    if ($VersionLine) {
        $Version = $VersionLine.Line.Replace("version:", "").Trim()
    }
}

# Date
$Date = Get-Date -Format "yyyy-MM-dd_HH-mm"

# Analyze
Write-Host "Running flutter analyze..."
flutter analyze *> "$ReportsFolder\flutter_analyze.txt"

# Tests
Write-Host "Running flutter test..."
flutter test *> "$ReportsFolder\flutter_test.txt"

# Package name
$ZipName = "MariaKindergartenERP_v$Version`_$Date.zip"
$ZipPath = Join-Path $ReleaseFolder $ZipName

if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

Write-Host "Creating package..."

$Exclude = @(
".git",
".dart_tool",
"build",
".idea",
".vscode",
"releases",
"reports"
)

$Files = Get-ChildItem $ProjectRoot -Recurse | Where-Object {

    foreach($e in $Exclude){

        if($_.FullName -match "\\$e\\"){
            return $false
        }

    }

    return -not $_.PSIsContainer
}

Compress-Archive `
    -Path $Files.FullName `
    -DestinationPath $ZipPath `
    -Force

# Statistics
$FileCount = ($Files | Measure-Object).Count
$ZipSize = [Math]::Round((Get-Item $ZipPath).Length / 1MB,2)

# Report
$Report = @"
# PACKAGE REPORT

Generated:
$(Get-Date)

Project Version:
$Version

Flutter Analyze:
reports/flutter_analyze.txt

Flutter Test:
reports/flutter_test.txt

Files:
$FileCount

Package:
$ZipName

Package Size:
$ZipSize MB
"@

$Report | Set-Content "$ProjectRoot\PACKAGE_REPORT.md"

Write-Host ""
Write-Host "========================================="
Write-Host "Package created successfully"
Write-Host "========================================="
Write-Host ""
Write-Host "Version      : $Version"
Write-Host "Files        : $FileCount"
Write-Host "Package Size : $ZipSize MB"
Write-Host ""
Write-Host "Package:"
Write-Host $ZipPath
Write-Host ""