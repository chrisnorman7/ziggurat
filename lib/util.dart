import 'dart:io';

import 'package:encrypt/encrypt.dart';

/// Encrypt the given [inputFile] into the given [outputFile], and return the
/// encryption key.
String encryptFile({
  required final File inputFile,
  required final File outputFile,
}) {
  final encryptionKey = SecureRandom(32).base64;
  final key = Key.fromBase64(encryptionKey);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  final data = encrypter
      .encryptBytes(
        inputFile.readAsBytesSync(),
        iv: iv,
      )
      .bytes;
  outputFile.writeAsBytesSync(data);
  return encryptionKey;
}

/// Decrypt and return the contents of the given [file], using the given
/// [encryptionKey] as a string.
String decryptFileString({
  required final File file,
  required final String encryptionKey,
}) {
  final encrypter = Encrypter(AES(Key.fromBase64(encryptionKey)));
  final iv = IV.fromLength(16);
  final encrypted = Encrypted(file.readAsBytesSync());
  return encrypter.decrypt(encrypted, iv: iv);
}

/// Decrypt and return the contents of the given [file], using the given
/// [encryptionKey] as a list of bytes.
List<int> decryptFileBytes({
  required final File file,
  required final String encryptionKey,
}) {
  final encrypter = Encrypter(AES(Key.fromBase64(encryptionKey)));
  final iv = IV.fromLength(16);
  final encrypted = Encrypted(file.readAsBytesSync());
  return encrypter.decryptBytes(encrypted, iv: iv);
}
