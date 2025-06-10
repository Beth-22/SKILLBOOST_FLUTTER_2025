import 'package:skill_boost/features/search/domain/entities/search_entity.dart';

class SearchState {
  final bool isLoading;
  final List<SearchEntity>? searchResults;
  final String? error;

  SearchState({
    this.isLoading = false,
    this.searchResults,
    this.error,
  });

  // Factory constructors for different states
  factory SearchState.initial() => SearchState();
  
  factory SearchState.loading() => SearchState(isLoading: true);
  
  factory SearchState.loaded(List<SearchEntity> results) => 
    SearchState(searchResults: results);
  
  factory SearchState.error(String message) => 
    SearchState(error: message);
}
