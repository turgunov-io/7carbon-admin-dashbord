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
            width: 720,
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

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EntityFormDialog extends StatefulWidget {
  const _EntityFormDialog({
    required this.title,
    required this.entity,
    this.initialValues,
  });

  final String title;
  final AdminEntityDefinition entity;
  final Map<String, dynamic>? initialValues;

  @override
  State<_EntityFormDialog> createState() => _EntityFormDialogState();
}

class _EntityFormDialogState extends State<_EntityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget.entity.formFields)
        field.key: TextEditingController(
          text: _initialText(widget.initialValues?[field.key], field.type),
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 680,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.entity.formFields
                  .map((field) {
                    final controller = _controllers[field.key]!;
                    final isLongText =
                        field.type == AdminFieldType.multiline ||
                        field.type == AdminFieldType.array ||
                        field.type == AdminFieldType.json;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        controller: controller,
                        minLines: isLongText ? 2 : 1,
                        maxLines: isLongText ? 6 : 1,
                        decoration: InputDecoration(
                          labelText: field.required
                              ? '${field.label} *'
                              : field.label,
                          helperText: switch (field.type) {
                            AdminFieldType.array =>
                              'Введите JSON массив или значения по строкам',
                            AdminFieldType.json => 'Введите JSON объект/массив',
                            _ => null,
                          },
                        ),
                        validator: (value) => _validateField(field, value),
                      ),
                    );
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

    final result = <String, dynamic>{};
    for (final field in widget.entity.formFields) {
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
}
