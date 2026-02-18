import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/widgets/entity_table.dart';
import '../../../core/ui/widgets/formatters.dart';
import '../../../core/ui/widgets/section_container.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../application/storage_providers.dart';
import '../application/storage_state.dart';
import '../models/storage_file_item.dart';
import '../models/storage_upload_result.dart';
import 'widgets/storage_upload_button.dart';

class StoragePage extends ConsumerStatefulWidget {
  const StoragePage({super.key});

  @override
  ConsumerState<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends ConsumerState<StoragePage> {
  final _bucketFilterController = TextEditingController();
  final _prefixFilterController = TextEditingController();
  final _uploadBucketController = TextEditingController();
  final _uploadFolderController = TextEditingController();
  final _uploadFilenameController = TextEditingController();

  bool _upsert = true;
  StorageUploadResult? _lastUpload;

  @override
  void dispose() {
    _bucketFilterController.dispose();
    _prefixFilterController.dispose();
    _uploadBucketController.dispose();
    _uploadFolderController.dispose();
    _uploadFilenameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storageControllerProvider);

    return SectionContainer(
      title: 'Storage',
      subtitle: state.allBucketsMode
          ? 'Режим all buckets: /admin/storage/files?all=true&limit=50'
          : 'Режим single bucket: /admin/storage/files?bucket=...&prefix=...',
      actions: [
        FilledButton.tonalIcon(
          onPressed: state.loading ? null : () => _refreshCurrent(state),
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить'),
        ),
        FilledButton.icon(
          onPressed: state.loading
              ? null
              : () => state.allBucketsMode
                    ? _loadSingleBucketMode()
                    : _loadAllBucketsMode(),
          icon: Icon(
            state.allBucketsMode ? Icons.filter_alt_outlined : Icons.public,
          ),
          label: Text(
            state.allBucketsMode ? 'Single bucket mode' : 'Load all buckets',
          ),
        ),
      ],
      child: Column(
        children: [
          _buildToolbarCard(state),
          const SizedBox(height: 10),
          Expanded(child: _buildContent(state)),
        ],
      ),
    );
  }

  Widget _buildToolbarCard(StorageState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _bucketFilterController,
                    enabled: !state.allBucketsMode,
                    decoration: InputDecoration(
                      labelText: state.allBucketsMode
                          ? 'Bucket filter (disabled in all mode)'
                          : 'Bucket filter',
                    ),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _prefixFilterController,
                    decoration: const InputDecoration(
                      labelText: 'Prefix filter',
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: state.loading ? null : () => _applyFilters(state),
                  icon: const Icon(Icons.search),
                  label: Text(
                    state.allBucketsMode
                        ? 'Применить (all buckets)'
                        : 'Применить',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _uploadBucketController,
                    decoration: const InputDecoration(
                      labelText: 'Bucket upload',
                    ),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _uploadFolderController,
                    decoration: const InputDecoration(labelText: 'Folder'),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _uploadFilenameController,
                    decoration: const InputDecoration(labelText: 'Filename'),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _upsert,
                      onChanged: (value) {
                        setState(() {
                          _upsert = value ?? true;
                        });
                      },
                    ),
                    const Text('upsert'),
                  ],
                ),
                StorageUploadButton(
                  label: 'Upload file',
                  bucket: _nullable(_uploadBucketController.text),
                  folder: _nullable(_uploadFolderController.text),
                  filename: _nullable(_uploadFilenameController.text),
                  upsert: _upsert,
                  onUploaded: (result) {
                    setState(() {
                      _lastUpload = result;
                    });
                    _refreshCurrent(state);
                  },
                ),
              ],
            ),
            if (_lastUpload != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: SelectableText('Uploaded: ${_lastUpload!.publicUrl}'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(StorageState state) {
    final controller = ref.read(storageControllerProvider.notifier);

    if (state.loading && state.files.isEmpty) {
      return const LoadingState();
    }

    if (state.errorMessage != null && state.files.isEmpty) {
      return ErrorState(
        message: state.errorMessage!,
        onRetry: () => _refreshCurrent(state),
      );
    }

    if (state.files.isEmpty) {
      return const EmptyState(message: 'Файлы не найдены');
    }

    if (state.allBucketsMode) {
      return _buildGroupedView(state, controller);
    }

    return _buildFilesTable(
      files: state.files,
      state: state,
      controller: controller,
      showBucketColumn: true,
      showErrorLabel: true,
    );
  }

  Widget _buildGroupedView(StorageState state, StorageController controller) {
    final groups = <String, List<StorageFileItem>>{};
    for (final file in state.files) {
      final bucket = textOrDash(file.bucket);
      groups.putIfAbsent(bucket, () => <StorageFileItem>[]).add(file);
    }

    final buckets = groups.keys.toList()..sort();

    return ListView.separated(
      itemCount: buckets.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          if (state.errorMessage == null) {
            return const SizedBox.shrink();
          }
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }

        final bucket = buckets[index - 1];
        final files = groups[bucket]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bucket: $bucket (${files.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildFilesTable(
              files: files,
              state: state,
              controller: controller,
              showBucketColumn: false,
              showErrorLabel: false,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilesTable({
    required List<StorageFileItem> files,
    required StorageState state,
    required StorageController controller,
    required bool showBucketColumn,
    required bool showErrorLabel,
  }) {
    final columns = <DataColumnDefinition<StorageFileItem>>[];

    if (showBucketColumn) {
      columns.add(
        DataColumnDefinition(
          label: 'Bucket',
          sortValue: (item) => item.bucket,
          cellBuilder: (item) =>
              SizedBox(width: 180, child: Text(textOrDash(item.bucket))),
        ),
      );
    }

    columns.addAll([
      DataColumnDefinition(
        label: 'Path',
        sortValue: (item) => item.path,
        cellBuilder: (item) => SizedBox(
          width: 320,
          child: Text(
            textOrDash(item.path ?? item.name),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataColumnDefinition(
        label: 'Public URL',
        sortValue: _resolvedUrl,
        cellBuilder: (item) => SizedBox(
          width: 360,
          child: Text(
            textOrDash(_resolvedUrl(item)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataColumnDefinition(
        label: 'Created',
        sortValue: (item) => item.createdAt,
        cellBuilder: (item) =>
            SizedBox(width: 180, child: Text(textOrDash(item.createdAt))),
      ),
      DataColumnDefinition(
        label: 'Действия',
        cellBuilder: (item) => SizedBox(
          width: 120,
          child: Row(
            children: [
              IconButton(
                tooltip: 'Copy URL',
                onPressed: _resolvedUrl(item) == null
                    ? null
                    : () => _copyUrl(_resolvedUrl(item)!),
                icon: const Icon(Icons.copy_outlined),
              ),
              IconButton(
                tooltip: 'Delete file',
                onPressed: state.deletingPath == (item.path ?? item.name)
                    ? null
                    : () => _deleteFile(controller, item),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    ]);

    return EntityTable<StorageFileItem>(
      items: files,
      searchHint: 'Поиск по пути или URL',
      searchMatcher: (item, query) {
        final resolvedUrl = _resolvedUrl(item);
        return textOrDash(item.path).toLowerCase().contains(query) ||
            textOrDash(resolvedUrl).toLowerCase().contains(query) ||
            textOrDash(item.storageUrl).toLowerCase().contains(query) ||
            textOrDash(item.bucket).toLowerCase().contains(query);
      },
      toolbarWidgets: [
        if (showErrorLabel && state.errorMessage != null)
          Text(
            state.errorMessage!,
            style: const TextStyle(color: Colors.redAccent),
          ),
      ],
      columns: columns,
    );
  }

  Future<void> _deleteFile(
    StorageController controller,
    StorageFileItem item,
  ) async {
    final path = item.path ?? item.name;
    if (path == null || path.trim().isEmpty) {
      return;
    }

    final approve = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить файл'),
          content: Text('Удалить файл:\n$path'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (approve != true) {
      return;
    }

    await controller.deleteFile(item);
  }

  Future<void> _copyUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('URL скопирован')));
  }

  void _refreshCurrent(StorageState state) {
    final controller = ref.read(storageControllerProvider.notifier);
    if (state.allBucketsMode) {
      controller.loadFiles(
        prefix: _nullable(_prefixFilterController.text),
        allBucketsMode: true,
        limit: 50,
        offset: 0,
        overrideFilters: true,
      );
      return;
    }
    _applyFilters(state);
  }

  void _loadAllBucketsMode() {
    ref
        .read(storageControllerProvider.notifier)
        .loadFiles(
          prefix: _nullable(_prefixFilterController.text),
          allBucketsMode: true,
          limit: 50,
          offset: 0,
          overrideFilters: true,
        );
  }

  void _loadSingleBucketMode() {
    ref
        .read(storageControllerProvider.notifier)
        .loadFiles(
          bucket: _nullable(_bucketFilterController.text),
          prefix: _nullable(_prefixFilterController.text),
          allBucketsMode: false,
          limit: 50,
          offset: 0,
          overrideFilters: true,
        );
  }

  void _applyFilters(StorageState state) {
    final controller = ref.read(storageControllerProvider.notifier);
    controller.loadFiles(
      bucket: state.allBucketsMode
          ? null
          : _nullable(_bucketFilterController.text),
      prefix: _nullable(_prefixFilterController.text),
      allBucketsMode: state.allBucketsMode,
      limit: 50,
      offset: 0,
      overrideFilters: true,
    );
  }

  String? _nullable(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _resolvedUrl(StorageFileItem item) {
    final publicUrl = _nullable(item.publicUrl ?? '');
    if (publicUrl != null) {
      return publicUrl;
    }
    return _nullable(item.storageUrl ?? '');
  }
}
