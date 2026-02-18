import 'package:flutter/material.dart';

const _readOnlyLabel = 'нужен серверный метод';

class ReadOnlyActionsCell extends StatelessWidget {
  const ReadOnlyActionsCell({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;

    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Tooltip(
            message: _readOnlyLabel,
            child: IconButton(
              onPressed: null,
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
          Tooltip(
            message: _readOnlyLabel,
            child: IconButton(
              onPressed: null,
              icon: const Icon(Icons.delete_outline),
            ),
          ),
          Expanded(
            child: Text(
              _readOnlyLabel,
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
