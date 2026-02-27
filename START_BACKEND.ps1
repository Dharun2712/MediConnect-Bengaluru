# START BACKEND SERVER
# Run this script to start the Flask backend

Write-Host "🚀 Starting Smart Ambulance Backend Server..." -ForegroundColor Green
Write-Host ""

# Navigate to backend directory
Set-Location -Path "d:\projects\sdg\sdg\backend"

# Start the Flask server
Write-Host "✅ Backend will run on http://localhost:5000" -ForegroundColor Cyan
Write-Host "✅ Press CTRL+C to stop the server" -ForegroundColor Cyan
Write-Host ""

python app.py
