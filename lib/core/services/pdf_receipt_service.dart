import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../format/formatters.dart';

/// Données d'une ligne d'article pour l'impression du reçu.
class ReceiptLineItem {
  const ReceiptLineItem({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String name;
  final String unit;
  final int quantity;
  final int unitPrice;
  final int lineTotal;
}

/// Données complètes d'un reçu de vente.
class ReceiptData {
  const ReceiptData({
    required this.reference,
    required this.date,
    required this.businessName,
    required this.businessPhone,
    required this.businessAddress,
    required this.businessNif,
    required this.lines,
    required this.total,
    required this.amountPaid,
    required this.creditAmount,
    required this.paymentMethodLabel,
    this.customerName,
  });

  final String reference;
  final DateTime date;
  final String businessName;
  final String businessPhone;
  final String businessAddress;
  final String businessNif;
  final List<ReceiptLineItem> lines;
  final int total;
  final int amountPaid;
  final int creditAmount;
  final String paymentMethodLabel;
  final String? customerName;

  bool get isCredit => creditAmount > 0;
}

/// Service responsable de la construction du document PDF de reçu.
class PdfReceiptService {
  /// Génère les octets du fichier PDF pour un [ReceiptData] donné.
  static Future<Uint8List> generateReceiptPdf(ReceiptData data) async {
    final pdf = pw.Document();

    // Utilisation d'une police système/standard compatible PDF
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Ticket caisse 80mm
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // En-tête commerce
              pw.Text(
                data.businessName.toUpperCase(),
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              if (data.businessAddress.isNotEmpty)
                pw.Text(
                  data.businessAddress,
                  style: pw.TextStyle(font: font, fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              if (data.businessPhone.isNotEmpty)
                pw.Text(
                  'Tél : ${data.businessPhone}',
                  style: pw.TextStyle(font: font, fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              if (data.businessNif.isNotEmpty)
                pw.Text(
                  'NIF : ${data.businessNif}',
                  style: pw.TextStyle(font: font, fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5),

              // Informations ticket
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Réf : ${data.reference}', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                  pw.Text(formatDateTime(data.date), style: pw.TextStyle(font: font, fontSize: 8)),
                ],
              ),
              if (data.customerName != null && data.customerName!.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  children: [
                    pw.Text('Client : ', style: pw.TextStyle(font: fontBold, fontSize: 8)),
                    pw.Text(data.customerName!, style: pw.TextStyle(font: font, fontSize: 8)),
                  ],
                ),
              ],
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5),

              // En-tête du tableau d'articles
              pw.Row(
                children: [
                  pw.Expanded(flex: 3, child: pw.Text('Article', style: pw.TextStyle(font: fontBold, fontSize: 8))),
                  pw.Expanded(flex: 1, child: pw.Text('Qté', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontBold, fontSize: 8))),
                  pw.Expanded(flex: 2, child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontBold, fontSize: 8))),
                ],
              ),
              pw.SizedBox(height: 4),

              // Articles
              for (final line in data.lines) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(line.name, style: pw.TextStyle(font: fontBold, fontSize: 8)),
                          pw.Text('${formatAmount(line.unitPrice)} GNF / ${line.unit}', style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('${line.quantity}', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font, fontSize: 8)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(formatAmount(line.lineTotal), textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontBold, fontSize: 8)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),
              ],

              pw.Divider(thickness: 0.5),

              // Totaux & Règlement
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL :', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.Text(formatGnf(data.total), style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Paiement (${data.paymentMethodLabel}) :', style: pw.TextStyle(font: font, fontSize: 8)),
                  pw.Text(formatGnf(data.amountPaid), style: pw.TextStyle(font: font, fontSize: 8)),
                ],
              ),
              if (data.isCredit) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Reste dû (Crédit) :', style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.red800)),
                    pw.Text(formatGnf(data.creditAmount), style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.red800)),
                  ],
                ),
              ],

              pw.SizedBox(height: 10),
              pw.Text('Merci pour votre confiance !', style: pw.TextStyle(font: font, fontSize: 8, fontStyle: pw.FontStyle.italic), textAlign: pw.TextAlign.center),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
