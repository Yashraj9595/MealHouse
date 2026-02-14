import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final Dio dio;

  UserProfileRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    try {
      final response = await dio.get('/api/auth/me');

      if (response.statusCode == 200) {
        // According to API_TESTING.md typical success response
        final data = response.data['data'] ?? response.data['user']; 
        return Right(UserProfileModel.fromJson(data));
      } else {
        return Left(ServerFailure(message: response.statusMessage ?? 'Failed to fetch profile'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserProfileEntity profile) async {
    try {
      final model = UserProfileModel(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        phoneNumber: profile.phoneNumber,
        address: profile.address,
      );

      final response = await dio.put(
        '/api/auth/updatedetails',
        data: model.toJson(),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: response.statusMessage ?? 'Failed to update profile'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
