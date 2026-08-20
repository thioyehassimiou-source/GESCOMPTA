import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables/expenses.dart';
import '../data/repositories/drift_expense_repository.dart';

export '../../../../core/database/tables/expenses.dart' show ExpenseCategory, ExpenseCategoryX;

class ExpensesData {
  const ExpensesData({
    required this.totalAmount,
    required this.thisMonthAmount,
    required this.categoryAmounts,
    required this.expenses,
  });

  final int totalAmount;
  final int thisMonthAmount;
  final Map<ExpenseCategory, int> categoryAmounts;
  final List<Expense> expenses;
}

final expensesDataProvider = FutureProvider<ExpensesData>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  final expenses = await repo.getAllExpenses();

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);

  int totalAmount = 0;
  int thisMonthAmount = 0;
  final categoryAmounts = <ExpenseCategory, int>{};

  for (final cat in ExpenseCategory.values) {
    categoryAmounts[cat] = 0;
  }

  for (final e in expenses) {
    totalAmount += e.amount;
    
    if (e.date.isAfter(startOfMonth) || e.date.isAtSameMomentAs(startOfMonth)) {
      thisMonthAmount += e.amount;
      categoryAmounts[e.category] = (categoryAmounts[e.category] ?? 0) + e.amount;
    }
  }

  return ExpensesData(
    totalAmount: totalAmount,
    thisMonthAmount: thisMonthAmount,
    categoryAmounts: categoryAmounts,
    expenses: expenses,
  );
});
