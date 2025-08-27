import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// Mock para SharedPreferences en tests
class MockSharedPreferences {
  final Map<String, dynamic> _data = {};
  
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }
  
  int? getInt(String key) => _data[key] as int?;
  
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }
  
  Future<bool> clear() async {
    _data.clear();
    return true;
  }
}

/// Mock para Directory en tests
class MockDirectory {
  final String path;
  final bool _exists;
  
  MockDirectory(this.path, {bool exists = true}) : _exists = exists;
  
  Future<bool> exists() async => _exists;
  
  Future<MockDirectory> create({bool recursive = false}) async {
    return MockDirectory(path);
  }
}

/// Mock para File en tests
class MockFile {
  final String path;
  final bool _exists;
  final String content;
  
  MockFile(this.path, {bool exists = true, this.content = ''}) : _exists = exists;
  
  Future<bool> exists() async => _exists;
  
  Future<String> readAsString() async => content;
  
  Future<void> writeAsString(String data) async {
    // Simula escritura
  }
}
