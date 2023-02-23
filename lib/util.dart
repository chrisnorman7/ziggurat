import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';

/// Generate a secure encryption key.
String generateEncryptionKey() => SecureRandom(32).base64;

/// Encrypt the given [bytes] to the given [outputFile], and return the
/// encryption key.
String encryptBytes({
  required final List<int> bytes,
  required final File outputFile,
  final String? encryptionKey,
}) {
  final actualEncryptionKey = encryptionKey ?? generateEncryptionKey();
  final key = Key.fromBase64(actualEncryptionKey);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  final data = encrypter
      .encryptBytes(
        bytes,
        iv: iv,
      )
      .bytes;
  outputFile.writeAsBytesSync(data);
  return actualEncryptionKey;
}

/// Encrypt the given [inputFile] into the given [outputFile], and return the
/// encryption key.
String encryptFile({
  required final File inputFile,
  required final File outputFile,
  final String? encryptionKey,
}) =>
    encryptBytes(
      bytes: inputFile.readAsBytesSync(),
      outputFile: outputFile,
      encryptionKey: encryptionKey,
    );

/// Encrypt the given [string] to the given [outputFile], and return the
/// encryption key.
String encryptString({
  required final String string,
  required final File outputFile,
  final String? encryptionKey,
}) =>
    encryptBytes(
      bytes: utf8.encode(string),
      outputFile: outputFile,
      encryptionKey: encryptionKey,
    );

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
