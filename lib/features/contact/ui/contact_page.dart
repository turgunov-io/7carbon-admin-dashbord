import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/request_state.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/ui/widgets/entity_table.dart';
import '../../../core/ui/widgets/formatters.dart';
import '../../../core/ui/widgets/read_only_actions.dart';
import '../../../core/ui/widgets/section_container.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../application/contact_providers.dart';
import '../models/contact_item.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ContactCubit(context.read<AppDependencies>().contactRepository)
            ..load(),
      child: const _ContactView(),
    );
  }
}

class _ContactView extends StatelessWidget {
  const _ContactView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ContactCubit>();

    return SectionContainer(
      title: 'Контакты',
      subtitle: 'Просмотр контактных данных в режиме чтения.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: cubit.load,
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить'),
        ),
      ],
      child: BlocBuilder<ContactCubit, RequestState<List<ContactItem>>>(
        builder: (context, state) {
          if (state.status == RequestStatus.loading && state.data == null) {
            return const LoadingState();
          }

          if (state.status == RequestStatus.failure && state.data == null) {
            return ErrorState(
              message: state.message ?? 'Не удалось загрузить контакты',
              onRetry: cubit.load,
            );
          }

          final items = state.data ?? const <ContactItem>[];
          if (items.isEmpty) {
            return const EmptyState(message: 'Список контактов пуст');
          }

          return EntityTable<ContactItem>(
            items: items,
            searchHint: 'Поиск по телефону, почте и адресу',
            searchMatcher: (item, query) {
              return textOrDash(
                    item.phoneNumber,
                  ).toLowerCase().contains(query) ||
                  textOrDash(item.email).toLowerCase().contains(query) ||
                  textOrDash(item.address).toLowerCase().contains(query);
            },
            columns: [
              DataColumnDefinition(
                label: 'ИД',
                sortValue: (item) => item.id,
                cellBuilder: (item) => Text(item.id.toString()),
              ),
              DataColumnDefinition(
                label: 'Телефон',
                sortValue: (item) => item.phoneNumber,
                cellBuilder: (item) => Text(textOrDash(item.phoneNumber)),
              ),
              DataColumnDefinition(
                label: 'Почта',
                sortValue: (item) => item.email,
                cellBuilder: (item) => Text(textOrDash(item.email)),
              ),
              DataColumnDefinition(
                label: 'Адрес',
                sortValue: (item) => item.address,
                cellBuilder: (item) => Text(textOrDash(item.address)),
              ),
              DataColumnDefinition(
                label: 'График работы',
                sortValue: (item) => item.workSchedule,
                cellBuilder: (item) => Text(textOrDash(item.workSchedule)),
              ),
              DataColumnDefinition(
                label: 'Описание',
                sortValue: (item) => item.description,
                cellBuilder: (item) => SizedBox(
                  width: 260,
                  child: Text(
                    textOrDash(item.description),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumnDefinition(
                label: 'Действия',
                cellBuilder: (_) => const ReadOnlyActionsCell(),
              ),
            ],
          );
        },
      ),
    );
  }
}
