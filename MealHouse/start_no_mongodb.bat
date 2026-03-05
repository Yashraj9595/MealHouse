@echo off
echo ========================================
echo 🚀 STARTING BACKEND (NO MONGODB REQUIRED)
echo ========================================
echo.

cd /d "%~dp0backend"

echo 🛑 Stopping any existing Node.js processes...
taskkill /F /IM node.exe >nul 2>&1

echo 🚀 Starting memory-based server...
echo 📱 Local: http://localhost:5001/api
echo 📱 Network: http://10.87.156.74:5001/api
echo 📊 Health: http://10.87.156.74:5001/api/health
echo 💾 Using: In-Memory Database (No MongoDB required!)
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

node server-memory.js
