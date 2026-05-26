import 'package:get_it/get_it.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/category_remote_data_source.dart';
import 'data/datasources/product_remote_data_source.dart';
import 'data/repositories/category_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/category_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/usecases/get_categories.dart';
import 'domain/usecases/get_products.dart';
import 'presentation/blocs/category_bloc.dart';
import 'presentation/blocs/product_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Red
  sl.registerLazySingleton(() => DioClient());

  // Capas de datos (Data sources)
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  // Repositorios
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // Casos de uso
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetProducts(sl()));

  // Blocs (Gestores de estado)
  sl.registerFactory(() => CategoryBloc(getCategories: sl()));
  sl.registerFactory(() => ProductBloc(getProducts: sl()));
}
