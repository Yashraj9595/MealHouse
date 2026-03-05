@echo off
echo ========================================
echo 🚀 STARTING MEALHOUSE BACKEND SERVER
echo ========================================
echo.

cd /d "%~dp0backend"

echo 📦 Checking dependencies...
if not exist node_modules (
    echo Installing dependencies...
    npm install
)

echo.
echo 🔍 Starting MongoDB...
net start MongoDB >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ MongoDB started successfully
) else (
    echo ⚠️  MongoDB might already be running or not installed
    echo    Please install MongoDB from: https://www.mongodb.com/try/download/community
)

echo.
echo 🌱 Seeding database (if needed)...
npm run seed >nul 2>&1

echo.
echo 🚀 Starting backend server...
echo 📱 Local: http://localhost:5000/api
echo 📱 Network: http://10.87.156.74:5000/api
echo 📊 Health: http://10.87.156.74:5000/api/health
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

npm run dev
