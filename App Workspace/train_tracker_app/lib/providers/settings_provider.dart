import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _batteryOptimize = true;      // Reduce polling in background
  bool _alarmEnabled = true;
  int _alarmMinutesBefore = 30;
  bool _crowdsourceEnabled = false;  // User must explicitly opt in

  ThemeMode get themeMode => _themeMode;
  bool get batteryOptimize => _batteryOptimize;
  bool get alarmEnabled => _alarmEnabled;
  int get alarmMinutesBefore => _alarmMinutesBefore;
  bool get crowdsourceEnabled => _crowdsourceEnabled;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getBool('darkMode') == false ? ThemeMode.light : ThemeMode.dark;
    _batteryOptimize = prefs.getBool('batteryOptimize') ?? true;
    _alarmEnabled = prefs.getBool('alarmEnabled') ?? true;
    _alarmMinutesBefore = prefs.getInt('alarmMinutesBefore') ?? 30;
    _crowdsourceEnabled = prefs.getBool('crowdsourceEnabled') ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', dark);
    notifyListeners();
  }

  Future<void> setBatteryOptimize(bool val) async {
    _batteryOptimize = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('batteryOptimize', val);
    notifyListeners();
  }

  Future<void> setAlarm(bool enabled, {int? minutesBefore}) async {
    _alarmEnabled = enabled;
    if (minutesBefore != null) _alarmMinutesBefore = minutesBefore;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarmEnabled', enabled);
    if (minutesBefore != null) await prefs.setInt('alarmMinutesBefore', minutesBefore);
    notifyListeners();
  }

  Future<void> setCrowdsource(bool val) async {
    _crowdsourceEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('crowdsourceEnabled', val);
    notifyListeners();
  }

  void toggleLanguage(BuildContext context) {
    final current = context.locale;
    final next = current.languageCode == 'en' ? const Locale('hi') : const Locale('en');
    context.setLocale(next);
  }
}
