#!/usr/bin/env pwsh
# DiaFit — Phase 12: APK Build Script
# Run this from: C:\Users\JOBIN\.gemini\antigravity\scratch\DiaFit\diafit_mobile
# Flutter must be on PATH or use full path

$FlutterExe = "C:\Users\JOBIN\Downloads\flutter\bin\flutter.bat"
$ProjectDir = $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DiaFit — Flutter APK Builder" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Clean
Write-Host "Step 1: Cleaning build cache..." -ForegroundColor Yellow
& $FlutterExe clean

# 2. Get dependencies
Write-Host "Step 2: Fetching dependencies..." -ForegroundColor Yellow
& $FlutterExe pub get

# 3. Build APK (release)
Write-Host "Step 3: Building release APK..." -ForegroundColor Yellow
& $FlutterExe build apk --release --target-platform android-arm64

if ($LASTEXITCODE -eq 0) {
    $apkPath = Join-Path $ProjectDir "build\app\outputs\flutter-apk\app-release.apk"
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  BUILD SUCCESSFUL! ✅" -ForegroundColor Green
    Write-Host "  APK: $apkPath" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green

    # Open output folder
    explorer.exe (Join-Path $ProjectDir "build\app\outputs\flutter-apk")
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  BUILD FAILED ❌ Check errors above" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
}
