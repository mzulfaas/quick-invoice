import 'dart:convert';
import 'package:intl/intl.dart';

enum CurrencyCode {
  usd('USD', '\$', 2, true),
  eur('EUR', '€', 2, false),
  gbp('GBP', '£', 2, true),
  idr('IDR', 'Rp ', 0, true),
  sgd('SGD', 'S\$', 2, true),
  aud('AUD', 'A\$', 2, true);

  final String code;
  final String symbol;
  final int decimals;
  final bool symbolBefore;

  const CurrencyCode(this.code, this.symbol, this.decimals, this.symbolBefore);

  String format(double amount) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
      customPattern: symbolBefore ? '\u00a4#,##0.00' : '#,##0.00 \u00a4',
    );
    if (decimals == 0) {
      return NumberFormat.currency(
        symbol: symbol,
        decimalDigits: 0,
        customPattern: symbolBefore ? '\u00a4#,##0' : '#,##0 \u00a4',
      ).format(amount);
    }
    return formatter.format(amount);
  }
}

class InvoiceItem {
  String id;
  String description;
  double quantity;
  double unitPrice;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BusinessInfo {
  String name;
  String email;
  String phone;
  String address;
  String taxId;
  String paymentDetails;

  BusinessInfo({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.taxId = '',
    this.paymentDetails = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'taxId': taxId,
      'paymentDetails': paymentDetails,
    };
  }

  factory BusinessInfo.fromMap(Map<String, dynamic> map) {
    return BusinessInfo(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      taxId: map['taxId'] ?? '',
      paymentDetails: map['paymentDetails'] ?? '',
    );
  }

  factory BusinessInfo.empty() {
    return BusinessInfo(
      name: '',
      email: '',
      phone: '',
      address: '',
    );
  }
}

class ClientInfo {
  String name;
  String email;
  String phone;
  String address;

  ClientInfo({
    required this.name,
    required this.email,
    this.phone = '',
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }

  factory ClientInfo.fromMap(Map<String, dynamic> map) {
    return ClientInfo(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
    );
  }

  factory ClientInfo.empty() {
    return ClientInfo(
      name: '',
      email: '',
      phone: '',
      address: '',
    );
  }
}

class Invoice {
  String invoiceNumber;
  DateTime issueDate;
  DateTime dueDate;
  CurrencyCode currency;
  BusinessInfo sender;
  ClientInfo client;
  List<InvoiceItem> items;
  double discountRate; // e.g. 5 for 5%
  double taxRate; // e.g. 10 for 10%
  String notes;

  Invoice({
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.currency,
    required this.sender,
    required this.client,
    required this.items,
    this.discountRate = 0.0,
    this.taxRate = 0.0,
    this.notes = 'Payment is due within 14 days of invoice date. Thank you for your business!',
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  double get discountAmount => subtotal * (discountRate / 100.0);
  double get taxableAmount => subtotal - discountAmount;
  double get taxAmount => taxableAmount * (taxRate / 100.0);
  double get grandTotal => taxableAmount + taxAmount;

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'currency': currency.name,
      'sender': sender.toMap(),
      'client': client.toMap(),
      'items': items.map((x) => x.toMap()).toList(),
      'discountRate': discountRate,
      'taxRate': taxRate,
      'notes': notes,
    };
  }

  String toJson() => json.encode(toMap());

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      invoiceNumber: map['invoiceNumber'] ?? 'INV-001',
      issueDate: DateTime.tryParse(map['issueDate'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now().add(const Duration(days: 14)),
      currency: CurrencyCode.values.firstWhere(
        (c) => c.name == map['currency'],
        orElse: () => CurrencyCode.usd,
      ),
      sender: BusinessInfo.fromMap(map['sender'] ?? {}),
      client: ClientInfo.fromMap(map['client'] ?? {}),
      items: (map['items'] as List<dynamic>?)
              ?.map((x) => InvoiceItem.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      discountRate: (map['discountRate'] as num?)?.toDouble() ?? 0.0,
      taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
    );
  }

  factory Invoice.sample() {
    final now = DateTime.now();
    return Invoice(
      invoiceNumber: 'INV-2026-084',
      issueDate: now,
      dueDate: now.add(const Duration(days: 14)),
      currency: CurrencyCode.usd,
      sender: BusinessInfo(
        name: 'Zulfa Engineering Studio',
        email: 'billing@mzulfaas.dev',
        phone: '+1 (555) 382-9104',
        address: '742 Market Street, Suite 400\nSan Francisco, CA 94103',
        taxId: 'US-EIN-94-3829104',
        paymentDetails: 'Wire Transfer / ACH:\nBank: Silicon Valley Tech Bank\nAccount: 8829-1092-4410\nRouting: 121000358',
      ),
      client: ClientInfo(
        name: 'Apex Growth Labs Inc.',
        email: 'finance@apexgrowthlabs.com',
        phone: '+1 (415) 890-4421',
        address: '500 Howard Street, Fl 8\nSan Francisco, CA 94105',
      ),
      items: [
        InvoiceItem(
          id: 'item-1',
          description: 'AI-Native Web Application Architecture & MVP Development',
          quantity: 1,
          unitPrice: 3500.00,
        ),
        InvoiceItem(
          id: 'item-2',
          description: 'Flutter Cross-Platform UI/UX System & Widget Optimization',
          quantity: 32,
          unitPrice: 75.00,
        ),
        InvoiceItem(
          id: 'item-3',
          description: 'Client-Side WASM Integration & Edge Performance Audit',
          quantity: 1,
          unitPrice: 850.00,
        ),
      ],
      discountRate: 5.0,
      taxRate: 8.5,
      notes: 'Thank you for partnering with Zulfa Engineering Studio. Payment is due within 14 business days. For questions regarding this invoice, contact billing@mzulfaas.dev.',
    );
  }
}
