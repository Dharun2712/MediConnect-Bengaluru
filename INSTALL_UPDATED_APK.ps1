#!/usr/bin/env pwsh
# Install Updated APK Script
# This will install the newly built APK with all features

Write-Host "=== LifeLink APK Installation ===" -ForegroundColor Cyan
Write-Host "Version: 2.0.0+4 with 11 hospitals and hardcoded ambulance details" -ForegroundColor Yellow
Write-Host ""

$apkPath = "build\app\outputs\flutter-apk\app-release.apk"

# Check if APK exists
if (!(Test-Path $apkPath)) {
    Write-Host "ERROR: APK not found at $apkPath" -ForegroundColor Red
    Write-Host "Please run: flutter build apk --release" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ APK found: $apkPath" -ForegroundColor Green

# Check for connected devices
Write-Host ""
Write-Host "Checking for connected devices..." -ForegroundColor Cyan
$devices = adb devices | Select-String -Pattern "device$"

if ($devices.Count -eq 0) {
    Write-Host ""
    Write-Host "No devices found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please connect your phone via USB and enable USB Debugging:" -ForegroundColor Yellow
    Write-Host "1. Settings → About Phone → Tap 'Build Number' 7 times" -ForegroundColor White
    Write-Host "2. Settings → Developer Options → Enable 'USB Debugging'" -ForegroundColor White
    Write-Host "3. Connect phone to PC with USB cable" -ForegroundColor White
    Write-Host "4. Allow USB debugging on phone when prompted" -ForegroundColor White
    Write-Host ""
    Write-Host "OR copy the APK to your phone and install manually" -ForegroundColor Yellow
    Write-Host "APK location: $((Get-Item $apkPath).FullName)" -ForegroundColor White
    exit 1
}

Write-Host "✓ Device connected" -ForegroundColor Green

# Uninstall old version first
Write-Host ""
Write-Host "Uninstalling old version..." -ForegroundColor Cyan
adb uninstall com.example.sdg 2>$null
Write-Host "✓ Old version removed (if it existed)" -ForegroundColor Green

# Install new APK
Write-Host ""
Write-Host "Installing new APK (this may take 30-60 seconds)..." -ForegroundColor Cyan
adb install -r $apkPath

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ Installation successful!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "New features included:" -ForegroundColor Yellow
    Write-Host "  • 11 hospital markers with distance labels" -ForegroundColor White
    Write-Host "  • Hardcoded ambulance details (Driver: Kishore, TN 28 8976, Sakthi Hospital)" -ForegroundColor White
    Write-Host "  • Enhanced background notifications" -ForegroundColor White
    Write-Host ""
    Write-Host "Open the app and check an ASSESSED request to see the changes!" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Installation failed!" -ForegroundColor Red
    Write-Host "Try installing manually from: $((Get-Item $apkPath).FullName)" -ForegroundColor Yellow
}
