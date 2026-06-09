part of 'init_dependencies.dart';

final serviceLocater = GetIt.instance;

Future<void> initDependencies() async {
  _authInit();
  _blogInit();
  _videoBlogInit();
  _commentInit();

  final supabase = await Supabase.initialize(
    url: AppSecrets.supaBaseUrl,
    anonKey: AppSecrets.supaBaseAnon,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  serviceLocater.registerLazySingleton(() => supabase.client);

  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.defaultDirectory = dir.path;
    serviceLocater.registerLazySingleton(() => Hive.box(name: 'Blogs'));
  }

  serviceLocater.registerLazySingleton(() => AppUserCubit());
  serviceLocater.registerLazySingleton(
    () => LogoutUserCubit(supabase: supabase),
  );
  serviceLocater.registerFactory<ConnectionCheker>(
    () => ConnectionCheckerImpl(),
  );
}

void _videoBlogInit() {
  serviceLocater
    ..registerFactory<VideoPostRemoteDataSource>(
      () => VideoPostRemoteDataSourceImpl(serviceLocater()),
    )
    ..registerFactory<VideoPostRepository>(
      () => VideoPostRepositoryImpl(serviceLocater()),
    )
    ..registerFactory(() => GetAllVideoPosts(serviceLocater()))
    ..registerFactory(() => CreateVideoPost(serviceLocater()))
    ..registerFactory(() => UpdateVideoPost(serviceLocater()))
    ..registerFactory(() => DeleteVideoPost(serviceLocater()))
    ..registerLazySingleton(
      () => VideoBlogBloc(
        getAllVideoPosts: serviceLocater(),
        createVideoPost: serviceLocater(),
        updateVideoPost: serviceLocater(),
        deleteVideoPost: serviceLocater(),
      ),
    );
}

void _blogInit() {
  serviceLocater.registerFactory<BlogLocalDataSource>(
    () => kIsWeb
        ? BlogLocalDataSourceWebImpl()
        : BlogLocaldatasourceImpl(box: serviceLocater()),
  );
  serviceLocater
    ..registerFactory<BlogRemotedatasource>(
      () => BlocRemotedatasoursceImpl(supabaseClient: serviceLocater()),
    )
    ..registerFactory<BlogRepositery>(
      () => BlogRepositeryimpl(
        blogRemotedatasource: serviceLocater(),
        connectionCheker: serviceLocater(),
        blogLocalDataSource: serviceLocater(),
      ),
    )
    ..registerFactory(() => UploadBlog(blogRepositery: serviceLocater()))
    ..registerFactory(() => GetAllBlogs(blogRepositery: serviceLocater()))
    ..registerLazySingleton(
      () => BlogBloc(uploadBlog: serviceLocater(), getAllBlog: serviceLocater()),
    );
}

void _commentInit() {
  serviceLocater
    ..registerFactory<CommentRemoteDataSource>(
      () => CommentRemoteDataSourceImpl(serviceLocater()),
    )
    ..registerFactory<CommentRepository>(
      () => CommentRepositoryImpl(serviceLocater()),
    )
    ..registerFactory(() => GetComments(serviceLocater()))
    ..registerFactory(() => AddComment(serviceLocater()));
}

void _authInit() {
  serviceLocater
    ..registerFactory<AuthRemoteDatasource>(
      () => AuthRemoteDataSourceImpl(serviceLocater()),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDatasource: serviceLocater(),
        connectionCheker: serviceLocater(),
      ),
    )
    ..registerFactory(() => UserSignup(serviceLocater()))
    ..registerFactory(() => UserLogin(serviceLocater()))
    ..registerFactory(() => CurrentUser(serviceLocater()))
    ..registerLazySingleton(
      () => AuthBloc(
        userSignup: serviceLocater(),
        userLogin: serviceLocater(),
        currentUser: serviceLocater(),
        appUserCubit: serviceLocater(),
      ),
    );
}
