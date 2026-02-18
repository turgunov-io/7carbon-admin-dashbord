import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/request_state.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/ui/widgets/entity_table.dart';
import '../../../core/ui/widgets/formatters.dart';
import '../../../core/ui/widgets/image_preview_gallery.dart';
import '../../../core/ui/widgets/section_container.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../application/work_posts_providers.dart';
import '../models/work_post_item.dart';

class WorkPostsPage extends StatelessWidget {
  const WorkPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WorkPostsCubit(context.read<AppDependencies>().workPostsRepository)
            ..load(),
      child: const _WorkPostsView(),
    );
  }
}

class _WorkPostsView extends StatefulWidget {
  const _WorkPostsView();

  @override
  State<_WorkPostsView> createState() => _WorkPostsViewState();
}

class _WorkPostsViewState extends State<_WorkPostsView> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkPostsCubit>();

    return SectionContainer(
      title: 'Посты о работах',
      subtitle:
          'Добавление и редактирование доступны локально в текущей сессии.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: cubit.load,
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить'),
        ),
        FilledButton.icon(
          onPressed: () => _openEditor(cubit),
          icon: const Icon(Icons.add),
          label: const Text('Добавить пост'),
        ),
      ],
      child: BlocBuilder<WorkPostsCubit, WorkPostsState>(
        builder: (context, state) {
          if (state.status == RequestStatus.loading && state.items.isEmpty) {
            return const LoadingState();
          }

          if (state.status == RequestStatus.failure && state.items.isEmpty) {
            return ErrorState(
              message: state.message ?? 'Не удалось загрузить посты',
              onRetry: cubit.load,
            );
          }

          if (state.items.isEmpty) {
            return const EmptyState(message: 'Список постов пуст');
          }

          return EntityTable<WorkPostItem>(
            items: state.items,
            searchHint: 'Поиск по заголовку и описанию',
            searchMatcher: (item, query) {
              return item.title.toLowerCase().contains(query) ||
                  item.description.toLowerCase().contains(query);
            },
            columns: [
              DataColumnDefinition(
                label: 'ИД',
                sortValue: (item) => item.id,
                cellBuilder: (item) => Text(item.id.toString()),
              ),
              DataColumnDefinition(
                label: 'Заголовок',
                sortValue: (item) => item.title,
                cellBuilder: (item) => Text(item.title),
              ),
              DataColumnDefinition(
                label: 'Краткое описание',
                sortValue: (item) => item.description,
                cellBuilder: (item) => SizedBox(
                  width: 260,
                  child: Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumnDefinition(
                label: 'Полное описание',
                sortValue: (item) => item.fullDescription,
                cellBuilder: (item) => SizedBox(
                  width: 300,
                  child: Text(
                    item.fullDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumnDefinition(
                label: 'Изображение',
                cellBuilder: (item) => ImagePreview(url: item.imageUrl),
              ),
              DataColumnDefinition(
                label: 'Видео',
                sortValue: (item) => item.videoUrl,
                cellBuilder: (item) => SizedBox(
                  width: 220,
                  child: Text(
                    textOrDash(item.videoUrl),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumnDefinition(
                label: 'Выполненные работы',
                cellBuilder: (item) => SizedBox(
                  width: 260,
                  child: Text(
                    item.performedWorks.isEmpty
                        ? dashValue
                        : item.performedWorks.join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumnDefinition(
                label: 'Галерея',
                cellBuilder: (item) =>
                    ImagePreviewGallery(urls: item.galleryImages),
              ),
              DataColumnDefinition(
                label: 'Действия',
                cellBuilder: (item) => IconButton(
                  tooltip: 'Редактировать',
                  onPressed: () => _openEditor(cubit, existing: item),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openEditor(
    WorkPostsCubit cubit, {
    WorkPostItem? existing,
  }) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    final fullDescriptionController = TextEditingController(
      text: existing?.fullDescription ?? '',
    );
    final imageController = TextEditingController(
      text: existing?.imageUrl ?? '',
    );
    final videoController = TextEditingController(
      text: existing?.videoUrl ?? '',
    );
    final worksController = TextEditingController(
      text: existing == null ? '' : existing.performedWorks.join(', '),
    );
    final galleryController = TextEditingController(
      text: existing == null ? '' : existing.galleryImages.join(', '),
    );
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Новый пост' : 'Редактирование поста'),
          content: SizedBox(
            width: 560,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Заголовок *',
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Краткое описание *',
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: fullDescriptionController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Полное описание *',
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: 'Ссылка на изображение',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: videoController,
                      decoration: const InputDecoration(
                        labelText: 'Ссылка на видео',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: worksController,
                      decoration: const InputDecoration(
                        labelText: 'Выполненные работы (через запятую)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: galleryController,
                      decoration: const InputDecoration(
                        labelText: 'Галерея (ссылки через запятую)',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (saved != true) {
      titleController.dispose();
      descriptionController.dispose();
      fullDescriptionController.dispose();
      imageController.dispose();
      videoController.dispose();
      worksController.dispose();
      galleryController.dispose();
      return;
    }

    final item = WorkPostItem(
      id: existing?.id ?? cubit.nextLocalId(),
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      fullDescription: fullDescriptionController.text.trim(),
      imageUrl: _nullable(imageController.text),
      videoUrl: _nullable(videoController.text),
      performedWorks: _splitList(worksController.text),
      galleryImages: _splitList(galleryController.text),
    );

    if (existing == null) {
      cubit.addLocal(item);
      _showMessage('Пост добавлен (локально)');
    } else {
      cubit.updateLocal(item);
      _showMessage('Пост обновлен (локально)');
    }

    titleController.dispose();
    descriptionController.dispose();
    fullDescriptionController.dispose();
    imageController.dispose();
    videoController.dispose();
    worksController.dispose();
    galleryController.dispose();
  }

  List<String> _splitList(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String? _nullable(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Обязательное поле';
    }
    return null;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
