import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/request_state.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/ui/widgets/entity_table.dart';
import '../../../core/ui/widgets/formatters.dart';
import '../../../core/ui/widgets/section_container.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../application/consultations_providers.dart';
import '../models/consultation_create_request.dart';
import '../models/consultation_item.dart';
import '../models/consultation_status.dart';

class ConsultationsPage extends StatelessWidget {
  const ConsultationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConsultationsCubit(
        context.read<AppDependencies>().consultationsRepository,
      )..load(),
      child: const _ConsultationsView(),
    );
  }
}

class _ConsultationsView extends StatefulWidget {
  const _ConsultationsView();

  @override
  State<_ConsultationsView> createState() => _ConsultationsViewState();
}

class _ConsultationsViewState extends State<_ConsultationsView> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _carModelController = TextEditingController();
  final _preferredCallTimeController = TextEditingController();
  final _commentsController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _serviceTypeController.dispose();
    _carModelController.dispose();
    _preferredCallTimeController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConsultationsCubit>();

    return SectionContainer(
      title: 'Консультации',
      subtitle:
          'Список заявок и форма создания. Редактирование записей работает локально.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: cubit.load,
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить'),
        ),
      ],
      child: BlocBuilder<ConsultationsCubit, ConsultationsState>(
        builder: (context, state) {
          final tableWidget = _buildTable(state, cubit);
          final formCard = _buildFormCard(state, cubit);

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 1200) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: tableWidget),
                    const SizedBox(width: 16),
                    SizedBox(width: 400, child: formCard),
                  ],
                );
              }

              return ListView(
                children: [formCard, const SizedBox(height: 12), tableWidget],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTable(ConsultationsState state, ConsultationsCubit cubit) {
    if (state.listStatus == RequestStatus.loading && state.items.isEmpty) {
      return const LoadingState();
    }

    if (state.listStatus == RequestStatus.failure && state.items.isEmpty) {
      return ErrorState(
        message: state.listError ?? 'Не удалось загрузить консультации',
        onRetry: cubit.load,
      );
    }

    if (state.items.isEmpty) {
      return const EmptyState(message: 'Список консультаций пуст');
    }

    return EntityTable<ConsultationItem>(
      items: state.items,
      searchHint: 'Поиск по имени, телефону и услуге',
      toolbarWidgets: [
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<ConsultationStatus?>(
            key: ValueKey(state.filter),
            initialValue: state.filter,
            decoration: const InputDecoration(labelText: 'Фильтр по статусу'),
            items: [
              const DropdownMenuItem<ConsultationStatus?>(
                value: null,
                child: Text('Все статусы'),
              ),
              ...ConsultationStatus.values.map(
                (status) => DropdownMenuItem<ConsultationStatus?>(
                  value: status,
                  child: Text(status.label),
                ),
              ),
            ],
            onChanged: cubit.setFilter,
          ),
        ),
      ],
      searchMatcher: (item, query) {
        final fullName = '${item.firstName} ${item.lastName}'.toLowerCase();
        return fullName.contains(query) ||
            item.phone.toLowerCase().contains(query) ||
            item.serviceType.toLowerCase().contains(query) ||
            textOrDash(item.carModel).toLowerCase().contains(query);
      },
      columns: [
        DataColumnDefinition(
          label: 'ИД',
          sortValue: (item) => item.id,
          cellBuilder: (item) => Text(item.id.toString()),
        ),
        DataColumnDefinition(
          label: 'Клиент',
          sortValue: (item) => '${item.firstName} ${item.lastName}',
          cellBuilder: (item) => Text('${item.firstName} ${item.lastName}'),
        ),
        DataColumnDefinition(
          label: 'Телефон',
          sortValue: (item) => item.phone,
          cellBuilder: (item) => Text(item.phone),
        ),
        DataColumnDefinition(
          label: 'Услуга',
          sortValue: (item) => item.serviceType,
          cellBuilder: (item) => Text(item.serviceType),
        ),
        DataColumnDefinition(
          label: 'Модель авто',
          sortValue: (item) => item.carModel,
          cellBuilder: (item) => Text(textOrDash(item.carModel)),
        ),
        DataColumnDefinition(
          label: 'Удобное время звонка',
          sortValue: (item) => item.preferredCallTime,
          cellBuilder: (item) => Text(textOrDash(item.preferredCallTime)),
        ),
        DataColumnDefinition(
          label: 'Комментарии',
          sortValue: (item) => item.comments,
          cellBuilder: (item) => SizedBox(
            width: 240,
            child: Text(
              textOrDash(item.comments),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataColumnDefinition(
          label: 'Статус',
          sortValue: (item) => item.status.label,
          cellBuilder: (item) => _StatusChip(status: item.status),
        ),
        DataColumnDefinition(
          label: 'Создана',
          sortValue: (item) => item.createdAt,
          cellBuilder: (item) => Text(formatDateTimeOrDash(item.createdAt)),
        ),
        DataColumnDefinition(
          label: 'Действия',
          cellBuilder: (item) => IconButton(
            tooltip: 'Редактировать',
            onPressed: () => _openEditDialog(cubit, item),
            icon: const Icon(Icons.edit_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(ConsultationsState state, ConsultationsCubit cubit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Создать консультацию',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Имя *'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Фамилия *'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Телефон *'),
                validator: _phoneValidator,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _serviceTypeController,
                decoration: const InputDecoration(labelText: 'Тип услуги *'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _carModelController,
                decoration: const InputDecoration(labelText: 'Модель авто'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _preferredCallTimeController,
                decoration: const InputDecoration(
                  labelText: 'Удобное время звонка',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _commentsController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Комментарии'),
              ),
              if (state.createError != null) ...[
                const SizedBox(height: 10),
                Text(
                  state.createError!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: state.creating ? null : () => _submit(cubit),
                icon: state.creating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: const Text('Создать'),
              ),
              const SizedBox(height: 8),
              Text(
                'Ошибки сервера 400/422 будут показаны выше.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Обязательное поле';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Обязательное поле';
    }

    final phone = value.trim();
    final regex = RegExp(r'^[+0-9()\-\s]{6,24}$');
    if (!regex.hasMatch(phone)) {
      return 'Неверный формат телефона';
    }

    return null;
  }

  Future<void> _submit(ConsultationsCubit cubit) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = ConsultationCreateRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      serviceType: _serviceTypeController.text.trim(),
      carModel: _nullable(_carModelController.text),
      preferredCallTime: _nullable(_preferredCallTimeController.text),
      comments: _nullable(_commentsController.text),
    );

    final created = await cubit.createConsultation(request);
    if (!created || !mounted) {
      return;
    }

    _firstNameController.clear();
    _lastNameController.clear();
    _phoneController.clear();
    _serviceTypeController.clear();
    _carModelController.clear();
    _preferredCallTimeController.clear();
    _commentsController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Консультация создана')));
  }

  Future<void> _openEditDialog(
    ConsultationsCubit cubit,
    ConsultationItem existing,
  ) async {
    final firstNameController = TextEditingController(text: existing.firstName);
    final lastNameController = TextEditingController(text: existing.lastName);
    final phoneController = TextEditingController(text: existing.phone);
    final serviceTypeController = TextEditingController(
      text: existing.serviceType,
    );
    final carModelController = TextEditingController(
      text: existing.carModel ?? '',
    );
    final preferredCallTimeController = TextEditingController(
      text: existing.preferredCallTime ?? '',
    );
    final commentsController = TextEditingController(
      text: existing.comments ?? '',
    );
    var selectedStatus = existing.status;
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Редактирование консультации'),
              content: SizedBox(
                width: 540,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: firstNameController,
                          decoration: const InputDecoration(labelText: 'Имя *'),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Фамилия *',
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Телефон *',
                          ),
                          validator: _phoneValidator,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: serviceTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Тип услуги *',
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: carModelController,
                          decoration: const InputDecoration(
                            labelText: 'Модель авто',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: preferredCallTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Удобное время звонка',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: commentsController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Комментарии',
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<ConsultationStatus>(
                          initialValue: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Статус',
                          ),
                          items: ConsultationStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.label),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setDialogState(() {
                              selectedStatus = value;
                            });
                          },
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
      },
    );

    if (saved == true) {
      final updated = ConsultationItem(
        id: existing.id,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        serviceType: serviceTypeController.text.trim(),
        carModel: _nullable(carModelController.text),
        preferredCallTime: _nullable(preferredCallTimeController.text),
        comments: _nullable(commentsController.text),
        status: selectedStatus,
        createdAt: existing.createdAt,
      );
      cubit.updateLocal(updated);
      _showMessage('Запись обновлена локально');
    }

    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    serviceTypeController.dispose();
    carModelController.dispose();
    preferredCallTimeController.dispose();
    commentsController.dispose();
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ConsultationStatus status;

  @override
  Widget build(BuildContext context) {
    final background = switch (status) {
      ConsultationStatus.newRequest => Colors.amber.shade100,
      ConsultationStatus.inProgress => Colors.blue.shade100,
      ConsultationStatus.completed => Colors.green.shade100,
    };

    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(status.label),
      backgroundColor: background,
    );
  }
}
