import 'package:dio/dio.dart';

enum ApiErrorType {
  network,
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  unknown,
}

class ApiError implements Exception {
  const ApiError({
    required this.type,
    required this.message,
    this.statusCode,
    this.details,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final Object? details;

  factory ApiError.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    final responseMessage = _extractMessage(responseData);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(
          type: ApiErrorType.timeout,
          message: 'Превышено время ожидания запроса.',
        );
      case DioExceptionType.connectionError:
        return const ApiError(
          type: ApiErrorType.network,
          message: 'Ошибка сети. Проверьте подключение к интернету.',
        );
      case DioExceptionType.badResponse:
        return _fromStatusCode(
          statusCode: statusCode,
          message: responseMessage,
          details: responseData,
        );
      case DioExceptionType.cancel:
        return const ApiError(
          type: ApiErrorType.unknown,
          message: 'Запрос был отменен.',
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiError(
          type: ApiErrorType.unknown,
          message: responseMessage ?? error.message ?? 'Неизвестная ошибка.',
          statusCode: statusCode,
          details: responseData ?? error.error,
        );
    }
  }

  static ApiError _fromStatusCode({
    required int? statusCode,
    required String? message,
    required Object? details,
  }) {
    final normalizedMessage = message ?? _defaultMessage(statusCode);
    switch (statusCode) {
      case 400:
        return ApiError(
          type: ApiErrorType.badRequest,
          message: normalizedMessage,
          statusCode: statusCode,
          details: details,
        );
      case 401:
        return ApiError(
          type: ApiErrorType.unauthorized,
          message: normalizedMessage,
          statusCode: statusCode,
          details: details,
        );
      case 403:
        return ApiError(
          type: ApiErrorType.forbidden,
          message: normalizedMessage,
          statusCode: statusCode,
          details: details,
        );
      case 404:
        return ApiError(
          type: ApiErrorType.notFound,
          message: normalizedMessage,
          statusCode: statusCode,
          details: details,
        );
      case 422:
        return ApiError(
          type: ApiErrorType.validation,
          message: normalizedMessage,
          statusCode: statusCode,
          details: details,
        );
      default:
        if ((statusCode ?? 0) >= 500) {
          return ApiError(
            type: ApiErrorType.server,
            message: normalizedMessage,
            statusCode: statusCode,
            details: details,
          );
        }
        return ApiError(
          type: ApiErrorType.unknown,
          message: normalizedMessage,
          statusCode: statusCode,
          details: details,
        );
    }
  }

  static String _defaultMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Неверный запрос.';
      case 401:
        return 'Необходима авторизация.';
      case 403:
        return 'Доступ запрещен.';
      case 404:
        return 'Запись не найдена.';
      case 422:
        return 'Ошибка валидации данных.';
      default:
        if ((statusCode ?? 0) >= 500) {
          return 'Ошибка сервера.';
        }
        return 'Неизвестная ошибка запроса.';
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final errors = data['errors'];
      if (errors is Map<String, dynamic> && errors.isNotEmpty) {
        final buffer = <String>[];
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List) {
            final joined = value.map((e) => e.toString()).join(', ');
            if (joined.isNotEmpty) {
              buffer.add('${entry.key}: $joined');
            }
          } else if (value != null) {
            buffer.add('${entry.key}: $value');
          }
        }
        if (buffer.isNotEmpty) {
          return buffer.join(' | ');
        }
      }
    }
    return null;
  }

  @override
  String toString() {
    final codePart = statusCode == null ? '' : ' (HTTP $statusCode)';
    return '$message$codePart';
  }
}
