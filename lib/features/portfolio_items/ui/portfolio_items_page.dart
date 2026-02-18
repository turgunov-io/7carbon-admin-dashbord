import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/request_state.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/ui/widgets/entity_table.dart';
import '../../../core/ui/widgets/formatters.dart';
import '../../../core/ui/widgets/image_preview_gallery.dart';
import '../../../core/ui/widgets/section_container.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../application/portfolio_items_providers.dart';
import '../models/portfolio_item.dart';

class PortfolioItemsPage extends StatelessWidget {
  const PortfolioItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PortfolioItemsCubit(
        context.read<AppDependencies>().portfolioItemsRepository,
      )..load(),
      child: const _PortfolioItemsView(),
    );
  }
}

class _PortfolioItemsView extends StatefulWidget {
  const _PortfolioItemsView();

  @override
  State<_PortfolioItemsView> createState() => _PortfolioItemsViewState();
}

class _PortfolioItemsViewState extends State<_PortfolioItemsView> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PortfolioItemsCubit>();

    return SectionContainer(
      title: 'Портфолио',
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
          label: const Text('Добавить запись'),
        ),
      ],
      child: BlocBuilder<PortfolioItemsCubit, PortfolioItemsState>(
        builder: (context, state) {
          if (state.status == RequestStatus.loading && state.items.isEmpty) {
            return const LoadingState();
          }

          if (state.status == RequestStatus.failure && state.items.isEmpty) {
            return ErrorState(
              message: state.message ?? 'Не удалось загрузить портфолио',
              onRetry: cubit.load,
            );
          }

          if (state.items.isEmpty) {
            return const EmptyState(message: 'Список портфолио пуст');
          }

          return EntityTable<PortfolioItem>(
            items: state.items,
            searchHint: 'Поиск по бренду и заголовку',
            searchMatcher: (item, query) {
              return textOrDash(item.brand).toLowerCase().contains(query) ||
                  item.title.toLowerCase().contains(query);
            },
            columns: [
              DataColumnDefinition(
                label: 'ИД',
                sortValue: (item) => item.id,
                cellBuilder: (item) => Text(item.id.toString()),
              ),
              DataColumnDefinition(
                label: 'Бренд',
                sortValue: (item) => item.brand,
                cellBuilder: (item) => Text(textOrDash(item.brand)),
              ),
              DataColumnDefinition(
                label: 'Заголовок',
                sortValue: (item) => item.title,
                cellBuilder: (item) => Text(item.title),
              ),
              DataColumnDefinition(
                label: 'Изображение',
                cellBuilder: (item) => ImagePreview(url: item.imageUrl),
              ),
              DataColumnDefinition(
                label: 'Описание',
                sortValue: (item) => item.description,
                cellBuilder: (item) => SizedBox(
                  width: 280,
                  child: Text(
                    textOrDash(item.description),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumnDefinition(
                label: 'Ссылка Ютуб',
                sortValue: (item) => item.youtubeLink,
                cellBuilder: (item) => SizedBox(
                  width: 250,
                  child: Text(
                    textOrDash(item.youtubeLink),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumnDefinition(
                label: 'Создано',
                sortValue: (item) => item.createdAt,
                cellBuilder: (item) =>
                    Text(formatDateTimeOrDash(item.createdAt)),
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
    PortfolioItemsCubit cubit, {
    PortfolioItem? existing,
  }) async {
    final brandController = TextEditingController(text: existing?.brand ?? '');
    final titleController = TextEditingController(text: existing?.title ?? '');
    final imageController = TextEditingController(
      text: existing?.imageUrl ?? '',
    );
    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    final youtubeController = TextEditingController(
      text: existing?.youtubeLink ?? '',
    );

    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existing == null
                ? 'Новая запись портфолио'
                : 'Редактирование записи',
          ),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: brandController,
                      decoration: const InputDecoration(labelText: 'Бренд'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Заголовок *',
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: 'Ссылка на изображение *',
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Описание'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: youtubeController,
                      decoration: const InputDecoration(
                        labelText: 'Ссылка на Ютуб',
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
      brandController.dispose();
      titleController.dispose();
      imageController.dispose();
      descriptionController.dispose();
      youtubeController.dispose();
      return;
    }

    final item = PortfolioItem(
      id: existing?.id ?? cubit.nextLocalId(),
      brand: _nullable(brandController.text),
      title: titleController.text.trim(),
      imageUrl: imageController.text.trim(),
      description: _nullable(descriptionController.text),
      youtubeLink: _nullable(youtubeController.text),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    if (existing == null) {
      cubit.addLocal(item);
      _showMessage('Запись добавлена (локально)');
    } else {
      cubit.updateLocal(item);
      _showMessage('Запись обновлена (локально)');
    }

    brandController.dispose();
    titleController.dispose();
    imageController.dispose();
    descriptionController.dispose();
    youtubeController.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Обязательное поле';
    }
    return null;
  }

  String? _nullable(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
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
