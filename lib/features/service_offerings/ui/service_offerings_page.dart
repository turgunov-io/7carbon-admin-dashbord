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
import '../application/service_offerings_providers.dart';
import '../models/service_offering_item.dart';

class ServiceOfferingsPage extends StatelessWidget {
  const ServiceOfferingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceOfferingsCubit(
        context.read<AppDependencies>().serviceOfferingsRepository,
      )..load(),
      child: const _ServiceOfferingsView(),
    );
  }
}

class _ServiceOfferingsView extends StatelessWidget {
  const _ServiceOfferingsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ServiceOfferingsCubit>();

    return SectionContainer(
      title: 'Услуги',
      subtitle: 'Просмотр услуг в режиме чтения.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: cubit.load,
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить'),
        ),
      ],
      child:
          BlocBuilder<
            ServiceOfferingsCubit,
            RequestState<List<ServiceOfferingItem>>
          >(
            builder: (context, state) {
              if (state.status == RequestStatus.loading && state.data == null) {
                return const LoadingState();
              }

              if (state.status == RequestStatus.failure && state.data == null) {
                return ErrorState(
                  message: state.message ?? 'Не удалось загрузить услуги',
                  onRetry: cubit.load,
                );
              }

              final items = state.data ?? const <ServiceOfferingItem>[];
              if (items.isEmpty) {
                return const EmptyState(message: 'Список услуг пуст');
              }

              return EntityTable<ServiceOfferingItem>(
                items: items,
                searchHint: 'Поиск по типу услуги и заголовку',
                searchMatcher: (item, query) {
                  return textOrDash(
                        item.serviceType,
                      ).toLowerCase().contains(query) ||
                      textOrDash(item.title).toLowerCase().contains(query);
                },
                columns: [
                  DataColumnDefinition(
                    label: 'ИД',
                    sortValue: (item) => item.id,
                    cellBuilder: (item) => Text(item.id.toString()),
                  ),
                  DataColumnDefinition(
                    label: 'Тип услуги',
                    sortValue: (item) => item.serviceType,
                    cellBuilder: (item) => Text(textOrDash(item.serviceType)),
                  ),
                  DataColumnDefinition(
                    label: 'Заголовок',
                    sortValue: (item) => item.title,
                    cellBuilder: (item) => Text(textOrDash(item.title)),
                  ),
                  DataColumnDefinition(
                    label: 'Описание',
                    sortValue: (item) => item.detailedDescription,
                    cellBuilder: (item) => SizedBox(
                      width: 280,
                      child: Text(
                        textOrDash(item.detailedDescription),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataColumnDefinition(
                    label: 'Галерея',
                    cellBuilder: (item) =>
                        ImagePreviewGallery(urls: item.galleryImages),
                  ),
                  DataColumnDefinition(
                    label: 'Цена',
                    sortValue: (item) => item.priceText,
                    cellBuilder: (item) => Text(textOrDash(item.priceText)),
                  ),
                  DataColumnDefinition(
                    label: 'Позиция',
                    sortValue: (item) => item.position,
                    numeric: true,
                    cellBuilder: (item) => Text(item.position.toString()),
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
