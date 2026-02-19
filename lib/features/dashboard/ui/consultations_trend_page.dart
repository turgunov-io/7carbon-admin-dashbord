import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_route.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../application/dashboard_provider.dart';

class ConsultationsTrendPage extends ConsumerWidget {
  const ConsultationsTrendPage({super.key});

  static const _months = <String>[
    'янв',
    'фев',
    'мар',
    'апр',
    'май',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(dashboardConsultationTrendProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontal = width < 760 ? 12.0 : 20.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Статистика заявок на консультацию',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.dashboard),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Назад в дашборд'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Помесячная динамика за последние 12 месяцев',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: trendAsync.when(
                  loading: () => const LoadingState(),
                  error: (error, _) => ErrorState(
                    message: 'Не удалось загрузить данные: $error',
                    onRetry: () =>
                        ref.invalidate(dashboardConsultationTrendProvider),
                  ),
                  data: (trend) {
                    if (trend.monthlyPoints.isEmpty) {
                      return const EmptyState(
                        message: 'Нет данных по консультациям',
                      );
                    }

                    final isGrowth = trend.delta >= 0;
                    final deltaPrefix = isGrowth ? '+' : '';
                    final deltaColor = isGrowth
                        ? Colors.green.shade700
                        : Colors.red.shade700;

                    final maxCount = trend.monthlyPoints.fold<int>(1, (
                      max,
                      point,
                    ) {
                      return point.count > max ? point.count : max;
                    });

                    const barSlotWidth = 86.0;
                    final minChartWidth =
                        trend.monthlyPoints.length * barSlotWidth;
                    final chartWidth = math.max(
                      minChartWidth,
                      width - (horizontal * 2) - 28,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _StatChip(
                                  title: 'Текущий месяц',
                                  value: trend.currentMonthCount.toString(),
                                ),
                                _StatChip(
                                  title: 'Прошлый месяц',
                                  value: trend.previousMonthCount.toString(),
                                ),
                                _StatChip(
                                  title: 'Изменение',
                                  value: '$deltaPrefix${trend.delta}',
                                  valueColor: deltaColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                14,
                                12,
                                12,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: chartWidth,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      for (
                                        var index = 0;
                                        index < trend.monthlyPoints.length;
                                        index++
                                      )
                                        SizedBox(
                                          width: barSlotWidth,
                                          child: _DetailedMonthBar(
                                            label: _formatMonth(
                                              trend
                                                  .monthlyPoints[index]
                                                  .monthStartUtc,
                                            ),
                                            value: trend
                                                .monthlyPoints[index]
                                                .count,
                                            max: maxCount,
                                            isCurrent:
                                                index ==
                                                trend.monthlyPoints.length - 1,
                                            isPrevious:
                                                index ==
                                                trend.monthlyPoints.length - 2,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: SizedBox(
                            height: 180,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              itemBuilder: (context, index) {
                                final point = trend.monthlyPoints[index];
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatMonth(point.monthStartUtc)),
                                    Text(
                                      '${point.count}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 10),
                              itemCount: trend.monthlyPoints.length,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatMonth(DateTime monthStartUtc) {
    final monthIndex = monthStartUtc.month - 1;
    final month = _months[monthIndex];
    final year = monthStartUtc.year % 100;
    return '$month ${year.toString().padLeft(2, '0')}';
  }
}

class _DetailedMonthBar extends StatelessWidget {
  const _DetailedMonthBar({
    required this.label,
    required this.value,
    required this.max,
    required this.isCurrent,
    required this.isPrevious,
  });

  final String label;
  final int value;
  final int max;
  final bool isCurrent;
  final bool isPrevious;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = max == 0 ? 0.0 : value / max;
    final barHeight = value == 0 ? 12.0 : 12 + (180 * ratio.clamp(0.0, 1.0));
    final barColor = isCurrent
        ? theme.colorScheme.primary
        : isPrevious
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary.withValues(alpha: 0.35);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value.toString(),
            style: theme.textTheme.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 30,
                height: barHeight,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.title, required this.value, this.valueColor});

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
