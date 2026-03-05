@echo off
echo ========================================
echo 🚀 STARTING MEALHOUSE BACKEND (NO MONGODB)
echo ========================================
echo.

cd /d "%~dp0backend"

echo 🚀 Starting backend server with in-memory database...
echo 📱 Local: http://localhost:5000/api
echo 📱 Network: http://10.87.156.74:5000/api
echo 📊 Health: http://10.87.156.74:5000/api/health
echo 💾 Using: In-Memory Database (No MongoDB required)
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

node server-memory.js
