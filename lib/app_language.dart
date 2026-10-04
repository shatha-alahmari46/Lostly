import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  String get languageName => isArabic ? 'العربية' : 'English';

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage == 'ar') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }

    notifyListeners();
  }

  Future<void> changeLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();

    if (language == 'العربية') {
      _locale = const Locale('ar');
      await prefs.setString(_languageKey, 'ar');
    } else {
      _locale = const Locale('en');
      await prefs.setString(_languageKey, 'en');
    }

    notifyListeners();
  }
}