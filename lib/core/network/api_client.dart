import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'api_error.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  factory ApiClient.create() {
    return ApiClient(createDio());
  }

  static Dio createDio() {
    final headers = <String, String>{'Accept': 'application/json'};
    final token = AppConfig.adminToken.trim();
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: headers,
      ),
    );

    if (!kIsWeb) {
      dio.options.sendTimeout = const Duration(seconds: 15);
    }

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    return dio;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.get<dynamic>(path, queryParameters: queryParameters),
    );
  }

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () =>
          _dio.put<dynamic>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      return _unwrapResponse(response.data);
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    } catch (error) {
      throw ApiError(
        type: ApiErrorType.unknown,
        message: 'Неожиданная ошибка: $error',
        details: error,
      );
    }
  }

  dynamic _unwrapResponse(dynamic raw) {
    final normalized = _normalizeDynamic(raw);

    if (normalized is Map<String, dynamic>) {
      final status = normalized['status'];
      if (status == 'success') {
        return normalized['data'];
      }
      if (status == 'error') {
        throw ApiError(
          type: ApiErrorType.badRequest,
          message:
              (normalized['message'] as String?) ?? 'Сервер вернул ошибку.',
          details: normalized,
        );
      }
    }

    return normalized;
  }

  dynamic _normalizeDynamic(dynamic raw) {
    if (raw is String) {
      final body = raw.trim();
      if (body.isEmpty) {
        return null;
      }
      try {
        return jsonDecode(body);
      } catch (_) {
        return body;
      }
    }
    return raw;
  }

  void dispose() {
    _dio.close(force: true);
  }
}
