import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/exception.dart';
import 'package:skill_boost/core/errors/failure.dart';
import '../../domain/entities/search_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SearchEntity>>> searchCourses(String query) async {
    try {
      final result = await remoteDataSource.searchCourses(query);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure( e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
