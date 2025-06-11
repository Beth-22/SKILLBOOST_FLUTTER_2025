import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_boost/features/search/domain/usecases/search_usecase.dart';
import 'package:skill_boost/features/search/presentation/providers/search_event.dart';
import 'package:skill_boost/features/search/presentation/providers/search_state.dart';
import 'package:skill_boost/injection_container.dart';

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(
    searchUseCase: ref.read(searchUseCaseProvider),
  );
});

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchUseCase searchUseCase;

  SearchNotifier({
    required this.searchUseCase,
  }) : super(SearchState.initial());

  Future<void> mapEventToState(SearchEvent event) async {
    if (event is SearchCoursesEvent) {
      state = SearchState.loading();
      try {
        final result = await searchUseCase(event.query);
        result.fold(
          (failure) => state = SearchState.error(failure.message),
          (results) => state = SearchState.loaded(results),
        );
      } catch (e) {
        state = SearchState.error('Failed to search courses: $e');
      }
    }

    if (event is ClearSearchEvent) {
      state = SearchState.initial();
    }
  }
}
