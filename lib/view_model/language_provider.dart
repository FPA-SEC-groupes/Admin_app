import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../utils/secure_storage.dart';
class LanguageProvider with ChangeNotifier {
  Locale _locale = window.locale;
  final SecureStorage secureStorage = SecureStorage(); // Create an instance of FlutterSecureStorage

  Locale get locale => _locale;

  // Initialize LanguageProvider and load saved language from secure storage
  LanguageProvider() {
    _loadSavedLanguage();
  }

  // Load saved language from secure storage
  void _loadSavedLanguage() async {

    String? savedLanguageCode = await secureStorage.readData( 'selectedLanguage');
    if (savedLanguageCode != null) {
      _locale = Locale(savedLanguageCode);
      notifyListeners();
    }
  }

  int getCurrentLanguageIndex() {
    return L10n.all.indexWhere((locale) => locale.languageCode == _locale.languageCode);
  }

  // Change the locale and save the selected language in secure storage
  void changeLocale(Locale newLocale) async {
    _locale = newLocale;
    notifyListeners();

    // Save the selected language in secure storage
    await secureStorage.writeData('selectedLanguage', newLocale.languageCode);
  }
}