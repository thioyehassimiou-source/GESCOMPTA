import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../data/repositories/drift_business_summary_repository.dart';
import '../domain/entities/business_summary.dart';
import '../domain/repositories/business_summary_repository.dart';

/// Câblage Riverpod du résumé « Mon commerce ».

final businessSummaryRepositoryProvider = Provider<BusinessSummaryRepository>(
  (ref) => DriftBusinessSummaryRepository(ref.watch(databaseProvider)),
);

final businessSummaryProvider = FutureProvider<BusinessSummary>(
  (ref) => ref.watch(businessSummaryRepositoryProvider).load(DateTime.now()),
);
