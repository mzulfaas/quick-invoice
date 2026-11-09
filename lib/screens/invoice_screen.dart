import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../services/pdf_invoice_service.dart';
import '../services/storage_service.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> with SingleTickerProviderStateMixin {
  late Invoice _invoice;
  late TabController _tabController;
  bool _isLoading = true;
  bool _autoSaveBusiness = true;

  // Controllers for text editing to keep reactive updates smooth
  final _invoiceNumCtrl = TextEditingController();
  final _senderNameCtrl = TextEditingController();
  final _senderEmailCtrl = TextEditingController();
  final _senderPhoneCtrl = TextEditingController();
  final _senderAddressCtrl = TextEditingController();
  final _senderTaxCtrl = TextEditingController();
  final _senderPaymentCtrl = TextEditingController();

  final _clientNameCtrl = TextEditingController();
  final _clientEmailCtrl = TextEditingController();
  final _clientPhoneCtrl = TextEditingController();
  final _clientAddressCtrl = TextEditingController();

  final _discountCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initData();
  }

  Future<void> _initData() async {
    final savedInvoice = await StorageService.loadLastInvoice();
    final savedBusiness = await StorageService.loadBusinessProfile();

    if (savedInvoice != null) {
      _invoice = savedInvoice;
    } else {
      _invoice = Invoice.sample();
    }

    if (savedBusiness != null) {
      _invoice.sender = savedBusiness;
    }

    _syncControllersWithInvoice();
    setState(() {
      _isLoading = false;
    });
  }

  void _syncControllersWithInvoice() {
    _invoiceNumCtrl.text = _invoice.invoiceNumber;
    _senderNameCtrl.text = _invoice.sender.name;
    _senderEmailCtrl.text = _invoice.sender.email;
    _senderPhoneCtrl.text = _invoice.sender.phone;
    _senderAddressCtrl.text = _invoice.sender.address;
    _senderTaxCtrl.text = _invoice.sender.taxId;
    _senderPaymentCtrl.text = _invoice.sender.paymentDetails;

    _clientNameCtrl.text = _invoice.client.name;
    _clientEmailCtrl.text = _invoice.client.email;
    _clientPhoneCtrl.text = _invoice.client.phone;
    _clientAddressCtrl.text = _invoice.client.address;

    _discountCtrl.text = _invoice.discountRate == 0 ? '' : _invoice.discountRate.toString();
    _taxCtrl.text = _invoice.taxRate == 0 ? '' : _invoice.taxRate.toString();
    _notesCtrl.text = _invoice.notes;
  }

  void _loadSampleData() {
    setState(() {
      _invoice = Invoice.sample();
      _syncControllersWithInvoice();
    });
    _saveState();
  }

  void _resetData() {
    setState(() {
      final now = DateTime.now();
      _invoice = Invoice(
        invoiceNumber: 'INV-${DateFormat('yyyyMMdd').format(now)}-01',
        issueDate: now,
        dueDate: now.add(const Duration(days: 14)),
        currency: CurrencyCode.usd,
        sender: BusinessInfo.empty(),
        client: ClientInfo.empty(),
        items: [
          InvoiceItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            description: 'Consulting Services',
            quantity: 1,
            unitPrice: 100,
          )
        ],
        discountRate: 0,
        taxRate: 0,
        notes: 'Thank you for your business!',
      );
      _syncControllersWithInvoice();
    });
    _saveState();
  }

  void _saveState() {
    StorageService.saveInvoice(_invoice);
    if (_autoSaveBusiness) {
      StorageService.saveBusinessProfile(_invoice.sender);
    }
  }

  void _addItem() {
    setState(() {
      _invoice.items.add(
        InvoiceItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: '',
          quantity: 1,
          unitPrice: 0,
        ),
      );
    });
    _saveState();
  }

  void _removeItem(int index) {
    if (_invoice.items.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice must contain at least 1 item.')),
      );
      return;
    }
    setState(() {
      _invoice.items.removeAt(index);
    });
    _saveState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _invoiceNumCtrl.dispose();
    _senderNameCtrl.dispose();
    _senderEmailCtrl.dispose();
    _senderPhoneCtrl.dispose();
    _senderAddressCtrl.dispose();
    _senderTaxCtrl.dispose();
    _senderPaymentCtrl.dispose();
    _clientNameCtrl.dispose();
    _clientEmailCtrl.dispose();
    _clientPhoneCtrl.dispose();
    _clientAddressCtrl.dispose();
    _discountCtrl.dispose();
    _taxCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isWide = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(isWide),
      body: isWide ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isWide) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'QI',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'QuickInvoice',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 12),
          if (isWide)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                border: Border.all(color: const Color(0xFFBFDBFE)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 13, color: Color(0xFF2563EB)),
                  const SizedBox(width: 5),
                  Text(
                    '100% Client-Side Private • Zero Server Data',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: _loadSampleData,
          icon: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF2563EB)),
          label: Text(
            'Load Sample',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2563EB),
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Reset Form',
          onPressed: _resetData,
          icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () async {
            final pdfBytes = await PdfInvoiceService.generateInvoicePdf(_invoice);
            await Printing.sharePdf(
              bytes: pdfBytes,
              filename: 'Invoice_${_invoice.invoiceNumber}.pdf',
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.download_rounded, size: 16),
          label: Text(
            'Export PDF',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        const SizedBox(width: 16),
      ],
      bottom: isWide
          ? null
          : TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0F172A),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF0F172A),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(icon: Icon(Icons.edit_note, size: 20), text: 'Edit Invoice'),
                Tab(icon: Icon(Icons.picture_as_pdf, size: 20), text: 'Live PDF Preview'),
              ],
            ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Form Editor
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                _buildInvoiceMetaCard(),
                const SizedBox(height: 16),
                _buildSenderCard(),
                const SizedBox(height: 16),
                _buildClientCard(),
                const SizedBox(height: 16),
                _buildItemsCard(),
                const SizedBox(height: 16),
                _buildTotalsAndNotesCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        // Right Column: Live PDF Preview
        Expanded(
          flex: 6,
          child: Container(
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PdfPreview(
                build: (format) => PdfInvoiceService.generateInvoicePdf(_invoice),
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                allowPrinting: true,
                allowSharing: true,
                pdfFileName: 'Invoice_${_invoice.invoiceNumber}.pdf',
                previewPageMargin: const EdgeInsets.all(12),
                loadingWidget: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return TabBarView(
      controller: _tabController,
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            _buildInvoiceMetaCard(),
            const SizedBox(height: 14),
            _buildSenderCard(),
            const SizedBox(height: 14),
            _buildClientCard(),
            const SizedBox(height: 14),
            _buildItemsCard(),
            const SizedBox(height: 14),
            _buildTotalsAndNotesCard(),
            const SizedBox(height: 32),
          ],
        ),
        Container(
          color: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.all(12),
          child: PdfPreview(
            build: (format) => PdfInvoiceService.generateInvoicePdf(_invoice),
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            pdfFileName: 'Invoice_${_invoice.invoiceNumber}.pdf',
            loadingWidget: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF0F172A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInvoiceMetaCard() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return _buildSectionCard(
      title: 'Invoice Details',
      icon: Icons.receipt_long,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _invoiceNumCtrl,
                decoration: _inputDecoration('Invoice Number', 'INV-2026-001'),
                onChanged: (val) {
                  setState(() => _invoice.invoiceNumber = val);
                  _saveState();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<CurrencyCode>(
                initialValue: _invoice.currency,
                decoration: _inputDecoration('Currency', ''),
                items: CurrencyCode.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text('${c.code} (${c.symbol})', style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _invoice.currency = val);
                    _saveState();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _invoice.issueDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setState(() => _invoice.issueDate = picked);
                    _saveState();
                  }
                },
                child: InputDecorator(
                  decoration: _inputDecoration('Issue Date', ''),
                  child: Text(
                    dateFormat.format(_invoice.issueDate),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _invoice.dueDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setState(() => _invoice.dueDate = picked);
                    _saveState();
                  }
                },
                child: InputDecorator(
                  decoration: _inputDecoration('Due Date', ''),
                  child: Text(
                    dateFormat.format(_invoice.dueDate),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSenderCard() {
    return _buildSectionCard(
      title: 'Your Business (Sender)',
      icon: Icons.business_outlined,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: _autoSaveBusiness,
            onChanged: (val) {
              setState(() => _autoSaveBusiness = val ?? true);
            },
          ),
          Text('Auto-save', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B))),
        ],
      ),
      children: [
        TextField(
          controller: _senderNameCtrl,
          decoration: _inputDecoration('Business or Freelancer Name', 'Acme Studios'),
          onChanged: (val) {
            setState(() => _invoice.sender.name = val);
            _saveState();
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _senderEmailCtrl,
                decoration: _inputDecoration('Email', 'billing@acme.com'),
                onChanged: (val) {
                  setState(() => _invoice.sender.email = val);
                  _saveState();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _senderPhoneCtrl,
                decoration: _inputDecoration('Phone', '+1 (555) 019-2834'),
                onChanged: (val) {
                  setState(() => _invoice.sender.phone = val);
                  _saveState();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _senderAddressCtrl,
          maxLines: 2,
          decoration: _inputDecoration('Physical / Billing Address', '100 Main St, City, State'),
          onChanged: (val) {
            setState(() => _invoice.sender.address = val);
            _saveState();
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _senderTaxCtrl,
                decoration: _inputDecoration('Tax / VAT / EIN ID (Optional)', 'US-EIN-12345'),
                onChanged: (val) {
                  setState(() => _invoice.sender.taxId = val);
                  _saveState();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _senderPaymentCtrl,
          maxLines: 2,
          decoration: _inputDecoration('Payment / Wire / Bank Transfer Instructions', 'Bank: Chase, Account: 1234-5678, Routing: 987654'),
          onChanged: (val) {
            setState(() => _invoice.sender.paymentDetails = val);
            _saveState();
          },
        ),
      ],
    );
  }

  Widget _buildClientCard() {
    return _buildSectionCard(
      title: 'Billed To (Client)',
      icon: Icons.person_outline,
      children: [
        TextField(
          controller: _clientNameCtrl,
          decoration: _inputDecoration('Client / Company Name', 'Apex Innovations LLC'),
          onChanged: (val) {
            setState(() => _invoice.client.name = val);
            _saveState();
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _clientEmailCtrl,
                decoration: _inputDecoration('Client Email', 'accounts@apexinnovations.com'),
                onChanged: (val) {
                  setState(() => _invoice.client.email = val);
                  _saveState();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _clientPhoneCtrl,
                decoration: _inputDecoration('Client Phone (Optional)', '+1 (555) 888-9999'),
                onChanged: (val) {
                  setState(() => _invoice.client.phone = val);
                  _saveState();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _clientAddressCtrl,
          maxLines: 2,
          decoration: _inputDecoration('Client Address', '500 Market St, Suite 200, City, State'),
          onChanged: (val) {
            setState(() => _invoice.client.address = val);
            _saveState();
          },
        ),
      ],
    );
  }

  Widget _buildItemsCard() {
    return _buildSectionCard(
      title: 'Line Items',
      icon: Icons.format_list_bulleted,
      trailing: TextButton.icon(
        onPressed: _addItem,
        icon: const Icon(Icons.add_circle_outline, size: 16),
        label: const Text('Add Item', style: TextStyle(fontSize: 12)),
      ),
      children: [
        for (int i = 0; i < _invoice.items.length; i++) _buildItemRow(i),
      ],
    );
  }

  Widget _buildItemRow(int index) {
    final item = _invoice.items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.description,
                  decoration: _inputDecoration('Description', 'e.g. Frontend Development'),
                  onChanged: (val) {
                    setState(() => item.description = val);
                    _saveState();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                tooltip: 'Remove',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: item.quantity.toString(),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Qty', '1'),
                  onChanged: (val) {
                    final q = double.tryParse(val) ?? 1.0;
                    setState(() => item.quantity = q);
                    _saveState();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: item.unitPrice.toString(),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Unit Price (${_invoice.currency.symbol})', '100.00'),
                  onChanged: (val) {
                    final p = double.tryParse(val) ?? 0.0;
                    setState(() => item.unitPrice = p);
                    _saveState();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B))),
                      Text(
                        _invoice.currency.format(item.total),
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsAndNotesCard() {
    return _buildSectionCard(
      title: 'Taxes, Discounts & Notes',
      icon: Icons.tune,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _discountCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Discount (%)', '0'),
                onChanged: (val) {
                  final d = double.tryParse(val) ?? 0.0;
                  setState(() => _invoice.discountRate = d);
                  _saveState();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _taxCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Tax / VAT (%)', '0'),
                onChanged: (val) {
                  final t = double.tryParse(val) ?? 0.0;
                  setState(() => _invoice.taxRate = t);
                  _saveState();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesCtrl,
          maxLines: 2,
          decoration: _inputDecoration('Notes / Terms & Conditions', 'Payment due within 14 days.'),
          onChanged: (val) {
            setState(() => _invoice.notes = val);
            _saveState();
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _buildTotalLine('Subtotal', _invoice.currency.format(_invoice.subtotal)),
              if (_invoice.discountRate > 0) ...[
                const SizedBox(height: 6),
                _buildTotalLine(
                  'Discount (${_invoice.discountRate.toStringAsFixed(1)}%)',
                  '- ${_invoice.currency.format(_invoice.discountAmount)}',
                  color: const Color(0xFF4ADE80),
                ),
              ],
              if (_invoice.taxRate > 0) ...[
                const SizedBox(height: 6),
                _buildTotalLine(
                  'Tax (${_invoice.taxRate.toStringAsFixed(1)}%)',
                  _invoice.currency.format(_invoice.taxAmount),
                ),
              ],
              const Divider(color: Color(0xFF334155), height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grand Total',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _invoice.currency.format(_invoice.grandTotal),
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalLine(String label, String value, {Color color = const Color(0xFF94A3B8)}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(color: color, fontSize: 13)),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}
