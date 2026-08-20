import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../data/repositories/drift_order_repository.dart';

export '../data/repositories/drift_order_repository.dart'
    show OrderStatus, OrderStatusX, DeliveryType, DeliveryTypeX, OrderLine, DriftOrderRepository;

/// Stream de toutes les commandes — réactif.
final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(orderRepositoryProvider).watchAllOrders();
});

class OrderSummary {
  const OrderSummary({
    required this.totalToday,
    required this.pending,
    required this.preparing,
    required this.ready,
    required this.delivered,
  });

  final int totalToday;
  final int pending;
  final int preparing;
  final int ready;
  final int delivered;
}

/// Agrégation des KPIs des commandes pour l'en-tête.
final orderSummaryProvider = Provider<OrderSummary>((ref) {
  final ordersAsync = ref.watch(ordersStreamProvider);
  return ordersAsync.when(
    loading: () => const OrderSummary(totalToday: 0, pending: 0, preparing: 0, ready: 0, delivered: 0),
    error: (e, st) => const OrderSummary(totalToday: 0, pending: 0, preparing: 0, ready: 0, delivered: 0),
    data: (orders) {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final todayOrders = orders.where((o) => o.createdAt.isAfter(startOfDay)).toList();

      return OrderSummary(
        totalToday: todayOrders.length,
        pending: orders.where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.confirmed).length,
        preparing: orders.where((o) => o.status == OrderStatus.preparing).length,
        ready: orders.where((o) => o.status == OrderStatus.ready).length,
        delivered: orders.where((o) => o.status == OrderStatus.delivered).length,
      );
    },
  );
});
