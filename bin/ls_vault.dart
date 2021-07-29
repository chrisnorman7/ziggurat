// ignore_for_file: avoid_print
/// Prints the filenames inside a vault file.
import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';

/// The type of JSON we'll be working with.
typedef JsonType = Map<String, List<int>>;
void main(List<String> args) {
  if (args.length != 2) {
    return print('Usage: ls-vault <vault_filename> <key>');
  }
  final f = File(args.first);
  if (f.existsSync() == false) {
    return print('Error: File does not exist.');
  }
  final data = f.readAsStringSync();
  final key = Key.fromBase64(args.last);
  final encrypter = Encrypter(AES(key));
  final iv = IV.fromLength(16);
  final encrypted = Encrypted.fromBase64(data);
  final json = encrypter.decrypt(encrypted, iv: iv);
  for (final entry in (jsonDecode(json) as Map<String, dynamic>).entries) {
    final contents = entry.value as List<dynamic>;
    print('${entry.key} (${contents.length})');
  }
}
