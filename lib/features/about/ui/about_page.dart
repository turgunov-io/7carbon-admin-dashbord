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
import '../application/about_providers.dart';
import '../models/about_response.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AboutCubit(context.read<AppDependencies>().aboutRepository)..load(),
      child: const _AboutView(),
    );
  }
}

class _AboutView extends StatelessWidget {
  const _AboutView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AboutCubit>();

    return SectionContainer(
      title: 'О нас',
      subtitle: 'Страница о компании, метрики и секции.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: cubit.load,
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить'),
        ),
      ],
      child: BlocBuilder<AboutCubit, RequestState<AboutResponse>>(
        builder: (context, state) {
          if (state.status == RequestStatus.loading && state.data == null) {
            return const LoadingState();
          }

          if (state.status == RequestStatus.failure && state.data == null) {
            return ErrorState(
              message: state.message ?? 'Не удалось загрузить раздел О нас',
              onRetry: cubit.load,
            );
          }

          final data = state.data;
          if (data == null) {
            return const EmptyState(message: 'Раздел О нас пуст');
          }

          if (data.page == null &&
              data.metrics.isEmpty &&
              data.sections.isEmpty) {
            return const EmptyState(message: 'Раздел О нас пуст');
          }

          return ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Страница',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if (data.page == null)
                        const Text(dashValue)
                      else
                        Wrap(
                          spacing: 16,
                          runSpacing: 10,
                          children: [
                            _Info(label: 'ИД', value: data.page!.id.toString()),
                            _Info(
                              label: 'Заголовок',
                              value: textOrDash(data.page!.title),
                            ),
                            _Info(
                              label: 'Вступление',
                              value: textOrDash(data.page!.introDescription),
                              width: 340,
                            ),
                            _Info(
                              label: 'Миссия',
                              value: textOrDash(data.page!.missionDescription),
                              width: 340,
                            ),
                            _Info(
                              label: 'Ссылка на видео',
                              value: textOrDash(data.page!.videoUrl),
                              width: 340,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Изображение баннера'),
                                const SizedBox(height: 6),
                                ImagePreview(url: data.page!.bannerImageUrl),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Изображение миссии'),
                                const SizedBox(height: 6),
                                ImagePreview(url: data.page!.missionImageUrl),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Метрики', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (data.metrics.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Список метрик пуст'),
                  ),
                )
              else
                EntityTable<AboutMetric>(
                  items: data.metrics,
                  searchHint: 'Поиск по ключу, названию и значению',
                  searchMatcher: (item, query) {
                    return item.key.toLowerCase().contains(query) ||
                        item.label.toLowerCase().contains(query) ||
                        objectOrDash(item.value).toLowerCase().contains(query);
                  },
                  columns: [
                    DataColumnDefinition(
                      label: 'ИД',
                      sortValue: (item) => item.id,
                      cellBuilder: (item) => Text(item.id.toString()),
                    ),
                    DataColumnDefinition(
                      label: 'Ключ',
                      sortValue: (item) => item.key,
                      cellBuilder: (item) => Text(item.key),
                    ),
                    DataColumnDefinition(
                      label: 'Название',
                      sortValue: (item) => item.label,
                      cellBuilder: (item) => Text(item.label),
                    ),
                    DataColumnDefinition(
                      label: 'Значение',
                      sortValue: (item) => item.value,
                      cellBuilder: (item) => Text(objectOrDash(item.value)),
                    ),
                    DataColumnDefinition(
                      label: 'Позиция',
                      sortValue: (item) => item.position,
                      cellBuilder: (item) => Text(item.position.toString()),
                    ),
                    DataColumnDefinition(
                      label: 'Действия',
                      cellBuilder: (_) => const ReadOnlyActionsCell(),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Text('Секции', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (data.sections.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Список секций пуст'),
                  ),
                )
              else
                EntityTable<AboutSection>(
                  items: data.sections,
                  searchHint: 'Поиск по ключу, заголовку и описанию',
                  searchMatcher: (item, query) {
                    return item.key.toLowerCase().contains(query) ||
                        item.title.toLowerCase().contains(query) ||
                        item.description.toLowerCase().contains(query);
                  },
                  columns: [
                    DataColumnDefinition(
                      label: 'ИД',
                      sortValue: (item) => item.id,
                      cellBuilder: (item) => Text(item.id.toString()),
                    ),
                    DataColumnDefinition(
                      label: 'Ключ',
                      sortValue: (item) => item.key,
                      cellBuilder: (item) => Text(item.key),
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
                        width: 340,
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
                      cellBuilder: (item) => Text(item.position.toString()),
                    ),
                    DataColumnDefinition(
                      label: 'Действия',
                      cellBuilder: (_) => const ReadOnlyActionsCell(),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value, this.width = 220});

  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
