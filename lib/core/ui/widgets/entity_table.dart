import 'dart:async';

import 'package:flutter/material.dart';

typedef SearchMatcher<T> = bool Function(T item, String query);

class DataColumnDefinition<T> {
  const DataColumnDefinition({
    required this.label,
    required this.cellBuilder,
    this.sortValue,
    this.numeric = false,
  });

  final String label;
  final Widget Function(T item) cellBuilder;
  final Object? Function(T item)? sortValue;
  final bool numeric;
}

class EntityTable<T> extends StatefulWidget {
  const EntityTable({
    required this.items,
    required this.columns,
    this.searchHint = 'Поиск',
    this.searchMatcher,
    this.showSearch = true,
    this.toolbarWidgets = const <Widget>[],
    super.key,
  });

  final List<T> items;
  final List<DataColumnDefinition<T>> columns;
  final String searchHint;
  final SearchMatcher<T>? searchMatcher;
  final bool showSearch;
  final List<Widget> toolbarWidgets;

  @override
  State<EntityTable<T>> createState() => _EntityTableState<T>();
}

class _EntityTableState<T> extends State<EntityTable<T>> {
  static const _searchDebounce = Duration(milliseconds: 250);

  final TextEditingController _searchController = TextEditingController();
  late final _EntityTableSource<T> _source;

  Timer? _debounce;
  String _query = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  /// Result of filter + sort. Recomputed only when the inputs actually change,
  /// never on an unrelated rebuild (theme change, parent repaint, resize).
  List<T> _visibleItems = const [];

  final int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _visibleItems = _computeVisibleItems();
    _source = _EntityTableSource<T>(
      items: _visibleItems,
      columns: widget.columns,
    );
  }

  @override
  void didUpdateWidget(covariant EntityTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.items, widget.items) ||
        !identical(oldWidget.columns, widget.columns) ||
        oldWidget.searchMatcher != widget.searchMatcher) {
      _refreshVisibleItems();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _source.dispose();
    super.dispose();
  }

  /// Recomputes the filtered/sorted view and pushes it into the existing
  /// [DataTableSource] instead of allocating a new one on every build.
  void _refreshVisibleItems() {
    _visibleItems = _computeVisibleItems();
    _source.updateData(items: _visibleItems, columns: widget.columns);
  }

  List<T> _computeVisibleItems() {
    final query = _query.trim().toLowerCase();
    final matcher = widget.searchMatcher;
    final needsSort =
        _sortColumnIndex != null &&
        _sortColumnIndex! < widget.columns.length &&
        widget.columns[_sortColumnIndex!].sortValue != null;

    // Nothing to filter or sort: hand back the source list, no copy.
    if (query.isEmpty && !needsSort) {
      return widget.items;
    }

    final result = query.isEmpty
        ? List<T>.of(widget.items)
        : widget.items.where((item) {
            if (matcher != null) {
              return matcher(item, query);
            }
            return item.toString().toLowerCase().contains(query);
          }).toList();

    if (!needsSort) {
      return result;
    }

    // Decorate-sort-undecorate: sortValue runs once per item rather than
    // O(n log n) times from inside the comparator.
    final sortValue = widget.columns[_sortColumnIndex!].sortValue!;
    final keyed = List<_SortEntry<T>>.generate(
      result.length,
      (index) => _SortEntry<T>(result[index], sortValue(result[index])),
      growable: false,
    );
    keyed.sort((a, b) {
      final comparison = _compare(a.key, b.key);
      return _sortAscending ? comparison : -comparison;
    });
    return List<T>.generate(
      keyed.length,
      (index) => keyed[index].item,
      growable: false,
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      if (!mounted || value == _query) {
        return;
      }
      setState(() {
        _query = value;
        _refreshVisibleItems();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredCount = _visibleItems.length;
    final availableRowsPerPage = _buildRowsPerPageOptions(filteredCount);
    final rowsPerPage = _normalizedRowsPerPage(
      current: _rowsPerPage,
      options: availableRowsPerPage,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final compact = maxWidth < 760;
            final searchWidth = compact
                ? (maxWidth - 24).clamp(220.0, 420.0).toDouble()
                : 320.0;
            final showToolbar =
                widget.showSearch || widget.toolbarWidgets.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showToolbar) ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (widget.showSearch)
                        SizedBox(
                          width: searchWidth,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: widget.searchHint,
                            ),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                      ...widget.toolbarWidgets,
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                if (filteredCount == 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Записи не найдены')),
                  )
                else
                  _buildDataTable(
                    maxWidth: maxWidth,
                    filteredCount: filteredCount,
                    rowsPerPage: rowsPerPage,
                    availableRowsPerPage: availableRowsPerPage,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDataTable({
    required double maxWidth,
    required int filteredCount,
    required int rowsPerPage,
    required List<int> availableRowsPerPage,
  }) {
    final estimatedTableWidth = widget.columns.length * 180.0;
    final tableWidth = estimatedTableWidth > maxWidth
        ? estimatedTableWidth
        : maxWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: tableWidth, maxWidth: tableWidth),
        child: PaginatedDataTable(
          header: Text('Всего: $filteredCount'),
          columns: List.generate(widget.columns.length, (index) {
            final column = widget.columns[index];
            return DataColumn(
              label: Text(column.label),
              numeric: column.numeric,
              onSort: column.sortValue == null
                  ? null
                  : (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                        _refreshVisibleItems();
                      });
                    },
            );
          }, growable: false),
          source: _source,
          rowsPerPage: rowsPerPage,
          availableRowsPerPage: availableRowsPerPage,
          onRowsPerPageChanged: null,
          showFirstLastButtons: true,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingRowHeight: 48,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 92,
        ),
      ),
    );
  }

  int _compare(Object? left, Object? right) {
    if (left == null && right == null) {
      return 0;
    }
    if (left == null) {
      return 1;
    }
    if (right == null) {
      return -1;
    }

    if (left is num && right is num) {
      return left.compareTo(right);
    }

    if (left is DateTime && right is DateTime) {
      return left.compareTo(right);
    }

    return left.toString().compareTo(right.toString());
  }

  List<int> _buildRowsPerPageOptions(int total) {
    if (total <= 0) {
      return const [1];
    }

    final defaults = <int>[5, 10, 20, 50];
    final options = defaults.where((value) => value < total).toList()
      ..add(total);
    return options.toSet().toList()..sort();
  }

  int _normalizedRowsPerPage({
    required int current,
    required List<int> options,
  }) {
    if (options.contains(current)) {
      return current;
    }

    final candidates = options.where((value) => value <= current).toList();
    if (candidates.isNotEmpty) {
      return candidates.last;
    }
    return options.first;
  }
}

class _SortEntry<T> {
  const _SortEntry(this.item, this.key);

  final T item;
  final Object? key;
}

class _EntityTableSource<T> extends DataTableSource {
  _EntityTableSource({required this.items, required this.columns});

  List<T> items;
  List<DataColumnDefinition<T>> columns;

  void updateData({
    required List<T> items,
    required List<DataColumnDefinition<T>> columns,
  }) {
    this.items = items;
    this.columns = columns;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= items.length) {
      return null;
    }

    final item = items[index];
    return DataRow.byIndex(
      index: index,
      cells: columns
          .map((column) => DataCell(column.cellBuilder(item)))
          .toList(growable: false),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => items.length;

  @override
  int get selectedRowCount => 0;
}
