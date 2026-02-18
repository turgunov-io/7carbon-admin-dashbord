import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/request_state.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/ui/widgets/entity_table.dart';
import '../../../core/ui/widgets/read_only_actions.dart';
import '../../../core/ui/widgets/section_container.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../application/privacy_sections_providers.dart';
import '../models/privacy_section_item.dart';

class PrivacySectionsPage extends StatelessWidget {
  const PrivacySectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PrivacySectionsCubit(
        context.read<AppDependencies>().privacySectionsRepository,
      )..load(),
      child: const _PrivacySectionsView(),
    );
  }
}

class _PrivacySectionsView extends StatelessWidget {
  const _PrivacySectionsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PrivacySectionsCubit>();

    return SectionContainer(
      title: 'Политика конфиденциальности',
      subtitle: 'Просмотр секций политики в режиме чтения.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: cubit.load,
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить'),
        ),
      ],
      child:
          BlocBuilder<
            PrivacySectionsCubit,
            RequestState<List<PrivacySectionItem>>
          >(
            builder: (context, state) {
              if (state.status == RequestStatus.loading && state.data == null) {
                return const LoadingState();
              }

              if (state.status == RequestStatus.failure && state.data == null) {
                return ErrorState(
                  message:
                      state.message ?? 'Не удалось загрузить секции политики',
                  onRetry: cubit.load,
                );
              }

              final items = state.data ?? const <PrivacySectionItem>[];
              if (items.isEmpty) {
                return const EmptyState(message: 'Список секций политики пуст');
              }

              return EntityTable<PrivacySectionItem>(
                items: items,
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
                    label: 'Описание',
                    sortValue: (item) => item.description,
                    cellBuilder: (item) => SizedBox(
                      width: 380,
                      child: Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataColumnDefinition(
                    label: 'Позиция',
                    sortValue: (item) => item.position,
                    numeric: true,
                    cellBuilder: (item) => Text(item.position.toString()),
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
