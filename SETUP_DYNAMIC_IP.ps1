# Quick Setup Script for Dynamic IP Solution
# Run this script to configure your .env file automatically

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Smart-Aid Dynamic IP Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Get computer hostname
$hostname = hostname
Write-Host "Detected hostname: $hostname" -ForegroundColor Green

# Get current IP address
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi*" -ErrorAction SilentlyContinue | Select-Object -First 1).IPAddress
if (-not $ipAddress) {
    $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*"} | Select-Object -First 1).IPAddress
}
Write-Host "Detected local IP: $ipAddress" -ForegroundColor Green
Write-Host ""

# Update .env file
$envPath = ".env"
$backendUrl = "http://${ipAddress}:8000"
$backendHostname = "${hostname}.local"
$backendPort = "8000"

Write-Host "Updating .env file with:" -ForegroundColor Yellow
Write-Host "  BACKEND_URL=$backendUrl"
Write-Host "  BACKEND_HOSTNAME=$backendHostname"
Write-Host "  BACKEND_PORT=$backendPort"
Write-Host ""

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$envContent = @"
# Backend Configuration
# This file provides fallback defaults for local development
# The app will auto-discover your backend and cache the working URL

# Default backend URL (current IP: $ipAddress)
BACKEND_URL=$backendUrl

# Backend hostname (use .local for mDNS resolution - more reliable than IP)
BACKEND_HOSTNAME=$backendHostname

# Backend port
BACKEND_PORT=$backendPort

# Note: After first successful connection, the app caches the backend URL
# You will not need to rebuild the APK when your IP changes
# Last updated: $timestamp
"@

Set-Content -Path $envPath -Value $envContent

Write-Host ".env file updated successfully!" -ForegroundColor Green
Write-Host ""

# Check if Bonjour is installed
Write-Host "Checking for Bonjour service..." -ForegroundColor Yellow
$bonjourService = Get-Service -ErrorAction SilentlyContinue | Where-Object {$_.Name -like "*Bonjour*"}
if ($bonjourService) {
    $serviceName = $bonjourService.Name
    $serviceStatus = $bonjourService.Status
    Write-Host "Bonjour service found: $serviceName - Status: $serviceStatus" -ForegroundColor Green
    Write-Host "Your .local hostname should work!" -ForegroundColor Green
}
else {
    Write-Host "Bonjour service not found" -ForegroundColor Red
    Write-Host "Install Bonjour for .local hostname support:" -ForegroundColor Yellow
    Write-Host "Download: https://support.apple.com/kb/DL999" -ForegroundColor Yellow
}
Write-Host ""

# Check if backend is running
Write-Host "Testing backend connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$backendUrl/health" -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
    $statusCode = $response.StatusCode
    Write-Host "Backend is running and accessible!" -ForegroundColor Green
    Write-Host "Health check response: $statusCode" -ForegroundColor Green
}
catch {
    Write-Host "Backend is not accessible at $backendUrl" -ForegroundColor Red
    Write-Host "Make sure to start the backend with:" -ForegroundColor Yellow
    Write-Host "cd backend ; python -m uvicorn app_fastapi:app --host 0.0.0.0 --port 8000" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Start backend: cd backend ; python -m uvicorn app_fastapi:app --host 0.0.0.0 --port 8000"
Write-Host "2. Build APK: flutter build apk"
Write-Host "3. Install on phone - this is the LAST rebuild you will need!"
Write-Host ""
Write-Host "For more info, see DYNAMIC_IP_SOLUTION.md" -ForegroundColor Cyan
Write-Host ""
