// ignore_for_file: avoid_print
/// Allows the encryption of a folder of files and subdirectories.
import 'dart:io';

import 'package:args/args.dart';
import 'package:encrypt/encrypt.dart';
import 'package:ziggurat/ziggurat.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Show help for this script')
    ..addOption('key', abbr: 'k', help: 'The encryption key to use');
  final ArgResults results;
  try {
    results = parser.parse(args);
  } on FormatException catch (e) {
    return print('Error: ${e.message}');
  }
  if (results['help'] as bool || results.rest.length != 2) {
    print('Usage: encrypt-folder <input_folder> <output_file>');
    return print('Encrypts the given folder, and prints out the security key.');
  }
  final folderName = results.rest.first;
  final folder = Directory(folderName);
  if (folder.existsSync() == false) {
    return print('Error: That folder does not exist.');
  }
  print('Encrypting folder $folderName.');
  final vaultFile = VaultFile();
  for (final item in folder.listSync()) {
    final f = item.path.replaceAll(Platform.pathSeparator, '/');
    if (item is Directory) {
      print('Adding subdirectory $f.');
      final l = <List<int>>[];
      for (final file in item.listSync()) {
        if (file is File) {
          l.add(file.readAsBytesSync());
        } else {
          print('Skipping ${file.path}.');
        }
      }
      vaultFile.folders[f] = l;
    } else if (item is File) {
      print('Adding file $f.');
      vaultFile.files[f] = item.readAsBytesSync();
    } else {
      print('Skipping $item.');
    }
  }
  final key = (results['key'] as String?) ?? Key.fromSecureRandom(32).base64;
  print("final encryptionKey = '$key';");
  final data = vaultFile.toEncryptedString(encryptionKey: key);
  final outputFile = File(results.rest.last)..writeAsStringSync(data);
  print("final inputFile = File('${outputFile.path}');");
}
