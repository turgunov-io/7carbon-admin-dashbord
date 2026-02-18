import 'package:flutter/material.dart';

import 'formatters.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({required this.url, this.size = 56, super.key});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalized = textOrDash(url);
    if (normalized == dashValue) {
      return _placeholder(size);
    }

    return InkWell(
      onTap: () => _openImageDialog(context, normalized),
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: size,
          height: size,
          child: Image.network(
            normalized,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _placeholder(size),
            loadingBuilder: (context, child, event) {
              if (event == null) {
                return child;
              }
              return ColoredBox(
                color: Colors.black12,
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }

  void _openImageDialog(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Не удалось загрузить изображение'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ImagePreviewGallery extends StatelessWidget {
  const ImagePreviewGallery({
    required this.urls,
    this.previewLimit = 4,
    super.key,
  });

  final List<String> urls;
  final int previewLimit;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return const Text(dashValue);
    }

    final preview = urls.take(previewLimit).toList();
    final hidden = urls.length - preview.length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final url in preview) ImagePreview(url: url, size: 52),
        if (hidden > 0)
          Chip(label: Text('+$hidden'), visualDensity: VisualDensity.compact),
      ],
    );
  }
}
