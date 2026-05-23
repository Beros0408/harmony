import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DioClient {
  DioClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000'),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _AuthInterceptor(),
    ]);
  }

  late final Dio _dio;

  Dio get instance => _dio;
}

class _LoggingInterceptor extends Interceptor {
  final _log = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.d('[HTTP] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.e('[HTTP] Erreur ${err.response?.statusCode}: ${err.message}');
    handler.next(err);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: injecter le JWT depuis SecureStorage au Sprint 1
    handler.next(options);
  }
}
