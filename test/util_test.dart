import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ziggurat/util.dart';

void main() {
  group(
    'Utils',
    () {
      final inputFile = File(path.join('lib', 'ziggurat.dart'));
      final outputFile = File('ziggurat.encrypted');

      tearDown(() {
        if (outputFile.existsSync()) {
          outputFile.deleteSync(recursive: true);
        }
      });

      test(
        'encryptBytes',
        () {
          final bytes = inputFile.readAsBytesSync();
          encryptBytes(
            bytes: bytes,
            outputFile: outputFile,
          );
          expect(
            outputFile.readAsBytesSync(),
            isNot(inputFile.readAsBytesSync()),
          );
        },
      );

      test(
        'encryptFile',
        () {
          final encryptionKey = encryptFile(
            inputFile: inputFile,
            outputFile: outputFile,
          );
          expect(encryptionKey, isNotEmpty);
          final contents = outputFile.readAsBytesSync();
          expect(contents, isNot(inputFile.readAsBytesSync()));
        },
      );

      test(
        'encryptString',
        () {
          final string = inputFile.readAsStringSync();
          final encryptionKey = encryptString(
            string: string,
            outputFile: outputFile,
          );
          expect(
            decryptFileString(file: outputFile, encryptionKey: encryptionKey),
            string,
          );
        },
      );

      test(
        'decryptFileString',
        () {
          final encryptionKey = encryptFile(
            inputFile: inputFile,
            outputFile: outputFile,
          );
          final string =
              decryptFileString(file: outputFile, encryptionKey: encryptionKey);
          expect(string, inputFile.readAsStringSync());
        },
      );

      test(
        'decryptFileBytes',
        () {
          final encryptionKey = encryptFile(
            inputFile: inputFile,
            outputFile: outputFile,
          );
          final bytes =
              decryptFileBytes(file: outputFile, encryptionKey: encryptionKey);
          expect(bytes, inputFile.readAsBytesSync());
        },
      );
    },
  );
}
