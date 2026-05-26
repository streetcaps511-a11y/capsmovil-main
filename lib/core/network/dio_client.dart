import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class DioClient {
  late Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );

    // ✅ SIN LOGS: No se agrega ningún interceptor de registro
    // Si en el futuro necesitas depurar, descomenta y ajusta el LogInterceptor
    /*
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      requestHeader: false,
      responseHeader: false,
      error: false,
      logPrint: (Object? object) {}, // Silencia completamente
    ));
    */
  }

  // Getter para acceder a la instancia de Dio
  Dio get dio => _dio;
}