import 'package:MealHouse/core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(Map<String, dynamic> data);
  Future<UserModel> getMe();
  Future<UserModel> updateDetails(Map<String, dynamic> data);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final data = response.data;
      final token = data['token'];
      final user = data['user'];
      
      return UserModel.fromJson(user, token: token);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> register(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        '/auth/register',
        data: data,
      );
      
      final resData = response.data;
      final token = resData['token'];
      final user = resData['user'];
      
      return UserModel.fromJson(user, token: token);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await dioClient.get('/auth/me');
      // getMe returns { success: true, data: user }
      final user = response.data['data'];
      return UserModel.fromJson(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> updateDetails(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(
        '/auth/updatedetails',
        data: data,
      );
       // updateDetails returns { success: true, message: '...', data: user }
      final user = response.data['data'];
      return UserModel.fromJson(user);
    } catch (e) {
      rethrow;
    }
  }
}
