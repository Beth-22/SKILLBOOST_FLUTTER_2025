abstract class SearchEvent {}

class SearchCoursesEvent extends SearchEvent {
  final String query;
  SearchCoursesEvent(this.query);
}

class ClearSearchEvent extends SearchEvent {}
