import 'dart:core';
import 'package:encrypt/encrypt.dart';

class Protector {
  final String firebaseUid;
  late final Encrypter _encrypter;
  late final IV _iv;
  Protector({required this.firebaseUid}) {
    final key = Key.fromUtf8(_secretKey);
    _encrypter = Encrypter(AES(key, mode: AESMode.sic, padding: 'PKCS7'));
    _iv = IV.fromLength(16);
  }

  String get _secretKey {
    if (firebaseUid.length == 32) {
      return firebaseUid;
    }
    if (firebaseUid.length > 32) {
      return firebaseUid.substring(0, 31);
    }
    return firebaseUid.padRight(32, '@');
  }

  String encryptToBase64(String text) {
    return _encrypter.encrypt(text, iv: _iv).base64;
  }

  String decryptBase64(String base64Text) {
    return _encrypter.decrypt(Encrypted.fromBase64(base64Text),
        iv: _iv);
  }
}
