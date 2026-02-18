import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/network/api_error.dart';
import '../../admin/application/admin_providers.dart';
import '../data/storage_service.dart';
import '../models/storage_file_item.dart';
import '../models/storage_upload_result.dart';
import 'storage_state.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(dioProvider));
});

final storageControllerProvider =
    StateNotifierProvider.autoDispose<StorageController, StorageState>((ref) {
      final service = ref.watch(storageServiceProvider);
      return StorageController(service)..loadFiles();
    });

class StorageController extends StateNotifier<StorageState> {
  StorageController(this._service) : super(const StorageState.initial());

  final StorageService _service;

  bool _allBucketsMode = false;
  String? _bucket;
  String? _prefix;
  int _limit = 50;
  int _offset = 0;

  Future<void> loadFiles({
    String? bucket,
    String? prefix,
    bool? allBucketsMode,
    int? limit,
    int? offset,
    bool overrideFilters = false,
  }) async {
    if (allBucketsMode != null) {
      _allBucketsMode = allBucketsMode;
    }

    if (overrideFilters) {
      _bucket = _normalizeEmpty(bucket);
      _prefix = _normalizeEmpty(prefix);
    } else {
      _bucket = _normalizeEmpty(bucket) ?? _bucket;
      _prefix = _normalizeEmpty(prefix) ?? _prefix;
    }
    _limit = limit ?? _limit;
    _offset = offset ?? _offset;

    state = state.copyWith(
      loading: true,
      clearError: true,
      allBucketsMode: _allBucketsMode,
    );
    try {
      final result = await _service.listFiles(
        bucket: _bucket,
        prefix: _prefix,
        allBuckets: _allBucketsMode,
        limit: _limit,
        offset: _offset,
      );
      state = state.copyWith(
        loading: false,
        files: result.files,
        meta: result.meta,
        allBucketsMode: _allBucketsMode,
        clearError: true,
        clearDeletingPath: true,
      );
    } on ApiError catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: _humanizeError(error),
        allBucketsMode: _allBucketsMode,
      );
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error.toString(),
        allBucketsMode: _allBucketsMode,
      );
    }
  }

  Future<StorageUploadResult> uploadFile(
    PlatformFile file, {
    String? bucket,
    String? folder,
    String? filename,
    bool upsert = true,
    required void Function(int sent, int total) onSendProgress,
  }) {
    return _service.uploadFile(
      file: file,
      bucket: _normalizeEmpty(bucket) ?? _bucket,
      folder: _normalizeEmpty(folder),
      filename: _normalizeEmpty(filename),
      upsert: upsert,
      onSendProgress: onSendProgress,
    );
  }

  Future<void> deleteFile(StorageFileItem item) async {
    final path = item.path ?? item.name;
    if (path == null || path.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Не удалось определить путь файла.');
      return;
    }

    final bucket = _bucket ?? item.bucket;
    state = state.copyWith(deletingPath: path, clearError: true);
    try {
      await _service.deleteFile(bucket: _normalizeEmpty(bucket), path: path);
      state = state.copyWith(clearDeletingPath: true);
      await loadFiles();
    } on ApiError catch (error) {
      state = state.copyWith(
        errorMessage: _humanizeError(error),
        clearDeletingPath: true,
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: error.toString(),
        clearDeletingPath: true,
      );
    }
  }

  String? _normalizeEmpty(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _humanizeError(ApiError error) {
    switch (error.type) {
      case ApiErrorType.unauthorized:
        return '401: Необходим ADMIN_TOKEN или токен недействителен.';
      case ApiErrorType.timeout:
        return 'Timeout: сервер не ответил вовремя.';
      case ApiErrorType.server:
        if (error.statusCode == 502) {
          return '502: backend временно недоступен.';
        }
        return error.message;
      default:
        return error.message;
    }
  }
}
