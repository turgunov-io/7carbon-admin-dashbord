import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/widgets/entity_table.dart';
import '../../../core/ui/widgets/formatters.dart';
import '../../../core/ui/widgets/section_container.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../application/admin_entity_state.dart';
import '../application/admin_providers.dart';
import '../domain/admin_entity_definition.dart';
import '../models/admin_entity_item.dart';
import '../../storage/ui/widgets/storage_upload_button.dart';

class AdminEntityPage extends ConsumerStatefulWidget {
  const AdminEntityPage({
    required this.entityKey,
    this.openCreateOnLoad = false,
    super.key,
  });

  final String entityKey;
  final bool openCreateOnLoad;

  @override
  ConsumerState<AdminEntityPage> createState() => _AdminEntityPageState();
}

class _AdminEntityPageState extends ConsumerState<AdminEntityPage> {
  bool _createOpenedOnce = false;
  final _tuningSearchController = TextEditingController();
  final _partnersSearchController = TextEditingController();
  final _bannersSearchController = TextEditingController();
  String _tuningSearchQuery = '';
  String _partnersSearchQuery = '';
  String _bannersSearchQuery = '';

  @override
  void dispose() {
    _tuningSearchController.dispose();
    _partnersSearchController.dispose();
    _bannersSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entity = ref.watch(adminEntityByKeyProvider(widget.entityKey));
    final state = ref.watch(adminEntityControllerProvider(widget.entityKey));
    final controller = ref.read(
      adminEntityControllerProvider(widget.entityKey).notifier,
    );

    if (widget.openCreateOnLoad && !_createOpenedOnce) {
      _createOpenedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openCreateDialog(entity, controller);
      });
    }

    return SectionContainer(
      title: entity.title,
      subtitle: 'CRUD для ${entity.endpoint}',
      actions: [
        FilledButton.tonalIcon(
          onPressed: state.submitting ? null : controller.load,
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить'),
        ),
        FilledButton.icon(
          onPressed: state.submitting
              ? null
              : () => _openCreateDialog(entity, controller),
          icon: const Icon(Icons.add),
          label: const Text('Создать'),
        ),
      ],
      child: _buildContent(
        entity: entity,
        state: state,
        controller: controller,
      ),
    );
  }

  Widget _buildContent({
    required AdminEntityDefinition entity,
    required AdminEntityState state,
    required AdminEntityController controller,
  }) {
    if (state.status == AdminLoadStatus.loading && state.items.isEmpty) {
      return const LoadingState();
    }

    if (state.status == AdminLoadStatus.failure && state.items.isEmpty) {
      return ErrorState(
        message: state.errorMessage ?? 'Не удалось загрузить данные.',
        onRetry: controller.load,
      );
    }

    if (state.items.isEmpty) {
      return const EmptyState(message: 'Записи отсутствуют');
    }

    if (entity.key == 'banners') {
      return _buildBannersList(
        entity: entity,
        state: state,
        controller: controller,
      );
    }

    if (entity.key == 'partners') {
      return _buildPartnersList(
        entity: entity,
        state: state,
        controller: controller,
      );
    }

    if (entity.key == 'tuning') {
      return _buildTuningCards(
        entity: entity,
        state: state,
        controller: controller,
      );
    }

    return EntityTable<AdminEntityItem>(
      items: state.items,
      searchHint: 'Поиск',
      searchMatcher: (item, query) {
        if (entity.searchFields.isEmpty) {
          return item.values.values.any(
            (value) => _displayValue(value).toLowerCase().contains(query),
          );
        }
        return entity.searchFields.any((field) {
          return _displayValue(
            item.values[field],
          ).toLowerCase().contains(query);
        });
      },
      columns: [
        ...entity.listFields.map((field) {
          return DataColumnDefinition<AdminEntityItem>(
            label: field.label,
            sortValue: (item) => _sortValue(item.values[field.key]),
            cellBuilder: (item) => SizedBox(
              width: field.width,
              child: Text(
                _displayValue(item.values[field.key]),
                maxLines: field.type == AdminFieldType.multiline ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }),
        DataColumnDefinition<AdminEntityItem>(
          label: 'Действия',
          cellBuilder: (item) => SizedBox(
            width: 156,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Детали',
                  onPressed: () =>
                      _openDetailsDialog(entity, controller, item.id),
                  icon: const Icon(Icons.visibility_outlined),
                ),
                IconButton(
                  tooltip: 'Редактировать',
                  onPressed: () => _openEditDialog(entity, controller, item),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Удалить',
                  onPressed: () => _confirmDelete(entity, controller, item.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        ),
      ],
      toolbarWidgets: [
        if (state.errorMessage != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildBannersList({
    required AdminEntityDefinition entity,
    required AdminEntityState state,
    required AdminEntityController controller,
  }) {
    final query = _bannersSearchQuery.trim().toLowerCase();
    final filtered = state.items
        .where((item) {
          if (query.isEmpty) {
            return true;
          }
          final id = item.id.toString().toLowerCase();
          final title = _displayValue(item.values['title']).toLowerCase();
          final imageUrl = _displayValue(
            item.values['image_url'],
          ).toLowerCase();
          return id.contains(query) ||
              title.contains(query) ||
              imageUrl.contains(query);
        })
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 360,
              child: TextField(
                controller: _bannersSearchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Поиск по заголовку и URL',
                ),
                onChanged: (value) {
                  setState(() {
                    _bannersSearchQuery = value;
                  });
                },
              ),
            ),
            if (state.errorMessage != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const Expanded(
            child: EmptyState(message: 'По выбранным фильтрам записей нет'),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final title = _displayValue(item.values['title']);
                final imageUrlText = _displayValue(item.values['image_url']);
                final imageUrl = _normalizedUrl(item.values['image_url']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 940;

                        final actionButtons = Wrap(
                          spacing: 2,
                          runSpacing: 2,
                          children: [
                            IconButton(
                              tooltip: 'Детали',
                              onPressed: () => _openDetailsDialog(
                                entity,
                                controller,
                                item.id,
                              ),
                              icon: const Icon(Icons.visibility_outlined),
                            ),
                            IconButton(
                              tooltip: 'Редактировать',
                              onPressed: () =>
                                  _openEditDialog(entity, controller, item),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Удалить',
                              onPressed: () =>
                                  _confirmDelete(entity, controller, item.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        );

                        final infoBlock = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: compact ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Chip(
                                  label: Text('ID: ${item.id}'),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              imageUrlText,
                              maxLines: compact ? 3 : 2,
                            ),
                          ],
                        );

                        if (compact) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () =>
                                _openDetailsDialog(entity, controller, item.id),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 7,
                                  child: _BannerImagePreview(url: imageUrl),
                                ),
                                const SizedBox(height: 10),
                                infoBlock,
                                const SizedBox(height: 6),
                                actionButtons,
                              ],
                            ),
                          );
                        }

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () =>
                              _openDetailsDialog(entity, controller, item.id),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 280,
                                height: 130,
                                child: _BannerImagePreview(url: imageUrl),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: infoBlock),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 130,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: actionButtons,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPartnersList({
    required AdminEntityDefinition entity,
    required AdminEntityState state,
    required AdminEntityController controller,
  }) {
    final query = _partnersSearchQuery.trim().toLowerCase();
    final filtered = state.items
        .where((item) {
          if (query.isEmpty) {
            return true;
          }
          final logoUrl = _displayValue(item.values['logo_url']).toLowerCase();
          final id = item.id.toString().toLowerCase();
          return logoUrl.contains(query) || id.contains(query);
        })
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 340,
              child: TextField(
                controller: _partnersSearchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Поиск по ID или URL логотипа',
                ),
                onChanged: (value) {
                  setState(() {
                    _partnersSearchQuery = value;
                  });
                },
              ),
            ),
            if (state.errorMessage != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const Expanded(
            child: EmptyState(message: 'По выбранным фильтрам записей нет'),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final logoUrl = _normalizedUrl(item.values['logo_url']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 720;

                        final actionButtons = Wrap(
                          spacing: 2,
                          children: [
                            IconButton(
                              tooltip: 'Детали',
                              onPressed: () => _openDetailsDialog(
                                entity,
                                controller,
                                item.id,
                              ),
                              icon: const Icon(Icons.visibility_outlined),
                            ),
                            IconButton(
                              tooltip: 'Редактировать',
                              onPressed: () =>
                                  _openEditDialog(entity, controller, item),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Удалить',
                              onPressed: () =>
                                  _confirmDelete(entity, controller, item.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        );

                        final infoBlock = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ID: ${item.id}',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              _displayValue(item.values['logo_url']),
                              maxLines: compact ? 3 : 2,
                            ),
                          ],
                        );

                        if (compact) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () =>
                                _openDetailsDialog(entity, controller, item.id),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 90,
                                  child: _PartnerLogoPreview(url: logoUrl),
                                ),
                                const SizedBox(height: 10),
                                infoBlock,
                                const SizedBox(height: 6),
                                actionButtons,
                              ],
                            ),
                          );
                        }

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () =>
                              _openDetailsDialog(entity, controller, item.id),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 160,
                                height: 90,
                                child: _PartnerLogoPreview(url: logoUrl),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: infoBlock),
                              const SizedBox(width: 8),
                              actionButtons,
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTuningCards({
    required AdminEntityDefinition entity,
    required AdminEntityState state,
    required AdminEntityController controller,
  }) {
    final query = _tuningSearchQuery.trim().toLowerCase();
    final filtered = state.items
        .where((item) {
          if (query.isEmpty) {
            return true;
          }
          final title = _displayValue(item.values['title']).toLowerCase();
          final brand = _displayValue(item.values['brand']).toLowerCase();
          final model = _displayValue(item.values['model']).toLowerCase();
          final price = _displayValue(item.values['price']).toLowerCase();
          return title.contains(query) ||
              brand.contains(query) ||
              model.contains(query) ||
              price.contains(query);
        })
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: _tuningSearchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Поиск по бренду, модели, заголовку, цене',
                ),
                onChanged: (value) {
                  setState(() {
                    _tuningSearchQuery = value;
                  });
                },
              ),
            ),
            if (state.errorMessage != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const Expanded(
            child: EmptyState(message: 'По выбранным фильтрам записей нет'),
          )
        else
          Expanded(
            child: GridView.builder(
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final title = _displayValue(item.values['title']);
                final brand = _displayValue(item.values['brand']);
                final model = _displayValue(item.values['model']);
                final price = _displayValue(item.values['price']);
                final cardImageUrl = _normalizedUrl(
                  item.values['card_image_url'],
                );

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _openDetailsDialog(entity, controller, item.id),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 21 / 9,
                          child: _TuningCardImage(url: cardImageUrl),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$brand • $model',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Цена: $price',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'Редактировать',
                                      onPressed: () => _openEditDialog(
                                        entity,
                                        controller,
                                        item,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: 'Удалить',
                                      onPressed: () => _confirmDelete(
                                        entity,
                                        controller,
                                        item.id,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () => _openDetailsDialog(
                                        entity,
                                        controller,
                                        item.id,
                                      ),
                                      style: TextButton.styleFrom(
                                        minimumSize: const Size(0, 34),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Подробнее'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _openCreateDialog(
    AdminEntityDefinition entity,
    AdminEntityController controller,
  ) async {
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _EntityFormDialog(title: 'Создать запись', entity: entity),
    );
    if (payload == null) {
      return;
    }

    try {
      await controller.create(payload);
      _showMessage('Запись создана');
    } catch (_) {
      _showMessage('Не удалось создать запись');
    }
  }

  Future<void> _openEditDialog(
    AdminEntityDefinition entity,
    AdminEntityController controller,
    AdminEntityItem item,
  ) async {
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EntityFormDialog(
        title: 'Редактировать запись',
        entity: entity,
        initialValues: item.values,
      ),
    );
    if (payload == null) {
      return;
    }

    try {
      await controller.update(item.id, payload);
      _showMessage('Запись обновлена');
    } catch (_) {
      _showMessage('Не удалось обновить запись');
    }
  }

  Future<void> _confirmDelete(
    AdminEntityDefinition entity,
    AdminEntityController controller,
    dynamic id,
  ) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удаление записи'),
          content: Text('Удалить запись с ID: $id?'),
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

    if (approved != true) {
      return;
    }

    try {
      await controller.remove(id);
      _showMessage('Запись удалена');
    } catch (_) {
      _showMessage('Не удалось удалить запись');
    }
  }

  Future<void> _openDetailsDialog(
    AdminEntityDefinition entity,
    AdminEntityController controller,
    dynamic id,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Детали записи #$id'),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width < 820
                ? MediaQuery.sizeOf(context).width * 0.9
                : 720,
            child: FutureBuilder<AdminEntityItem>(
              future: controller.fetchDetails(id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Ошибка загрузки: ${snapshot.error}');
                }
                final item = snapshot.data;
                if (item == null) {
                  return const Text('Запись не найдена');
                }

                final sortedEntries = item.values.entries.toList()
                  ..sort((a, b) => a.key.compareTo(b.key));
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedEntries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                                const SizedBox(height: 4),
                                SelectableText(_displayValue(entry.value)),
                              ],
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                try {
                  final item = await controller.fetchDetails(id);
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                  await _openEditDialog(entity, controller, item);
                } catch (_) {
                  if (!mounted) {
                    return;
                  }
                  _showMessage(
                    'Не удалось загрузить запись для редактирования',
                  );
                }
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Редактировать'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  String _displayValue(dynamic value) {
    if (value == null) {
      return dashValue;
    }

    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? dashValue : trimmed;
    }

    if (value is List) {
      if (value.isEmpty) {
        return dashValue;
      }
      return value.map((item) => item.toString()).join(', ');
    }

    if (value is Map) {
      if (value.isEmpty) {
        return dashValue;
      }
      return const JsonEncoder.withIndent('  ').convert(value);
    }

    return value.toString();
  }

  Object? _sortValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num || value is DateTime) {
      return value;
    }
    return _displayValue(value);
  }

  String? _normalizedUrl(dynamic value) {
    if (value == null) {
      return null;
    }
    final normalized = value.toString().trim();
    if (normalized.isEmpty || normalized == dashValue) {
      return null;
    }
    return normalized;
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

class _TuningCardImage extends StatelessWidget {
  const _TuningCardImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return _buildFallback(context);
    }

    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallback(context);
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return _buildFallback(context, loading: true);
      },
    );
  }

  Widget _buildFallback(BuildContext context, {bool loading = false}) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: loading
            ? const CircularProgressIndicator(strokeWidth: 2)
            : const Icon(Icons.image_outlined, size: 40),
      ),
    );
  }
}

class _BannerImagePreview extends StatelessWidget {
  const _BannerImagePreview({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return _fallback(context);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _fallback(context, loading: true);
        },
      ),
    );
  }

  Widget _fallback(BuildContext context, {bool loading = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(strokeWidth: 2)
            : const Icon(Icons.image_not_supported_outlined, size: 28),
      ),
    );
  }
}

class _PartnerLogoPreview extends StatelessWidget {
  const _PartnerLogoPreview({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return _fallback(context);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _fallback(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _fallback(context, loading: true);
        },
      ),
    );
  }

  Widget _fallback(BuildContext context, {bool loading = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(strokeWidth: 2)
            : const Icon(Icons.image_not_supported_outlined, size: 28),
      ),
    );
  }
}

class _EntityFormDialog extends ConsumerStatefulWidget {
  const _EntityFormDialog({
    required this.title,
    required this.entity,
    this.initialValues,
  });

  final String title;
  final AdminEntityDefinition entity;
  final Map<String, dynamic>? initialValues;

  @override
  ConsumerState<_EntityFormDialog> createState() => _EntityFormDialogState();
}

class _EntityFormDialogState extends ConsumerState<_EntityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, List<TextEditingController>> _arrayControllers;
  final _arrayErrors = <String, String>{};

  @override
  void initState() {
    super.initState();
    _arrayControllers = {};
    _controllers = {
      for (final field in widget.entity.formFields)
        if (field.type != AdminFieldType.array)
          field.key: TextEditingController(
            text: _initialText(widget.initialValues?[field.key], field.type),
          ),
    };

    for (final field in widget.entity.formFields) {
      if (field.type == AdminFieldType.array) {
        final values = _initialArrayValues(widget.initialValues?[field.key]);
        _arrayControllers[field.key] = values
            .map((value) => TextEditingController(text: value))
            .toList(growable: true);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final list in _arrayControllers.values) {
      for (final controller in list) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width < 820
            ? MediaQuery.sizeOf(context).width * 0.9
            : 680,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.entity.formFields
                  .map((field) {
                    if (field.type == AdminFieldType.array) {
                      return _buildArrayManager(field);
                    }
                    return _buildTextField(field);
                  })
                  .toList(growable: false),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Сохранить')),
      ],
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _arrayErrors.clear();
    });

    var hasArrayError = false;
    for (final field in widget.entity.formFields) {
      if (field.type != AdminFieldType.array) {
        continue;
      }
      final values = _arrayControllers[field.key]!
          .map((controller) => controller.text.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      if (field.required && values.isEmpty) {
        _arrayErrors[field.key] = 'Добавьте минимум один URL';
        hasArrayError = true;
      }
    }

    if (hasArrayError) {
      setState(() {});
      return;
    }

    final result = <String, dynamic>{};
    for (final field in widget.entity.formFields) {
      if (field.type == AdminFieldType.array) {
        final values = _arrayControllers[field.key]!
            .map((controller) => controller.text.trim())
            .where((value) => value.isNotEmpty)
            .toList(growable: false);
        result[field.key] = values;
      } else {
        final raw = _controllers[field.key]!.text.trim();
        if (raw.isEmpty) {
          if (!field.nullable) {
            result[field.key] = '';
          } else {
            result[field.key] = null;
          }
          continue;
        }
        result[field.key] = _parseValue(field, raw);
      }
    }

    Navigator.of(context).pop(result);
  }

  String? _validateField(AdminFieldDefinition field, String? value) {
    final normalized = (value ?? '').trim();
    if (field.required && normalized.isEmpty) {
      return 'Обязательное поле';
    }

    if (normalized.isNotEmpty && field.type == AdminFieldType.number) {
      if (num.tryParse(normalized) == null) {
        return 'Введите число';
      }
    }

    if (normalized.isNotEmpty &&
        (field.type == AdminFieldType.array ||
            field.type == AdminFieldType.json)) {
      try {
        _parseValue(field, normalized);
      } catch (_) {
        return field.type == AdminFieldType.array
            ? 'Некорректный формат массива'
            : 'Некорректный JSON';
      }
    }

    return null;
  }

  Widget _buildTextField(AdminFieldDefinition field) {
    final controller = _controllers[field.key]!;
    final isLongText =
        field.type == AdminFieldType.multiline ||
        field.type == AdminFieldType.json;
    final uploadable = _isSingleUploadTarget(field);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            minLines: isLongText ? 2 : 1,
            maxLines: isLongText ? 6 : 1,
            decoration: InputDecoration(
              labelText: field.required ? '${field.label} *' : field.label,
              helperText: switch (field.type) {
                AdminFieldType.json => 'Введите JSON объект/массив',
                _ => null,
              },
            ),
            validator: (value) => _validateField(field, value),
          ),
          if (uploadable) ...[
            const SizedBox(height: 8),
            StorageUploadButton(
              label: 'Загрузить и вставить URL',
              folder: _suggestedFolder(field),
              onUploaded: (result) {
                controller.text = result.publicUrl;
                setState(() {});
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArrayManager(AdminFieldDefinition field) {
    final items = _arrayControllers[field.key]!;
    final uploadable = _isArrayUploadTarget(field);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  field.required ? '${field.label} *' : field.label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                OutlinedButton.icon(
                  onPressed: () => _addArrayItem(field.key),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить URL'),
                ),
                if (uploadable)
                  StorageUploadButton(
                    label: 'Загрузить и добавить',
                    folder: _suggestedFolder(field),
                    onUploaded: (result) {
                      _addArrayItem(field.key, initialValue: result.publicUrl);
                    },
                  ),
              ],
            ),
            if (_arrayErrors[field.key] != null) ...[
              const SizedBox(height: 6),
              Text(
                _arrayErrors[field.key]!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('Список пуст')
            else
              Column(
                children: List.generate(items.length, (index) {
                  final controller = items[index];
                  return Padding(
                    key: ValueKey('${field.key}-$index'),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'URL ${index + 1}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Вверх',
                          onPressed: index == 0
                              ? null
                              : () =>
                                    _moveArrayItem(field.key, index, index - 1),
                          icon: const Icon(Icons.arrow_upward_outlined),
                        ),
                        IconButton(
                          tooltip: 'Вниз',
                          onPressed: index == items.length - 1
                              ? null
                              : () =>
                                    _moveArrayItem(field.key, index, index + 1),
                          icon: const Icon(Icons.arrow_downward_outlined),
                        ),
                        IconButton(
                          tooltip: 'Удалить',
                          onPressed: () => _removeArrayItem(field.key, index),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  void _addArrayItem(String fieldKey, {String initialValue = ''}) {
    setState(() {
      _arrayControllers[fieldKey]!.add(
        TextEditingController(text: initialValue),
      );
      _arrayErrors.remove(fieldKey);
    });
  }

  void _removeArrayItem(String fieldKey, int index) {
    setState(() {
      final controller = _arrayControllers[fieldKey]!.removeAt(index);
      controller.dispose();
    });
  }

  void _moveArrayItem(String fieldKey, int from, int to) {
    setState(() {
      final items = _arrayControllers[fieldKey]!;
      final value = items.removeAt(from);
      items.insert(to, value);
    });
  }

  bool _isSingleUploadTarget(AdminFieldDefinition field) {
    final key = '${widget.entity.key}.${field.key}';
    return _singleUploadTargets.contains(key);
  }

  bool _isArrayUploadTarget(AdminFieldDefinition field) {
    final key = '${widget.entity.key}.${field.key}';
    return _arrayUploadTargets.contains(key);
  }

  String? _suggestedFolder(AdminFieldDefinition field) {
    final entityKey = widget.entity.key;
    final fieldKey = field.key;
    if (entityKey == 'banners') {
      return 'banners/home';
    }
    if (entityKey == 'partners') {
      return 'partners';
    }
    if (entityKey == 'portfolio_items') {
      return 'portfolio/items';
    }
    if (entityKey == 'tuning' && fieldKey == 'card_image_url') {
      return 'tuning/card';
    }
    if (entityKey == 'tuning' && fieldKey == 'full_image_url') {
      return 'tuning/full';
    }
    if (entityKey == 'service_offerings' && fieldKey == 'gallery_images') {
      return 'service_offerings/gallery';
    }
    if (entityKey == 'work_post' && fieldKey == 'gallery_images') {
      return 'work_post/gallery';
    }
    return entityKey;
  }

  dynamic _parseValue(AdminFieldDefinition field, String raw) {
    switch (field.type) {
      case AdminFieldType.number:
        final parsed = num.tryParse(raw);
        if (parsed == null) {
          return raw;
        }
        return parsed;
      case AdminFieldType.boolean:
        final normalized = raw.toLowerCase();
        if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
          return true;
        }
        if (normalized == 'false' || normalized == '0' || normalized == 'no') {
          return false;
        }
        return raw;
      case AdminFieldType.array:
        final parsedJson = _tryJsonDecode(raw);
        if (parsedJson is List) {
          return parsedJson;
        }
        return raw
            .split(RegExp(r'[\n,]'))
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      case AdminFieldType.json:
        final parsed = _tryJsonDecode(raw);
        return parsed ?? raw;
      case AdminFieldType.text:
      case AdminFieldType.multiline:
      case AdminFieldType.dateTime:
        return raw;
    }
  }

  dynamic _tryJsonDecode(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return null;
    }
  }

  String _initialText(dynamic value, AdminFieldType type) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value;
    }
    if (value is List || value is Map) {
      if (type == AdminFieldType.array || type == AdminFieldType.json) {
        return const JsonEncoder.withIndent('  ').convert(value);
      }
      return value.toString();
    }
    return value.toString();
  }

  List<String> _initialArrayValues(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    if (value is String) {
      final parsed = _tryJsonDecode(value);
      if (parsed is List) {
        return parsed.map((item) => item.toString()).toList(growable: false);
      }
      return value
          .split(RegExp(r'[\n,]'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }
}

const _singleUploadTargets = <String>{
  'banners.image_url',
  'partners.logo_url',
  'portfolio_items.image_url',
  'tuning.card_image_url',
};

const _arrayUploadTargets = <String>{
  'tuning.full_image_url',
  'service_offerings.gallery_images',
  'work_post.gallery_images',
};
