import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/invoice.dart';

class PdfInvoiceService {
  static Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document(
      title: 'Invoice ${invoice.invoiceNumber}',
      author: invoice.sender.name.isNotEmpty ? invoice.sender.name : 'QuickInvoice',
      creator: 'QuickInvoice (Client-Side Private Engine)',
    );

    final dateFormat = DateFormat('MMM dd, yyyy');
    final primaryColor = PdfColor.fromHex('#0F172A'); // Slate 900
    final secondaryColor = PdfColor.fromHex('#475569'); // Slate 600
    final lightBgColor = PdfColor.fromHex('#F8FAFC'); // Slate 50
    final borderColor = PdfColor.fromHex('#E2E8F0'); // Slate 200
    final accentColor = PdfColor.fromHex('#2563EB'); // Blue 600

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => _buildHeader(invoice, dateFormat, primaryColor, accentColor, lightBgColor),
        footer: (context) => _buildFooter(context, secondaryColor, borderColor),
        build: (context) => [
          pw.SizedBox(height: 24),
          _buildPartyInfo(invoice, primaryColor, secondaryColor),
          pw.SizedBox(height: 28),
          _buildItemsTable(invoice, primaryColor, secondaryColor, borderColor, lightBgColor),
          pw.SizedBox(height: 20),
          _buildSummaryAndPayment(invoice, primaryColor, secondaryColor, borderColor, lightBgColor),
          if (invoice.notes.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _buildNotes(invoice, primaryColor, secondaryColor, borderColor, lightBgColor),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
    Invoice invoice,
    DateFormat dateFormat,
    PdfColor primaryColor,
    PdfColor accentColor,
    PdfColor lightBgColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromHex('#CBD5E1'), width: 1.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 32,
                    height: 32,
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'QI',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '# ${invoice.invoiceNumber}',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: pw.BoxDecoration(
              color: lightBgColor,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      'Date Issued: ',
                      style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#64748B')),
                    ),
                    pw.Text(
                      dateFormat.format(invoice.issueDate),
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      'Payment Due: ',
                      style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#64748B')),
                    ),
                    pw.Text(
                      dateFormat.format(invoice.dueDate),
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPartyInfo(
    Invoice invoice,
    PdfColor primaryColor,
    PdfColor secondaryColor,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BILLED FROM',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: secondaryColor,
                  letterSpacing: 1.0,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                invoice.sender.name.isNotEmpty ? invoice.sender.name : 'Your Business Name',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              if (invoice.sender.address.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  invoice.sender.address,
                  style: pw.TextStyle(fontSize: 10, color: secondaryColor, lineSpacing: 2),
                ),
              ],
              if (invoice.sender.email.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  invoice.sender.email,
                  style: pw.TextStyle(fontSize: 10, color: secondaryColor),
                ),
              ],
              if (invoice.sender.phone.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  invoice.sender.phone,
                  style: pw.TextStyle(fontSize: 10, color: secondaryColor),
                ),
              ],
              if (invoice.sender.taxId.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  'Tax ID: ${invoice.sender.taxId}',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: secondaryColor),
                ),
              ],
            ],
          ),
        ),
        pw.SizedBox(width: 24),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BILLED TO',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: secondaryColor,
                  letterSpacing: 1.0,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                invoice.client.name.isNotEmpty ? invoice.client.name : 'Client Name',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              if (invoice.client.address.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  invoice.client.address,
                  style: pw.TextStyle(fontSize: 10, color: secondaryColor, lineSpacing: 2),
                ),
              ],
              if (invoice.client.email.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  invoice.client.email,
                  style: pw.TextStyle(fontSize: 10, color: secondaryColor),
                ),
              ],
              if (invoice.client.phone.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  invoice.client.phone,
                  style: pw.TextStyle(fontSize: 10, color: secondaryColor),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(
    Invoice invoice,
    PdfColor primaryColor,
    PdfColor secondaryColor,
    PdfColor borderColor,
    PdfColor lightBgColor,
  ) {
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: borderColor, width: 0.8),
        bottom: pw.BorderSide(color: borderColor, width: 1.2),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(5.0), // Description
        1: const pw.FlexColumnWidth(1.2), // Qty
        2: const pw.FlexColumnWidth(2.0), // Unit Price
        3: const pw.FlexColumnWidth(2.2), // Total
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: lightBgColor,
            border: pw.Border(
              top: pw.BorderSide(color: borderColor, width: 1),
              bottom: pw.BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
          children: [
            _buildTableHeader('DESCRIPTION', pw.TextAlign.left, secondaryColor),
            _buildTableHeader('QTY', pw.TextAlign.center, secondaryColor),
            _buildTableHeader('PRICE', pw.TextAlign.right, secondaryColor),
            _buildTableHeader('AMOUNT', pw.TextAlign.right, secondaryColor),
          ],
        ),
        // Item Rows
        ...invoice.items.map((item) {
          final isEven = invoice.items.indexOf(item) % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : PdfColor.fromHex('#F8FAFC'),
            ),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: pw.Text(
                  item.description.isNotEmpty ? item.description : 'Service item',
                  style: pw.TextStyle(fontSize: 10, color: primaryColor),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: pw.Text(
                  item.quantity == item.quantity.roundToDouble()
                      ? item.quantity.toInt().toString()
                      : item.quantity.toStringAsFixed(1),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10, color: primaryColor),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: pw.Text(
                  invoice.currency.format(item.unitPrice),
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontSize: 10, color: primaryColor),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: pw.Text(
                  invoice.currency.format(item.total),
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text, pw.TextAlign align, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryAndPayment(
    Invoice invoice,
    PdfColor primaryColor,
    PdfColor secondaryColor,
    PdfColor borderColor,
    PdfColor lightBgColor,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Payment Instructions
        pw.Expanded(
          flex: 5,
          child: invoice.sender.paymentDetails.isNotEmpty
              ? pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: lightBgColor,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: borderColor),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PAYMENT INSTRUCTIONS',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: secondaryColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        invoice.sender.paymentDetails,
                        style: pw.TextStyle(fontSize: 9, color: primaryColor, lineSpacing: 2),
                      ),
                    ],
                  ),
                )
              : pw.SizedBox.shrink(),
        ),
        pw.SizedBox(width: 24),
        // Totals Block
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            children: [
              _buildSummaryRow('Subtotal', invoice.currency.format(invoice.subtotal), secondaryColor, primaryColor),
              if (invoice.discountRate > 0) ...[
                pw.SizedBox(height: 5),
                _buildSummaryRow(
                  'Discount (${invoice.discountRate.toStringAsFixed(1)}%)',
                  '- ${invoice.currency.format(invoice.discountAmount)}',
                  secondaryColor,
                  PdfColor.fromHex('#16A34A'), // Green 600
                ),
              ],
              if (invoice.taxRate > 0) ...[
                pw.SizedBox(height: 5),
                _buildSummaryRow(
                  'Tax / VAT (${invoice.taxRate.toStringAsFixed(1)}%)',
                  invoice.currency.format(invoice.taxAmount),
                  secondaryColor,
                  primaryColor,
                ),
              ],
              pw.SizedBox(height: 10),
              // Grand Total Pill
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL DUE',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    pw.Text(
                      invoice.currency.format(invoice.grandTotal),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value, PdfColor labelColor, PdfColor valColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, color: labelColor),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: valColor),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildNotes(
    Invoice invoice,
    PdfColor primaryColor,
    PdfColor secondaryColor,
    PdfColor borderColor,
    PdfColor lightBgColor,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TERMS & NOTES',
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: secondaryColor,
              letterSpacing: 0.8,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            invoice.notes,
            style: pw.TextStyle(fontSize: 9, color: secondaryColor, lineSpacing: 2),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(
    pw.Context context,
    PdfColor secondaryColor,
    PdfColor borderColor,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: borderColor, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'QuickInvoice • 100% Client-Side & Private • Zero Server Retention',
            style: pw.TextStyle(fontSize: 8, color: secondaryColor),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: secondaryColor),
          ),
        ],
      ),
    );
  }
}
