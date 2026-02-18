import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/request_state.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/ui/widgets/entity_table.dart';
import '../../../core/ui/widgets/image_preview_gallery.dart';
import '../../../core/ui/widgets/read_only_actions.dart';
import '../../../core/ui/widgets/section_container.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../application/partners_providers.dart';
import '../models/partner_item.dart';

class PartnersPage extends StatelessWidget {
  const PartnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PartnersCubit(context.read<AppDependencies>().partnersRepository)
            ..load(),
      child: const _PartnersView(),
    );
  }
}

class _PartnersView extends StatelessWidget {
  const _PartnersView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PartnersCubit>();

    return SectionContainer(
      title: 'Партнеры',
      subtitle: 'Просмотр партнеров в режиме чтения.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: cubit.load,
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить'),
        ),
      ],
      child: BlocBuilder<PartnersCubit, RequestState<List<PartnerItem>>>(
        builder: (context, state) {
          if (state.status == RequestStatus.loading && state.data == null) {
            return const LoadingState();
          }

          if (state.status == RequestStatus.failure && state.data == null) {
            return ErrorState(
              message: state.message ?? 'Не удалось загрузить партнеров',
              onRetry: cubit.load,
            );
          }

          final items = state.data ?? const <PartnerItem>[];
          if (items.isEmpty) {
            return const EmptyState(message: 'Список партнеров пуст');
          }

          return EntityTable<PartnerItem>(
            items: items,
            searchHint: 'Поиск по идентификатору и ссылке логотипа',
            searchMatcher: (item, query) {
              return item.id.toString().contains(query) ||
                  item.logoUrl.toLowerCase().contains(query);
            },
            columns: [
              DataColumnDefinition(
                label: 'ИД',
                sortValue: (item) => item.id,
                cellBuilder: (item) => Text(item.id.toString()),
              ),
              DataColumnDefinition(
                label: 'Логотип',
                cellBuilder: (item) => ImagePreview(url: item.logoUrl),
              ),
              DataColumnDefinition(
                label: 'Ссылка логотипа',
                sortValue: (item) => item.logoUrl,
                cellBuilder: (item) => SizedBox(
                  width: 280,
                  child: Text(
                    item.logoUrl,
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
