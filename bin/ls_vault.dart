// ignore_for_file: avoid_print
/// Prints the filenames inside a vault file.
import 'dart:io';

import 'package:ziggurat/ziggurat.dart';

void main(List<String> args) {
  if (args.length != 2) {
    return print('Usage: ls-vault <vault_filename> <key>');
  }
  final f = File(args.first);
  if (f.existsSync() == false) {
    return print('Error: File does not exist.');
  }
  final vaultFile = VaultFile.fromEncryptedString(
      contents: f.readAsStringSync(), encryptionKey: args.last);
  print('Folders (${vaultFile.folders.length}):');
  for (final folder in vaultFile.folders.entries) {
    print('${folder.key}: ${folder.value.length}');
  }
  print('Files (${vaultFile.files.length}):');
  for (final file in vaultFile.files.entries) {
    print('${file.key}: ${file.value.length}');
  }
}
