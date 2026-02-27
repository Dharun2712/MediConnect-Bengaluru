# Flutter Quick Start Script
# Run this after QUICKSTART_BACKEND.ps1 is running

Write-Host "📱 Flutter App - Quick Start" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

# Install Flutter dependencies
Write-Host "Step 1: Installing Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "Step 2: Google Maps API Key Required!" -ForegroundColor Red
Write-Host "----------------------------------------" -ForegroundColor Red
Write-Host "1. Get API key from: https://console.cloud.google.com/" -ForegroundColor Cyan
Write-Host "2. Enable 'Maps SDK for Android'" -ForegroundColor Cyan
Write-Host "3. Edit: android/app/src/main/AndroidManifest.xml" -ForegroundColor Cyan
Write-Host "4. Replace 'YOUR_GOOGLE_MAPS_API_KEY_HERE' with your actual key" -ForegroundColor Cyan
Write-Host ""

$response = Read-Host "Have you added the Google Maps API key? (y/n)"
if ($response -ne 'y') {
    Write-Host "Please add the API key first, then run this script again." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Step 3: Starting Flutter app..." -ForegroundColor Yellow
Write-Host "Make sure Android emulator is running!" -ForegroundColor Cyan
Write-Host ""

flutter run

Write-Host ""
Write-Host "📖 Login Credentials:" -ForegroundColor Green
Write-Host "  Client: client@example.com / Client123" -ForegroundColor Cyan
Write-Host "  Driver: drive123 / drive@123" -ForegroundColor Cyan
Write-Host "  Admin:  1 / 123" -ForegroundColor Cyan
