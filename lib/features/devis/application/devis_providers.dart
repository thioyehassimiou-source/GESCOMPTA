import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';

enum DevisStatus {
  pending,  // Devis en attente
  accepted, // Accepté / Transformé en commande
  invoiced, // Facturé
  paid,     // Payé
}

class DevisDocumentView {
  const DevisDocumentView({
    required this.id,
    required this.reference,
    required this.customerName,
    required this.date,
    required this.dueDate,
    required this.totalAmount,
    required this.status,
    required this.itemsCount,
  });

  final String id;
  final String reference;
  final String customerName;
  final DateTime date;
  final DateTime dueDate;
  final int totalAmount;
  final DevisStatus status;
  final int itemsCount;
}

class DevisData {
  const DevisData({
    required this.pendingCount,
    required this.pendingAmount,
    required this.paidMonthAmount,
    required this.totalDocumentsCount,
    required this.documents,
  });

  final int pendingCount;
  final int pendingAmount;
  final int paidMonthAmount;
  final int totalDocumentsCount;
  final List<DevisDocumentView> documents;
}

final devisDataProvider = FutureProvider<DevisData>((ref) async {
  final db = ref.watch(databaseProvider);

  // Fetch sales as invoices
  final sales = await (db.select(db.sales)
        ..orderBy([(s) => OrderingTerm(expression: s.date, mode: OrderingMode.desc)]))
      .get();

  final customerIds = sales.map((s) => s.customerId).whereType<String>().toSet().toList();
  final customerNames = <String, String>{};

  if (customerIds.isNotEmpty) {
    final custs = await (db.select(db.customers)..where((c) => c.id.isIn(customerIds))).get();
    for (final c in custs) {
      customerNames[c.id] = c.name;
    }
  }

  final documents = <DevisDocumentView>[];
  int pendingCount = 0;
  int pendingAmount = 0;
  int paidMonthAmount = 0;

  for (final s in sales) {
    final isPaid = s.amountPaid >= s.totalAmount;
    final status = isPaid
        ? DevisStatus.paid
        : (s.amountPaid > 0 ? DevisStatus.invoiced : DevisStatus.pending);

    if (status == DevisStatus.pending) {
      pendingCount++;
      pendingAmount += s.totalAmount;
    } else if (status == DevisStatus.paid) {
      paidMonthAmount += s.totalAmount;
    }

    documents.add(
      DevisDocumentView(
        id: s.id,
        reference: s.reference.replaceAll('V-', 'FAC-'),
        customerName: s.customerId != null ? (customerNames[s.customerId] ?? 'Client') : 'Client Comptoir',
        date: s.date,
        dueDate: s.date.add(const Duration(days: 30)),
        totalAmount: s.totalAmount,
        status: status,
        itemsCount: 1,
      ),
    );
  }

  return DevisData(
    pendingCount: pendingCount,
    pendingAmount: pendingAmount,
    paidMonthAmount: paidMonthAmount,
    totalDocumentsCount: documents.length,
    documents: documents,
  );
});
