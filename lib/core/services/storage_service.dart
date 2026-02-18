import 'package:flutter/material.dart';

class StorageService extends ChangeNotifier {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }
}
