import requests
import time

def test_backend_connection():
    """Test if backend server is running and accessible"""
    
    # Test URLs
    urls = [
        "http://localhost:5001/api/health",
        "http://10.87.156.74:5001/api/health"
    ]
    
    print("🔍 Testing backend connection...")
    
    for url in urls:
        try:
            print(f"\n📡 Testing: {url}")
            response = requests.get(url, timeout=5)
            
            if response.status_code == 200:
                print(f"✅ SUCCESS: Server is running!")
                print(f"📊 Response: {response.json()}")
                return True
            else:
                print(f"⚠️  WARNING: Status code {response.status_code}")
                
        except requests.exceptions.ConnectionError:
            print(f"❌ FAILED: Connection refused - Server not running")
        except requests.exceptions.Timeout:
            print(f"❌ FAILED: Request timeout")
        except Exception as e:
            print(f"❌ FAILED: {e}")
    
    print("\n🚨 BACKEND SERVER IS NOT RUNNING!")
    print("\n📋 To fix this:")
    print("1. Open a new terminal")
    print("2. Navigate to: cd backend")
    print("3. Start MongoDB: net start MongoDB")
    print("4. Start server: npm run dev")
    print("5. Wait for 'Server running on port 5000' message")
    
    return False

def test_messes_endpoint():
    """Test the messes endpoint specifically"""
    url = "http://10.87.156.74:5001/api/messes"
    
    print(f"\n🍱 Testing messes endpoint: {url}")
    
    try:
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Messes endpoint working!")
            print(f"📊 Found {len(data.get('data', []))} messes")
            return True
        else:
            print(f"⚠️  Status code: {response.status_code}")
            print(f"📊 Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")
    
    return False

if __name__ == "__main__":
    print("=" * 50)
    print("🔧 MEALHOUSE BACKEND CONNECTION TEST")
    print("=" * 50)
    
    # Test basic connection
    if test_backend_connection():
        # Test messes endpoint
        test_messes_endpoint()
        
        print("\n" + "=" * 50)
        print("🎉 BACKEND IS READY FOR FLUTTER APP!")
        print("📱 Your Flutter app should now connect successfully")
        print("=" * 50)
    else:
        print("\n" + "=" * 50)
        print("❌ PLEASE START THE BACKEND SERVER FIRST")
        print("=" * 50)
