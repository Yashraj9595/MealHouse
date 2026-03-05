# 🔧 Quick Fix Guide: Backend Connection Issues

## 🚨 Problem: Backend not connecting to Flutter app

### ✅ What I Fixed:
1. **Added network permissions** to AndroidManifest.xml
2. **Added HTTP support** with `usesCleartextTraffic="true"`
3. **Added missing import** for Environment class
4. **Created API test utility** for debugging

## 🚀 Quick Steps to Fix:

### Step 1: Start Backend Server
Double-click this file: `start_backend.bat`

Or run manually:
```bash
cd backend
npm run dev
```

You should see:
```
🚀 MealHouse API server running on port 5000
✅ Connected to MongoDB
```

### Step 2: Test Connection
```bash
python scripts/test_connection.py
```

Should show:
```
✅ SUCCESS: Server is running!
🎉 BACKEND IS READY FOR FLUTTER APP!
```

### Step 3: Run Flutter App
```bash
flutter run
```

### Step 4: Test API in App
1. Long press on any mess card
2. Select "Test API Connection" 
3. Check console logs for results

## 🔍 Debug Information:

### Current Configuration:
- **API URL**: `http://10.87.156.74:5000/api`
- **Your IP**: `10.87.156.74`
- **Port**: `5000`

### What to Check:
1. ✅ Backend server running on port 5000
2. ✅ MongoDB service started
3. ✅ Network permissions added
4. ✅ HTTP traffic allowed
5. ✅ Correct IP address configured

## 📱 Expected Results:

### ✅ Working:
- App shows real mess data from backend
- No "Offline mode" banner
- Console shows: `✅ Successfully loaded X messes`

### ❌ Not Working:
- App shows mock data only
- "Offline mode" banner appears
- Console shows: `Network error` or `Connection timeout`

## 🛠️ Troubleshooting:

### If backend won't start:
```bash
# Check MongoDB
net start MongoDB

# Install dependencies
cd backend
npm install

# Start server
npm run dev
```

### If app can't connect:
1. **Check IP address**: Run `python scripts/get_local_ip.py`
2. **Update URL**: Edit `lib/core/config/env_config.dart`
3. **Check firewall**: Allow port 5000
4. **Test manually**: Open `http://10.87.156.74:5000/api/health` in browser

### If connection times out:
1. Restart backend server
2. Check internet connection on phone
3. Make sure phone and laptop are on same network

## 📋 Commands to Run:

```bash
# 1. Start MongoDB
net start MongoDB

# 2. Start backend
cd backend
npm run dev

# 3. Test connection
python scripts/test_connection.py

# 4. Run Flutter app
flutter run
```

## 🎯 Success Indicators:

### Backend Server:
```
🚀 MealHouse API server running on port 5000
✅ Connected to MongoDB
📱 Network: http://10.87.156.74:5000
```

### Python Test:
```
✅ SUCCESS: Server is running!
🎉 BACKEND IS READY FOR FLUTTER APP!
```

### Flutter App:
```
🔍 Loading messes from: http://10.87.156.74:5000/api/messes
✅ Successfully loaded 6 messes
```

## 🔄 If Still Not Working:

1. **Restart everything**:
   - Stop backend (Ctrl+C)
   - Restart MongoDB
   - Start backend again
   - Re-run Flutter app

2. **Check IP address**:
   ```bash
   python scripts/get_local_ip.py
   ```
   Update the IP in `lib/core/config/env_config.dart`

3. **Manual browser test**:
   Open `http://10.87.156.74:5000/api/messes` in browser

4. **Check logs**: Run Flutter app with verbose logging
   ```bash
   flutter run --verbose
   ```

## 📞 Quick Test:
1. Start backend: `start_backend.bat`
2. Run this: `python scripts/test_connection.py`
3. If success, run: `flutter run`
4. App should show real data!
