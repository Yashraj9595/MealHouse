import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      
      // Save token to secure storage
      if (user.token != null) {
        await storageService.saveToken(user.token!);
        await storageService.saveUserId(user.id);
      }
      
      return Right(user);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message'] ?? 'Login failed',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(Map<String, dynamic> data) async {
    try {
      final user = await remoteDataSource.register(data);
      
      // Save token to secure storage
      if (user.token != null) {
        await storageService.saveToken(user.token!);
        await storageService.saveUserId(user.id);
      }
      
      return Right(user);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message'] ?? 'Registration failed',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getMe() async {
    try {
      final user = await remoteDataSource.getMe();
      return Right(user);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message'] ?? 'Failed to fetch user',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateDetails(Map<String, dynamic> data) async {
    try {
      final user = await remoteDataSource.updateDetails(data);
      return Right(user);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message'] ?? 'Failed to update profile',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear token from secure storage
      await storageService.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

