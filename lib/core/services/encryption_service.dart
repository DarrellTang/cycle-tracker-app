import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for encrypting and decrypting sensitive data
class EncryptionService {
  static EncryptionService? _instance;
  static EncryptionService get instance => _instance ??= EncryptionService._();

  EncryptionService._();

  late final encrypt.Encrypter _encrypter;
  late final encrypt.Key _key;
  static const String _keyStorageKey = 'cycle_tracker_encryption_key';
  static const String _ivStorageKey = 'cycle_tracker_encryption_iv';
  bool _isInitialized = false;

  /// Initialize the encryption service
  Future<void> initialize() async {
    if (_isInitialized) return; // Prevent double initialization

    final prefs = await SharedPreferences.getInstance();

    // Get or generate encryption key
    String? storedKey = prefs.getString(_keyStorageKey);
    if (storedKey == null) {
      // Generate new key
      _key = encrypt.Key.fromSecureRandom(32);
      await prefs.setString(_keyStorageKey, _key.base64);
    } else {
      _key = encrypt.Key.fromBase64(storedKey);
    }

    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
    _isInitialized = true;
  }

  /// Encrypt a string value
  String encryptString(String value) {
    if (value.isEmpty) return value;

    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(value, iv: iv);

    // Combine IV and encrypted data
    final combined = iv.bytes + encrypted.bytes;
    return base64.encode(combined);
  }

  /// Decrypt a string value
  String decryptString(String encryptedValue) {
    if (encryptedValue.isEmpty) return encryptedValue;

    try {
      final combined = base64.decode(encryptedValue);

      // Extract IV (first 16 bytes) and encrypted data
      final iv = encrypt.IV(Uint8List.fromList(combined.take(16).toList()));
      final encryptedBytes = Uint8List.fromList(combined.skip(16).toList());
      final encrypted = encrypt.Encrypted(encryptedBytes);

      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      // If decryption fails, return original value (might be unencrypted legacy data)
      return encryptedValue;
    }
  }

  /// Encrypt a JSON map (for storing complex objects)
  String encryptJson(Map<String, dynamic> json) {
    final jsonString = jsonEncode(json);
    return encryptString(jsonString);
  }

  /// Decrypt a JSON string back to a map
  Map<String, dynamic> decryptJson(String encryptedJson) {
    final jsonString = decryptString(encryptedJson);
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Encrypt sensitive fields in a database row
  Map<String, dynamic> encryptSensitiveFields(
    Map<String, dynamic> data,
    List<String> sensitiveFields,
  ) {
    final result = Map<String, dynamic>.from(data);

    for (final field in sensitiveFields) {
      if (result.containsKey(field) && result[field] != null) {
        final value = result[field].toString();
        result[field] = encryptString(value);
      }
    }

    return result;
  }

  /// Decrypt sensitive fields in a database row
  Map<String, dynamic> decryptSensitiveFields(
    Map<String, dynamic> data,
    List<String> sensitiveFields,
  ) {
    final result = Map<String, dynamic>.from(data);

    for (final field in sensitiveFields) {
      if (result.containsKey(field) && result[field] != null) {
        final encryptedValue = result[field].toString();
        result[field] = decryptString(encryptedValue);
      }
    }

    return result;
  }

  /// Generate a hash for data integrity verification
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify data integrity using hash
  bool verifyHash(String data, String expectedHash) {
    final actualHash = generateHash(data);
    return actualHash == expectedHash;
  }

  /// Clear encryption keys (for logout/reset)
  Future<void> clearKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStorageKey);
    await prefs.remove(_ivStorageKey);
  }

  /// Check if encryption is properly initialized
  bool get isInitialized => _key.bytes.isNotEmpty;
}

/// Mixin for database models that need encryption
mixin EncryptedModel {
  /// List of field names that should be encrypted
  List<String> get sensitiveFields;

  /// Convert to JSON with encryption
  Map<String, dynamic> toEncryptedJson() {
    final json = toJson();
    return EncryptionService.instance.encryptSensitiveFields(
      json,
      sensitiveFields,
    );
  }

  /// Abstract method that concrete models must implement
  Map<String, dynamic> toJson();
}

/// Extension to add encryption capabilities to existing models
extension EncryptedJsonMap on Map<String, dynamic> {
  /// Encrypt sensitive fields in this map
  Map<String, dynamic> withEncryptedFields(List<String> fields) {
    return EncryptionService.instance.encryptSensitiveFields(this, fields);
  }

  /// Decrypt sensitive fields in this map
  Map<String, dynamic> withDecryptedFields(List<String> fields) {
    return EncryptionService.instance.decryptSensitiveFields(this, fields);
  }
}
