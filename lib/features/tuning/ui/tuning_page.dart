import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/request_state.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/ui/widgets/entity_table.dart';
import '../../../core/ui/widgets/formatters.dart';
import '../../../core/ui/widgets/image_preview_gallery.dart';
import '../../../core/ui/widgets/read_only_actions.dart';
import '../../../core/ui/widgets/section_container.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../application/tuning_providers.dart';
import '../models/tuning_item.dart';

class TuningPage extends StatelessWidget {
  const TuningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TuningCubit(context.read<AppDependencies>().tuningRepository)..load(),
      child: const _TuningView(),
    );
  }
}

class _TuningView extends StatelessWidget {
  const _TuningView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TuningCubit>();

    return SectionContainer(
      title: 'Тюнинг',
      subtitle: 'Просмотр тюнинга в режиме чтения.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: cubit.load,
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить'),
        ),
      ],
      child: BlocBuilder<TuningCubit, RequestState<List<TuningItem>>>(
        builder: (context, state) {
          if (state.status == RequestStatus.loading && state.data == null) {
            return const LoadingState();
          }

          if (state.status == RequestStatus.failure && state.data == null) {
            return ErrorState(
              message: state.message ?? 'Не удалось загрузить тюнинг',
              onRetry: cubit.load,
            );
          }

          final items = state.data ?? const <TuningItem>[];
          if (items.isEmpty) {
            return const EmptyState(message: 'Список тюнинга пуст');
          }

          return EntityTable<TuningItem>(
            items: items,
            searchHint: 'Поиск по бренду, модели и заголовку',
            searchMatcher: (item, query) {
              return textOrDash(item.brand).toLowerCase().contains(query) ||
                  textOrDash(item.carModel).toLowerCase().contains(query) ||
                  textOrDash(item.title).toLowerCase().contains(query);
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
                label: 'Модель',
                sortValue: (item) => item.carModel,
                cellBuilder: (item) => Text(textOrDash(item.carModel)),
              ),
              DataColumnDefinition(
                label: 'Заголовок',
                sortValue: (item) => item.title,
                cellBuilder: (item) => Text(textOrDash(item.title)),
              ),
              DataColumnDefinition(
                label: 'Изображение карточки',
                cellBuilder: (item) => ImagePreview(url: item.cardImageUrl),
              ),
              DataColumnDefinition(
                label: 'Галерея',
                cellBuilder: (item) =>
                    ImagePreviewGallery(urls: item.fullImageUrl),
              ),
              DataColumnDefinition(
                label: 'Цена',
                sortValue: (item) => item.price,
                cellBuilder: (item) => Text(objectOrDash(item.price)),
              ),
              DataColumnDefinition(
                label: 'Описание карточки',
                sortValue: (item) => item.cardDescription,
                cellBuilder: (item) => SizedBox(
                  width: 250,
                  child: Text(
                    textOrDash(item.cardDescription),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumnDefinition(
                label: 'Изображение видео',
                cellBuilder: (item) => ImagePreview(url: item.videoImageUrl),
              ),
              DataColumnDefinition(
                label: 'Ссылка на видео',
                sortValue: (item) => item.videoLink,
                cellBuilder: (item) => SizedBox(
                  width: 220,
                  child: Text(
                    textOrDash(item.videoLink),
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
                label: 'Обновлено',
                sortValue: (item) => item.updatedAt,
                cellBuilder: (item) =>
                    Text(formatDateTimeOrDash(item.updatedAt)),
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
