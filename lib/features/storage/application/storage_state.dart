import '../models/storage_file_item.dart';

class StorageState {
  const StorageState({
    required this.loading,
    required this.files,
    required this.meta,
    required this.allBucketsMode,
    this.errorMessage,
    this.deletingPath,
  });

  const StorageState.initial()
    : loading = false,
      files = const <StorageFileItem>[],
      meta = const <String, dynamic>{},
      allBucketsMode = false,
      errorMessage = null,
      deletingPath = null;

  final bool loading;
  final List<StorageFileItem> files;
  final Map<String, dynamic> meta;
  final bool allBucketsMode;
  final String? errorMessage;
  final String? deletingPath;

  StorageState copyWith({
    bool? loading,
    List<StorageFileItem>? files,
    Map<String, dynamic>? meta,
    bool? allBucketsMode,
    String? errorMessage,
    bool clearError = false,
    String? deletingPath,
    bool clearDeletingPath = false,
  }) {
    return StorageState(
      loading: loading ?? this.loading,
      files: files ?? this.files,
      meta: meta ?? this.meta,
      allBucketsMode: allBucketsMode ?? this.allBucketsMode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      deletingPath: clearDeletingPath
          ? null
          : (deletingPath ?? this.deletingPath),
    );
  }
}
