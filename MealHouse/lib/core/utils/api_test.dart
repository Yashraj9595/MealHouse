import 'package:dio/dio.dart';
import '../config/env_config.dart';

class ApiTest {
  static Future<void> testConnection() async {
    final dio = Dio();
    final baseUrl = Environment.config.baseUrl;
    
    print('🔍 Testing API connection...');
    print('📡 Base URL: $baseUrl');
    
    try {
      // Test health endpoint
      print('\n🏥 Testing health endpoint...');
      final healthResponse = await dio.get(
        '$baseUrl/health',
        options: Options(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      
      print('✅ Health check successful!');
      print('📊 Response: ${healthResponse.data}');
      
      // Test messes endpoint
      print('\n🍱 Testing messes endpoint...');
      final messesResponse = await dio.get(
        '$baseUrl/messes',
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final raw = messesResponse.data;
      int count = 0;

      if (raw is List) {
        count = raw.length;
      } else if (raw is Map<String, dynamic>) {
        final inner = raw['data'] ?? raw['messes'] ?? raw['items'];
        if (inner is List) {
          count = inner.length;
        } else if (inner != null) {
          count = 1;
        }
      }
      
      print('✅ Messes endpoint successful!');
      print('📊 Found $count messes');
      
      print('\n🎉 API connection is working perfectly!');
      print('📱 Your Flutter app should load real data now');
      
    } on DioException catch (e) {
      print('❌ API Connection Failed!');
      print('🔍 Error Type: ${e.type}');
      print('📝 Message: ${e.message}');
      
      if (e.type == DioExceptionType.connectionError) {
        print('\n🔧 SOLUTIONS:');
        print('1. Start the backend server: cd backend && npm run dev');
        print('2. Check if MongoDB is running: net start MongoDB');
        print('3. Verify the URL in lib/core/config/env_config.dart');
        print('4. Make sure server is running on port 5000');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        print('\n🔧 SOLUTIONS:');
        print('1. Server is taking too long to respond');
        print('2. Check if backend server is actually running');
        print('3. Try restarting the backend server');
      }
      
    } catch (e) {
      print('❌ Unexpected Error: $e');
    }
  }
  
  static void printConfiguration() {
    print('\n📋 Current Configuration:');
    print('🔗 Base URL: ${Environment.config.baseUrl}');
    print('🌍 Environment: ${Environment.config.environment}');
    print('🔑 API Key: ${Environment.config.apiKey}');
  }
}
