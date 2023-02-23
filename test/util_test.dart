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
        'generateEncryptionKey',
        () {
          expect(generateEncryptionKey(), isA<String>());
        },
      );

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
          final encryptionKey = generateEncryptionKey();
          expect(
            encryptBytes(
              bytes: inputFile.readAsBytesSync(),
              outputFile: outputFile,
              encryptionKey: encryptionKey,
            ),
            encryptionKey,
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
          final generatedEncryptionKey = generateEncryptionKey();
          expect(
            encryptFile(
              inputFile: inputFile,
              outputFile: outputFile,
              encryptionKey: generatedEncryptionKey,
            ),
            generatedEncryptionKey,
          );
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
          final generatedEncryptionKey = generateEncryptionKey();
          expect(
            encryptString(
              string: inputFile.readAsStringSync(),
              outputFile: outputFile,
              encryptionKey: generatedEncryptionKey,
            ),
            generatedEncryptionKey,
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
