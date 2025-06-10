import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import '../entities/search_entity.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<SearchEntity>>> searchCourses(String query);
}
