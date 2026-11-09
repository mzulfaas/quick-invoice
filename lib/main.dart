import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/invoice_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuickInvoiceApp());
}

class QuickInvoiceApp extends StatelessWidget {
  const QuickInvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickInvoice • 100% Client-Side Private Invoice Maker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF0F172A),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const InvoiceScreen(),
    );
  }
}
