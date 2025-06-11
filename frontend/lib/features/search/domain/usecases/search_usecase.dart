import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import '../entities/search_entity.dart';
import '../repositories/search_repository.dart';

class SearchUseCase {
  final SearchRepository repository;

  SearchUseCase(this.repository);

  @override
  Future<Either<Failure, List<SearchEntity>>> call(String query) async {
    return await repository.searchCourses(query);
  }
}


