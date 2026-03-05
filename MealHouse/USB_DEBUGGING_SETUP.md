# USB Debugging Setup Guide

## 🔧 Backend Connection for Physical Device

Your app is now configured to connect to your laptop's backend server when using a physical device via USB.

## Current Configuration:
- **Laptop IP**: `10.87.156.74`
- **API URL**: `http://10.87.156.74:5000/api`
- **Device**: Physical Android device via USB

## 📋 Setup Steps:

### 1. Start Your Backend Server
Make sure your backend server is running on port 5000:
```bash
# If using Node.js
npm run dev

# If using Python
python app.py

# Or whatever command starts your backend
```

### 2. Verify Backend is Accessible
Open your browser and test:
```
http://10.87.156.74:5000/api/messes
```
You should see JSON data or an API response.

### 3. Enable USB Debugging on Phone
1. Go to Settings → About Phone
2. Tap "Build Number" 7 times to enable Developer Options
3. Go to Settings → Developer Options
4. Enable "USB Debugging"
5. Connect phone to laptop via USB
6. Allow debugging when prompted

### 4. Run Flutter App
```bash
flutter run
```

### 5. Test Connection
- Open the app on your phone
- Check if backend data loads
- Look for "Offline mode" banner (means connection failed)
- Check logs for connection errors

## 🔍 Troubleshooting:

### If data doesn't load:

#### 1. Check Backend Server
```bash
# Test if server is running
curl http://10.87.156.74:5000/api/messes
```

#### 2. Check Firewall
- Windows Defender might block the connection
- Add port 5000 to firewall exceptions
- Or temporarily disable firewall for testing

#### 3. Check Network Connection
```bash
# Ping your phone from laptop
adb shell ping 10.87.156.74

# Check if phone can reach laptop
adb shell curl http://10.87.156.74:5000/api/messes
```

#### 4. Update IP Address
If your IP changes, update it in:
`lib/core/config/env_config.dart` line 33

Or run the script again:
```bash
python scripts/get_local_ip.py
```

#### 5. Check ADB Connection
```bash
# Check if device is connected
adb devices

# Restart ADB if needed
adb kill-server
adb start-server
```

## 📱 Expected Behavior:

### ✅ Working:
- App loads real data from backend
- No "Offline mode" banner
- Mess list shows actual backend data
- Mess details work correctly

### ❌ Not Working:
- "Offline mode" banner appears
- Only mock data is shown
- Network timeout errors in logs
- Error messages about connection failed

## 🔄 Switching Between Emulator and Physical Device:

### For Android Emulator:
```dart
// In lib/core/config/env_config.dart
baseUrl = 'http://10.0.2.2:5000/api'; // Uncomment this line
// baseUrl = 'http://10.87.156.74:5000/api'; // Comment this line
```

### For Physical Device:
```dart
// In lib/core/config/env_config.dart
// baseUrl = 'http://10.0.2.2:5000/api'; // Comment this line
baseUrl = 'http://10.87.156.74:5000/api'; // Uncomment this line
```

## 🚀 Quick Test:
1. Start backend server
2. Connect phone via USB
3. Run `flutter run`
4. Check if real data loads

If you still see issues, check the Flutter logs for detailed error messages.
