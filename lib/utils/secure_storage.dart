


import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = FlutterSecureStorage();

  Future<String?> readData(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> writeData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> deleteData(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
