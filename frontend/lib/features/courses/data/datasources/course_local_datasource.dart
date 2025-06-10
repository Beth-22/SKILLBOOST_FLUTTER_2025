// abstract class CourseLocalDataSource {
//   Future<List<CourseModel>> getCachedCourses();
//   Future<void> cacheCourses(List<CourseModel> courses);
// }

// class CourseLocalDataSourceImpl implements CourseLocalDataSource {
//   final SharedPreferences sharedPreferences;
  
//   CourseLocalDataSourceImpl(this.sharedPreferences);
  
//   @override
//   Future<List<CourseModel>> getCachedCourses() async {
//     final jsonString = sharedPreferences.getString('CACHED_COURSES');
//     if (jsonString != null) {
//       final List<dynamic> jsonList = json.decode(jsonString);
//       return jsonList.map((json) => CourseModel.fromJson(json)).toList();
//     }
//     return [];
//   }

//   @override
//   Future<void> cacheCourses(List<CourseModel> courses) async {
//     final jsonList = courses.map((course) => course.toJson()).toList();
//     await sharedPreferences.setString('CACHED_COURSES', json.encode(jsonList));
//   }
// }