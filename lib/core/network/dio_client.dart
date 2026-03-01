// ───────────────────────────────────────────────────────────────
// dio_client.dart  –  Dio HTTP client with interceptors
// Replaces: Java → MyApplication.java (Retrofit setup)
// ───────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:dream_ludo/core/config/env.dart';
import 'package:dream_ludo/core/services/storage_service.dart';
import 'package:dream_ludo/core/error/exceptions.dart';

class DioClient {
  late final Dio _dio;
  final StorageService _storage;
  final Logger _logger = Logger();

  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      _LoggingInterceptor(_logger),
      _ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  // ── Convenience Methods ─────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> postForm(
    String path, {
    required Map<String, dynamic> formData,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      return await _dio.post(
        path,
        data: FormData.fromMap(formData),
        queryParameters: queryParams,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return UnauthorizedException('Session expired. Please login again.');
        }
        if (statusCode == 404) {
          return NotFoundException('Resource not found.');
        }
        if (statusCode != null && statusCode >= 500) {
          return ServerException('Server error. Please try again later.');
        }
        return ServerException('Something went wrong (${statusCode}).');
      default:
        return UnknownException(e.message ?? 'Unknown error occurred.');
    }
  }
}

// ── Auth Interceptor: Attaches JWT token ────────────────────────

class _AuthInterceptor extends Interceptor {
  final StorageService _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired – clear and re-login
      await _storage.clearAll();
      // Navigation handled globally via GoRouter redirect
    }
    super.onError(err, handler);
  }
}

// ── Logging Interceptor ─────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  final Logger _logger;

  _LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('→ ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('← ${response.statusCode} ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('✗ ${err.requestOptions.path}: ${err.message}');
    super.onError(err, handler);
  }
}

// ── Error Interceptor ───────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
  }
}
