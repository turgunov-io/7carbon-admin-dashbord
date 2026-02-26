import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_error.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  factory AuthRepository.create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: const <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    return AuthRepository(dio);
  }

  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/admin/auth/login',
        data: <String, String>{'username': username, 'password': password},
      );

      final token = _extractToken(response.data);
      if (token == null || token.isEmpty) {
        throw const ApiError(
          type: ApiErrorType.unknown,
          message:
              'РЎРµСЂРІРµСЂ РЅРµ РІРµСЂРЅСѓР» С‚РѕРєРµРЅ Р°РІС‚РѕСЂРёР·Р°С†РёРё.',
        );
      }

      return token;
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    } on ApiError {
      rethrow;
    } catch (error) {
      throw ApiError(
        type: ApiErrorType.unknown,
        message: 'РќРµ СѓРґР°Р»РѕСЃСЊ РІС‹РїРѕР»РЅРёС‚СЊ РІС…РѕРґ: $error',
        details: error,
      );
    }
  }

  void dispose() {
    _dio.close(force: true);
  }

  String? _extractToken(dynamic raw) {
    final normalized = _normalizeDynamic(raw);

    if (normalized is String) {
      final token = normalized.trim();
      return token.isEmpty ? null : token;
    }

    if (normalized is List) {
      for (final item in normalized) {
        final token = _extractToken(item);
        if (token != null && token.isNotEmpty) {
          return token;
        }
      }
      return null;
    }

    if (normalized is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(normalized);

    for (final key in const [
      'token',
      'access_token',
      'accessToken',
      'jwt',
      'bearer',
      'bearerToken',
    ]) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    for (final nestedKey in const ['data', 'result', 'payload', 'response']) {
      if (!map.containsKey(nestedKey)) {
        continue;
      }
      final token = _extractToken(map[nestedKey]);
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }

    return null;
  }

  dynamic _normalizeDynamic(dynamic raw) {
    if (raw is String) {
      final body = raw.trim();
      if (body.isEmpty) {
        return '';
      }
      try {
        return jsonDecode(body);
      } catch (_) {
        return body;
      }
    }
    return raw;
  }
}
