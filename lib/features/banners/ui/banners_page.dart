import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/request_state.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/ui/widgets/entity_table.dart';
import '../../../core/ui/widgets/image_preview_gallery.dart';
import '../../../core/ui/widgets/read_only_actions.dart';
import '../../../core/ui/widgets/section_container.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../application/banners_providers.dart';
import '../models/banner_item.dart';

class BannersPage extends StatelessWidget {
  const BannersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BannersCubit(context.read<AppDependencies>().bannersRepository)
            ..load(),
      child: const _BannersView(),
    );
  }
}

class _BannersView extends StatelessWidget {
  const _BannersView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BannersCubit>();

    return SectionContainer(
      title: 'Баннеры',
      subtitle: 'Просмотр баннеров в режиме чтения.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: cubit.load,
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить'),
        ),
      ],
      child: BlocBuilder<BannersCubit, RequestState<List<BannerItem>>>(
        builder: (context, state) {
          if (state.status == RequestStatus.loading && state.data == null) {
            return const LoadingState();
          }

          if (state.status == RequestStatus.failure && state.data == null) {
            return ErrorState(
              message: state.message ?? 'Не удалось загрузить баннеры',
              onRetry: cubit.load,
            );
          }

          final items = state.data ?? const <BannerItem>[];
          if (items.isEmpty) {
            return const EmptyState(message: 'Список баннеров пуст');
          }

          return EntityTable<BannerItem>(
            items: items,
            searchHint: 'Поиск по секции и заголовку',
            searchMatcher: (item, query) {
              return item.section.toLowerCase().contains(query) ||
                  item.title.toLowerCase().contains(query);
            },
            columns: [
              DataColumnDefinition(
                label: 'ИД',
                sortValue: (item) => item.id,
                cellBuilder: (item) => Text(item.id.toString()),
              ),
              DataColumnDefinition(
                label: 'Секция',
                sortValue: (item) => item.section,
                cellBuilder: (item) => Text(item.section),
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
                label: 'Приоритет',
                sortValue: (item) => item.priority,
                numeric: true,
                cellBuilder: (item) => Text(item.priority.toString()),
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
