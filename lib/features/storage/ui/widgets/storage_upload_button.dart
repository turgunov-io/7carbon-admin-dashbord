import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_error.dart';
import '../../application/storage_providers.dart';
import '../../models/storage_upload_result.dart';

class StorageUploadButton extends ConsumerStatefulWidget {
  const StorageUploadButton({
    required this.onUploaded,
    this.bucket,
    this.folder,
    this.filename,
    this.upsert = true,
    this.label = 'Загрузить',
    super.key,
  });

  final String? bucket;
  final String? folder;
  final String? filename;
  final bool upsert;
  final String label;
  final ValueChanged<StorageUploadResult> onUploaded;

  @override
  ConsumerState<StorageUploadButton> createState() =>
      _StorageUploadButtonState();
}

class _StorageUploadButtonState extends ConsumerState<StorageUploadButton> {
  bool _uploading = false;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.tonalIcon(
          onPressed: _uploading ? null : _pickAndUpload,
          icon: _uploading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload_outlined),
          label: Text(widget.label),
        ),
        if (_uploading) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: 220,
            child: LinearProgressIndicator(value: _progress),
          ),
          const SizedBox(height: 4),
          Text('${(_progress * 100).clamp(0, 100).toStringAsFixed(0)}%'),
        ],
      ],
    );
  }

  Future<void> _pickAndUpload() async {
    final picked = await FilePicker.platform.pickFiles(
      withData: kIsWeb,
      allowMultiple: false,
    );
    if (picked == null || picked.files.isEmpty) {
      return;
    }

    final file = picked.files.single;
    final service = ref.read(storageServiceProvider);

    setState(() {
      _uploading = true;
      _progress = 0;
    });

    try {
      final result = await service.uploadFile(
        file: file,
        bucket: widget.bucket,
        folder: widget.folder,
        filename: widget.filename,
        upsert: widget.upsert,
        onSendProgress: (sent, total) {
          if (!mounted || total <= 0) {
            return;
          }
          setState(() {
            _progress = sent / total;
          });
        },
      );
      if (!mounted) {
        return;
      }
      widget.onUploaded(result);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Файл загружен')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = switch (error) {
        ApiError apiError => apiError.message,
        _ => error.toString(),
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $message')));
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _progress = 0;
        });
      }
    }
  }
}
