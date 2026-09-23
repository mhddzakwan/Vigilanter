import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  bool _statusIngatSaya = false;
  String? _userId;  // Menyimpan UID pengguna

  bool get StatusIngatSaya => _statusIngatSaya;
  String? get UserId => _userId;

  set statusIngatSaya(bool value) {
    _statusIngatSaya = value;
    _savePreferences();
    notifyListeners();
  }

  set userId(String? value) {
    _userId = value;
    _savePreferences();
    notifyListeners();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _statusIngatSaya = prefs.getBool('ingat_saya') ?? false;
    _userId = prefs.getString('user_id');
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ingat_saya', _statusIngatSaya);
    if (_userId != null) {
      await prefs.setString('user_id', _userId!);
    } else {
      await prefs.remove('user_id');  // Hapus jika null
    }
  }


}