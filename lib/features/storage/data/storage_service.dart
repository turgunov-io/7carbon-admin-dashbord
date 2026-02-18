import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_error.dart';
import '../models/storage_file_item.dart';
import '../models/storage_file_list_result.dart';
import '../models/storage_upload_result.dart';

class StorageService {
  StorageService(this._dio);

  final Dio _dio;
  static const _publicObjectMarker = '/storage/v1/object/public/';
  String? _cachedPublicBaseUrl;
  bool _publicBaseUrlProbeDone = false;

  Future<StorageUploadResult> uploadFile({
    required PlatformFile file,
    String? bucket,
    String? folder,
    String? filename,
    bool upsert = true,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final multipart = await _toMultipartFile(file, filename: filename);
      final formData = FormData.fromMap({
        'file': multipart,
        if (bucket != null && bucket.trim().isNotEmpty) 'bucket': bucket.trim(),
        if (folder != null && folder.trim().isNotEmpty) 'folder': folder.trim(),
        if (filename != null && filename.trim().isNotEmpty)
          'filename': filename.trim(),
        'upsert': upsert.toString(),
      });

      final response = await _dio.post<dynamic>(
        '/admin/storage/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
      );
      final envelope = _asMap(response.data);
      final data = _unwrapSuccessData(envelope);
      return StorageUploadResult.fromJson(_asMap(data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    } on ApiError {
      rethrow;
    } catch (error) {
      throw ApiError(
        type: ApiErrorType.unknown,
        message: 'Не удалось загрузить файл: $error',
        details: error,
      );
    }
  }

  Future<StorageFileListResult> listFiles({
    String? bucket,
    String? prefix,
    bool allBuckets = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'limit': limit};

      if (allBuckets) {
        queryParameters['all'] = 'true';
        if (prefix != null && prefix.trim().isNotEmpty) {
          queryParameters['prefix'] = prefix.trim();
        }
      } else {
        if (bucket != null && bucket.trim().isNotEmpty) {
          queryParameters['bucket'] = bucket.trim();
        }
        if (prefix != null && prefix.trim().isNotEmpty) {
          queryParameters['prefix'] = prefix.trim();
        }
        queryParameters['offset'] = offset;
      }

      final response = await _dio.get<dynamic>(
        '/admin/storage/files',
        queryParameters: queryParameters,
      );
      final envelope = _asMap(response.data);
      final data = _unwrapSuccessData(envelope);
      final meta = _asMap(envelope['meta']);
      final metaPublicBaseUrl = _firstString(meta, const [
        'public_base_url',
        'publicBaseUrl',
        'storage_public_base_url',
        'storagePublicBaseUrl',
      ]);
      final publicBaseUrl = metaPublicBaseUrl ?? _cachedPublicBaseUrl;
      var files = _extractFiles(
        data,
        prefix: prefix,
        publicBaseUrl: publicBaseUrl,
      );
      if (_needsPublicUrlGeneration(files) && publicBaseUrl == null) {
        if (!_publicBaseUrlProbeDone) {
          _publicBaseUrlProbeDone = true;
          final guessedBaseUrl = await _guessPublicBaseUrl();
          if (guessedBaseUrl != null) {
            _cachedPublicBaseUrl = guessedBaseUrl;
            files = _extractFiles(
              data,
              prefix: prefix,
              publicBaseUrl: guessedBaseUrl,
            );
          }
        }
      } else if (metaPublicBaseUrl != null) {
        _cachedPublicBaseUrl = metaPublicBaseUrl;
        _publicBaseUrlProbeDone = true;
      }
      return StorageFileListResult(files: files, meta: meta);
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    } on ApiError {
      rethrow;
    } catch (error) {
      throw ApiError(
        type: ApiErrorType.unknown,
        message: 'Не удалось получить список файлов: $error',
        details: error,
      );
    }
  }

  Future<void> deleteFile({String? bucket, required String path}) async {
    try {
      final response = await _dio.delete<dynamic>(
        '/admin/storage/file',
        queryParameters: {
          if (bucket != null && bucket.trim().isNotEmpty)
            'bucket': bucket.trim(),
          'path': path,
        },
      );
      final envelope = _asMap(response.data);
      _unwrapSuccessData(envelope);
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    } on ApiError {
      rethrow;
    } catch (error) {
      throw ApiError(
        type: ApiErrorType.unknown,
        message: 'Не удалось удалить файл: $error',
        details: error,
      );
    }
  }

  dynamic _unwrapSuccessData(Map<String, dynamic> envelope) {
    final status = envelope['status'];
    if (status == 'success') {
      return envelope['data'];
    }

    final message = envelope['message'];
    if (message is String && message.trim().isNotEmpty) {
      throw ApiError(type: ApiErrorType.badRequest, message: message);
    }

    throw const ApiError(
      type: ApiErrorType.unknown,
      message: 'Сервер вернул некорректный ответ.',
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List<dynamic>) {
      return value;
    }
    if (value is List) {
      return List<dynamic>.from(value);
    }
    return const <dynamic>[];
  }

  List<StorageFileItem> _extractFiles(
    dynamic data, {
    String? prefix,
    String? publicBaseUrl,
  }) {
    final result = <StorageFileItem>[];

    void addFile(
      dynamic raw, {
      String? bucketFallback,
      String? prefixFallback,
      String? publicBaseUrlFallback,
    }) {
      final fileMap = _asMap(raw);
      if (fileMap.isEmpty) {
        return;
      }
      final normalized = _normalizeFileMap(
        fileMap,
        bucketFallback: bucketFallback,
        prefixFallback: prefixFallback,
        publicBaseUrlFallback: publicBaseUrlFallback,
      );
      if (normalized.isEmpty) {
        return;
      }
      result.add(StorageFileItem.fromJson(normalized));
    }

    void addGroup(String? bucket, dynamic filesRaw) {
      for (final file in _asList(filesRaw)) {
        addFile(
          file,
          bucketFallback: bucket,
          prefixFallback: prefix,
          publicBaseUrlFallback: publicBaseUrl,
        );
      }
    }

    if (data is List) {
      for (final item in data) {
        final map = _asMap(item);
        if (map.containsKey('files')) {
          final bucket = map['bucket']?.toString() ?? map['name']?.toString();
          addGroup(bucket, map['files']);
        } else {
          addFile(
            map,
            prefixFallback: prefix,
            publicBaseUrlFallback: publicBaseUrl,
          );
        }
      }
      return result;
    }

    if (data is Map) {
      final map = _asMap(data);

      if (map['files'] is List) {
        final bucket = map['bucket']?.toString() ?? map['name']?.toString();
        addGroup(bucket, map['files']);
        return result;
      }

      if (map['buckets'] is List) {
        for (final item in _asList(map['buckets'])) {
          final group = _asMap(item);
          final bucket =
              group['bucket']?.toString() ?? group['name']?.toString();
          addGroup(bucket, group['files']);
        }
        return result;
      }

      for (final entry in map.entries) {
        if (entry.value is List) {
          addGroup(entry.key, entry.value);
        }
      }
      if (result.isNotEmpty) {
        return result;
      }

      addFile(
        map,
        prefixFallback: prefix,
        publicBaseUrlFallback: publicBaseUrl,
      );
      return result;
    }

    return result;
  }

  Map<String, dynamic> _normalizeFileMap(
    Map<String, dynamic> source, {
    String? bucketFallback,
    String? prefixFallback,
    String? publicBaseUrlFallback,
  }) {
    final normalized = Map<String, dynamic>.from(source);

    final bucket = _firstString(source, const [
      'bucket',
      'bucket_name',
      'bucketName',
    ], fallback: bucketFallback);

    String? path = _firstString(source, const [
      'path',
      'file_path',
      'filePath',
      'full_path',
      'fullPath',
      'key',
      'object_key',
      'objectKey',
    ]);
    String? name = _firstString(source, const [
      'name',
      'file_name',
      'fileName',
      'filename',
      'object_name',
      'objectName',
    ]);

    final normalizedPrefix = _normalizeText(prefixFallback);
    if (path == null && name != null && normalizedPrefix != null) {
      if (name.startsWith('$normalizedPrefix/')) {
        path = name;
      } else {
        path = '$normalizedPrefix/$name';
      }
    }
    if (name == null && path != null) {
      final segments = path.split('/');
      if (segments.isNotEmpty) {
        name = segments.last;
      }
    }

    final metadata = _asMap(source['metadata']);
    String? publicUrl = _firstString(source, const [
      'public_url',
      'publicUrl',
      'publicURL',
      'url',
      'file_url',
      'fileUrl',
      'cdn_url',
      'cdnUrl',
    ]);
    String? storageUrl = _firstString(source, const [
      'storage_url',
      'storageUrl',
      'storageURL',
      'path_url',
      'pathUrl',
      'object_url',
      'objectUrl',
    ]);

    publicUrl ??= _firstString(metadata, const [
      'public_url',
      'publicUrl',
      'url',
      'file_url',
      'fileUrl',
    ]);
    storageUrl ??= _firstString(metadata, const [
      'storage_url',
      'storageUrl',
      'path_url',
      'pathUrl',
      'object_url',
      'objectUrl',
    ]);

    final effectivePath = path ?? name;
    final hasFileIdentity = source['id'] != null || metadata.isNotEmpty;

    publicUrl ??= _toPublicUrl(storageUrl);
    if (publicUrl == null && hasFileIdentity) {
      publicUrl = _buildPublicUrl(
        publicBaseUrlFallback,
        bucket: bucket,
        path: effectivePath,
      );
    }

    if (bucket != null) {
      normalized['bucket'] = bucket;
    }
    if (path != null) {
      normalized['path'] = path;
    }
    if (name != null) {
      normalized['name'] = name;
    }
    if (publicUrl != null) {
      normalized['public_url'] = publicUrl;
    }
    if (storageUrl != null) {
      normalized['storage_url'] = storageUrl;
    }

    final createdAt = _firstString(source, const ['created_at', 'createdAt']);
    final updatedAt = _firstString(source, const ['updated_at', 'updatedAt']);
    if (createdAt != null) {
      normalized['created_at'] = createdAt;
    }
    if (updatedAt != null) {
      normalized['updated_at'] = updatedAt;
    }

    return normalized;
  }

  String? _firstString(
    Map<String, dynamic> map,
    List<String> keys, {
    String? fallback,
  }) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      final normalized = value.toString().trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return _normalizeText(fallback);
  }

  String? _normalizeText(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _toPublicUrl(String? storageUrl) {
    final normalized = _normalizeText(storageUrl);
    if (normalized == null) {
      return null;
    }
    if (normalized.contains('/storage/v1/object/public/')) {
      return normalized;
    }
    if (normalized.contains('/storage/v1/object/')) {
      return normalized.replaceFirst(
        '/storage/v1/object/',
        '/storage/v1/object/public/',
      );
    }
    if (normalized.contains('/object/public/')) {
      return normalized;
    }
    if (normalized.contains('/object/')) {
      return normalized.replaceFirst('/object/', '/object/public/');
    }
    return null;
  }

  String? _buildPublicUrl(String? baseUrl, {String? bucket, String? path}) {
    final normalizedBase = _normalizeText(baseUrl);
    final normalizedBucket = _normalizeText(bucket);
    final normalizedPath = _normalizeText(path);

    if (normalizedBase == null ||
        normalizedBucket == null ||
        normalizedPath == null) {
      return null;
    }

    final base = normalizedBase.endsWith('/')
        ? normalizedBase.substring(0, normalizedBase.length - 1)
        : normalizedBase;
    final encodedBucket = Uri.encodeComponent(normalizedBucket);
    final encodedPath = normalizedPath
        .split('/')
        .map(Uri.encodeComponent)
        .join('/');
    return '$base/$encodedBucket/$encodedPath';
  }

  bool _needsPublicUrlGeneration(List<StorageFileItem> files) {
    for (final item in files) {
      final hasPublic = _normalizeText(item.publicUrl) != null;
      final hasStorage = _normalizeText(item.storageUrl) != null;
      if (hasPublic || hasStorage) {
        continue;
      }
      final hasBucket = _normalizeText(item.bucket) != null;
      final hasPath = _normalizeText(item.path ?? item.name) != null;
      if (hasBucket && hasPath) {
        return true;
      }
    }
    return false;
  }

  Future<String?> _guessPublicBaseUrl() async {
    final probePaths = <String>[
      '/banners',
      '/partners',
      '/portfolio_items',
      '/tuning',
      '/service_offerings',
      '/work_post',
      '/about',
      '/admin/banners',
      '/admin/partners',
      '/admin/portfolio_items',
      '/admin/tuning',
    ];

    for (final path in probePaths) {
      try {
        final response = await _dio.get<dynamic>(path);
        final baseUrl = _findPublicBaseUrl(response.data);
        if (baseUrl != null) {
          return baseUrl;
        }
      } catch (_) {
        // Best-effort probing.
      }
    }
    return null;
  }

  String? _findPublicBaseUrl(dynamic value, {int depth = 0}) {
    if (depth > 6) {
      return null;
    }

    if (value is String) {
      final index = value.indexOf(_publicObjectMarker);
      if (index < 0) {
        return null;
      }
      final end = index + _publicObjectMarker.length;
      final normalized = value.substring(0, end).trim();
      if (normalized.isEmpty) {
        return null;
      }
      return normalized.endsWith('/')
          ? normalized.substring(0, normalized.length - 1)
          : normalized;
    }

    if (value is Map) {
      for (final nested in value.values) {
        final found = _findPublicBaseUrl(nested, depth: depth + 1);
        if (found != null) {
          return found;
        }
      }
      return null;
    }

    if (value is List) {
      for (final nested in value) {
        final found = _findPublicBaseUrl(nested, depth: depth + 1);
        if (found != null) {
          return found;
        }
      }
      return null;
    }

    return null;
  }

  Future<MultipartFile> _toMultipartFile(
    PlatformFile file, {
    String? filename,
  }) async {
    final effectiveFilename = (filename == null || filename.trim().isEmpty)
        ? file.name
        : filename.trim();

    if (kIsWeb) {
      final bytes = file.bytes;
      if (bytes == null) {
        throw const ApiError(
          type: ApiErrorType.badRequest,
          message: 'Не удалось прочитать файл в браузере.',
        );
      }
      return MultipartFile.fromBytes(bytes, filename: effectiveFilename);
    }

    if (file.path != null && file.path!.isNotEmpty) {
      return MultipartFile.fromFile(file.path!, filename: effectiveFilename);
    }

    if (file.bytes != null) {
      return MultipartFile.fromBytes(file.bytes!, filename: effectiveFilename);
    }

    throw const ApiError(
      type: ApiErrorType.badRequest,
      message: 'Файл не содержит данных.',
    );
  }
}
