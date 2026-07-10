import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class AppTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;

  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Theme(
      data: theme.copyWith(
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(theme.colorScheme.secondaryContainer.withValues(alpha: 0.5)),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return theme.colorScheme.surfaceContainerLow;
            }
            return Colors.transparent;
          }),
          headingTextStyle: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
            letterSpacing: 0.5,
          ),
          dividerThickness: 1.0,
          horizontalMargin: AppSpacing.lg,
          columnSpacing: AppSpacing.lg,
        ),
      ),
      child: DataTable(
        columns: columns,
        rows: rows,
      ),
    );
  }
}
