import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice.dart';

class StorageService {
  static const String _keyBusinessProfile = 'qi_business_profile';
  static const String _keyLastInvoice = 'qi_last_invoice';

  static Future<void> saveBusinessProfile(BusinessInfo profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBusinessProfile, json.encode(profile.toMap()));
  }

  static Future<BusinessInfo?> loadBusinessProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyBusinessProfile);
    if (data != null && data.isNotEmpty) {
      try {
        final map = json.decode(data) as Map<String, dynamic>;
        return BusinessInfo.fromMap(map);
      } catch (_) {}
    }
    return null;
  }

  static Future<void> saveInvoice(Invoice invoice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastInvoice, invoice.toJson());
  }

  static Future<Invoice?> loadLastInvoice() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyLastInvoice);
    if (data != null && data.isNotEmpty) {
      try {
        final map = json.decode(data) as Map<String, dynamic>;
        return Invoice.fromMap(map);
      } catch (_) {}
    }
    return null;
  }
}
