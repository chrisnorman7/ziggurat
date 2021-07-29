// ignore_for_file: avoid_print
/// Allows the encryption of a folder of files.
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:encrypt/encrypt.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Show help for this script');
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
  final files = <String, List<int>>{};
  for (final file in folder.listSync()) {
    final f = file.path.replaceAll(Platform.pathSeparator, '/');
    if (file is Directory) {
      print('Skipping subdirectory $f.');
    } else if (file is File) {
      print('Adding file $f.');
      files[f] = file.readAsBytesSync();
    } else {
      print('Skipping $file.');
    }
  }
  final json = jsonEncode(files);
  final key = Key.fromSecureRandom(32);
  print("final encryptionKey = '${key.base64}';");
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  final encrypted = encrypter.encrypt(json, iv: iv);
  final outputFile = File(results.rest.last)
    ..writeAsStringSync(encrypted.base64);
  print("final inputFile = File('${outputFile.path}');");
}
