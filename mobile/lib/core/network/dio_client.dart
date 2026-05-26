import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../security/token_storage.dart';

typedef OnSessionExpired = void Function();

class DioClient {
  DioClient({
    String? baseUrl,
    ITokenStorage? tokenStorage,
    OnSessionExpired? onSessionExpired,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://localhost:8000',
            ),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _AuthInterceptor(
        tokenStorage: tokenStorage ?? SecureTokenStorage(),
        onSessionExpired: onSessionExpired,
        dio: _dio,
      ),
    ]);
  }

  late final Dio _dio;

  Dio get instance => _dio;
}

// ─── Logging ────────────────────────────────────────────────────────────────

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

// ─── Auth interceptor ────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({
    required this.tokenStorage,
    required this.dio,
    this.onSessionExpired,
  });

  final ITokenStorage tokenStorage;
  final Dio dio;
  final OnSessionExpired? onSessionExpired;

  // Verrou pour éviter plusieurs refreshes simultanés
  bool _isRefreshing = false;
  final List<_PendingRequest> _queue = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Éviter une boucle infinie sur l'endpoint de refresh lui-même
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await _expireSession();
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      // Mettre la requête en file d'attente
      _queue.add(_PendingRequest(options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    final refreshed = await _tryRefresh();
    _isRefreshing = false;

    if (!refreshed) {
      // Vider la file et rejeter toutes les requêtes en attente
      for (final pending in _queue) {
        pending.handler.next(
          DioException(
            requestOptions: pending.options,
            response: err.response,
            type: DioExceptionType.badResponse,
          ),
        );
      }
      _queue.clear();
      await _expireSession();
      handler.next(err);
      return;
    }

    // Rejouer les requêtes en file avec le nouveau token
    final newToken = await tokenStorage.getAccessToken();
    for (final pending in _queue) {
      pending.options.headers['Authorization'] = 'Bearer $newToken';
      try {
        final response = await dio.fetch(pending.options);
        pending.handler.resolve(response);
      } catch (e) {
        pending.handler.next(
          DioException(requestOptions: pending.options, error: e),
        );
      }
    }
    _queue.clear();

    // Rejouer la requête originale
    final retryOptions = err.requestOptions
      ..headers['Authorization'] = 'Bearer $newToken';
    try {
      final response = await dio.fetch(retryOptions);
      handler.resolve(response);
    } catch (e) {
      handler.next(DioException(requestOptions: err.requestOptions, error: e));
    }
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;
    try {
      // Appel sans intercepteur pour éviter la boucle infinie
      final response = await Dio().post(
        '${dio.options.baseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final newAccess = response.data['access_token'] as String?;
      final newRefresh = response.data['refresh_token'] as String?;
      if (newAccess == null) return false;
      await tokenStorage.saveAccessToken(newAccess);
      if (newRefresh != null) await tokenStorage.saveRefreshToken(newRefresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _expireSession() async {
    await tokenStorage.clearAll();
    onSessionExpired?.call();
  }
}

class _PendingRequest {
  const _PendingRequest({required this.options, required this.handler});
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
}
