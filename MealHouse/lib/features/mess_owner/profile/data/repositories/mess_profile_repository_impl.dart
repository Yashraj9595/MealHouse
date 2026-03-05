import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/mess_profile_entity.dart';
import '../../domain/repositories/mess_profile_repository.dart';
import '../models/mess_profile_model.dart';

class MessProfileRepositoryImpl implements MessProfileRepository {
  final Dio dio;

  MessProfileRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, MessProfileEntity>> getMessProfile() async {
    try {
      final response = await dio.get('/messes/my/mess');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Right(MessProfileModel.fromJson(data));
      } else {
        return Left(ServerFailure(message: response.statusMessage ?? 'Failed to fetch profile'));
      }
    } catch (e) {
       // Check for 404 which means no mess created yet
      if (e is DioException && e.response?.statusCode == 404) {
          return Left(ServerFailure(message: 'No mess found. Please create one.'));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMessProfile(MessProfileEntity profile) async {
    try {
      // Logic to handle conversion back to API format would go here or in model
      // For now using partial update logic based on model's toJson
      final model = MessProfileModel(
          id: profile.id,
          messName: profile.messName,
          address: profile.address,
          phoneNumber: profile.phoneNumber,
          description: profile.description,
          images: profile.images,
          operatingHours: profile.operatingHours,
          isVegOnly: profile.isVegOnly
      );
      
      final response = await dio.put(
        '/messes/${profile.id}',
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
