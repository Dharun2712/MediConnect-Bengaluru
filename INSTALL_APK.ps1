# Smart-Aid APK Installation Script
# Quick install to connected Android device

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Smart-Aid APK Installer" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$apkPath = "build\app\outputs\flutter-apk\app-release.apk"

# Check if APK exists
if (-not (Test-Path $apkPath)) {
    Write-Host "APK not found at: $apkPath" -ForegroundColor Red
    Write-Host "Please build the APK first with: flutter build apk" -ForegroundColor Yellow
    exit 1
}

# Get APK info
$apkInfo = Get-Item $apkPath
$sizeMB = [math]::Round($apkInfo.Length / 1MB, 1)
Write-Host "APK Found:" -ForegroundColor Green
Write-Host "  File: $($apkInfo.Name)"
Write-Host "  Size: $sizeMB MB"
Write-Host "  Date: $($apkInfo.LastWriteTime)"
Write-Host ""

# Check if adb is available
$adbPath = (Get-Command adb -ErrorAction SilentlyContinue).Source
if (-not $adbPath) {
    Write-Host "ADB not found in PATH" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "1. Install Android SDK Platform Tools"
    Write-Host "2. Or manually transfer APK to phone and install"
    Write-Host ""
    Write-Host "Manual installation:" -ForegroundColor Yellow
    Write-Host "1. Copy $apkPath to your phone"
    Write-Host "2. Open the file on your phone"
    Write-Host "3. Allow installation from unknown sources if prompted"
    Write-Host "4. Install the app"
    exit 0
}

Write-Host "ADB found: $adbPath" -ForegroundColor Green
Write-Host ""

# Check for connected devices
Write-Host "Checking for connected devices..." -ForegroundColor Yellow
$devices = adb devices | Select-String "device$" | Where-Object { $_ -notmatch "List of devices" }

if (-not $devices) {
    Write-Host "No devices connected" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Connect your Android phone via USB"
    Write-Host "2. Enable USB Debugging in Developer Options"
    Write-Host "3. Authorize the computer when prompted on phone"
    Write-Host "4. Run this script again"
    exit 1
}

Write-Host "Connected devices:" -ForegroundColor Green
adb devices
Write-Host ""

# Install APK
Write-Host "Installing APK..." -ForegroundColor Yellow
Write-Host ""

try {
    $result = adb install -r $apkPath 2>&1
    
    if ($result -match "Success") {
        Write-Host "=====================================" -ForegroundColor Green
        Write-Host "Installation Successful!" -ForegroundColor Green
        Write-Host "=====================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "The app has been installed on your phone." -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "1. Start backend: cd backend ; python -m uvicorn app_fastapi:app --host 0.0.0.0 --port 8000"
        Write-Host "2. Launch the app on your phone"
        Write-Host "3. App will auto-discover backend - no more rebuilds needed!"
        Write-Host ""
    }
    else {
        Write-Host "Installation may have encountered issues:" -ForegroundColor Yellow
        Write-Host $result
        Write-Host ""
        Write-Host "If installation failed, try:" -ForegroundColor Yellow
        Write-Host "1. Uninstall old version from phone"
        Write-Host "2. Run this script again"
        Write-Host "3. Or install manually by transferring APK to phone"
    }
}
catch {
    Write-Host "Error during installation: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
