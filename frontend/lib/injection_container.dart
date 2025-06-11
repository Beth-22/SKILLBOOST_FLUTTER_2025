import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_boost/features/auth/domain/usecases/edit_user_profile_usecase.dart';
import 'package:skill_boost/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:skill_boost/features/auth/domain/usecases/logout_usecase.dart';
import 'package:skill_boost/features/auth/domain/usecases/select_role_usecase.dart';
import 'package:skill_boost/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:skill_boost/features/courses/data/repositories/course_repository_impl.dart';
import 'package:skill_boost/features/courses/domain/repositories/course_repository.dart';
import 'package:skill_boost/features/courses/domain/usecases/create_course_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/delete_course_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/enroll_course_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/get_course_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/get_enrolled_courses_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/update_course_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/upload_image_usecase.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/delete_account_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/search/data/datasources/search_remote_datasource.dart';
import 'features/search/data/repositories/search_repository_impl.dart';
import 'features/search/domain/repositories/search_repository.dart';
import 'features/search/domain/usecases/search_usecase.dart';
import 'package:http/http.dart' as http;

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences first');
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
      (ref) => AuthRemoteDatasourceImpl(),
);

final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => AuthRepositoryImpl(
    ref.read(authRemoteDatasourceProvider),
    ref.read(sharedPreferencesProvider),
  ),
);

final signupUsecaseProvider = Provider<SignupUsecase>(
      (ref) => SignupUsecase(ref.read(authRepositoryProvider)),
);

final selectRoleUsecaseProvider = Provider<SelectRoleUsecase>(
      (ref) => SelectRoleUsecase(ref.read(authRepositoryProvider)),
);

final loginUsecaseProvider = Provider<LoginUsecase>(
      (ref) => LoginUsecase(ref.read(authRepositoryProvider)),
);

final logoutUsecaseProvider = Provider<LogoutUsecase>(
      (ref) => LogoutUsecase(ref.read(authRepositoryProvider)),
);

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>(
      (ref) => GetCurrentUserUsecase(ref.read(authRepositoryProvider)),
);

final editUserProfileUsecaseProvider = Provider<EditUserProfileUsecase>(
      (ref) => EditUserProfileUsecase(ref.read(authRepositoryProvider)),
);

final courseRemoteDatasourceProvider = Provider<CourseRemoteDataSource>(
      (ref) => CourseRemoteDataSourceImpl(),
);

final courseRepositoryProvider = Provider<CourseRepository>(
      (ref) => CourseRepositoryImpl(
    ref.read(courseRemoteDatasourceProvider),
  ),
);

final getCoursesUsecaseProvider = Provider<GetCoursesUseCase>(
      (ref) => GetCoursesUseCase(ref.read(courseRepositoryProvider)),
);

final createCourseUsecaseProvider = Provider<CreateCourseUseCase>(
        (ref)=> CreateCourseUseCase(ref.read(courseRepositoryProvider)));

final updateCourseUsecaseProvider = Provider<UpdateCourseUseCase>(
        (ref)=> UpdateCourseUseCase(ref.read(courseRepositoryProvider)));

final deleteCourseUsecaseProvider = Provider<DeleteCourseUseCase>(
        (ref)=> DeleteCourseUseCase(ref.read(courseRepositoryProvider)));

final uploadImageUsecaseProvider = Provider<UploadImageUseCase>(
        (ref)=> UploadImageUseCase(ref.read(courseRepositoryProvider)));

final getCourseUsecaseProvider = Provider<GetCourseUseCase>(
        (ref)=> GetCourseUseCase(ref.read(courseRepositoryProvider)));

final getEnrolledCoursesUsecaseProvider = Provider<GetEnrolledCoursesUseCase>(
      (ref) => GetEnrolledCoursesUseCase(ref.read(courseRepositoryProvider)),
);

final enrollCourseUsecaseProvider = Provider<EnrollCourseUseCase>(
      (ref) => EnrollCourseUseCase(ref.read(courseRepositoryProvider)),
);

final searchRemoteDatasourceProvider = Provider<SearchRemoteDataSource>(
      (ref) => SearchRemoteDataSourceImpl(
    client: http.Client(),
  ),
);

final searchRepositoryProvider = Provider<SearchRepository>(
      (ref) => SearchRepositoryImpl(
    remoteDataSource: ref.read(searchRemoteDatasourceProvider),
  ),
);

final searchUseCaseProvider = Provider<SearchUseCase>(
      (ref) => SearchUseCase(ref.read(searchRepositoryProvider)),
);

final deleteAccountUsecaseProvider = Provider<DeleteAccountUsecase>((ref) {
  return DeleteAccountUsecase(ref.read(authRepositoryProvider));
});