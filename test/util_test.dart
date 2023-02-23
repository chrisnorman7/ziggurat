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

      test(
        'encryptFile',
        () {
          final encryptionKey =
              encryptFile(inputFile: inputFile, outputFile: outputFile);
          expect(encryptionKey, isNotEmpty);
          final contents =
              decryptFile(file: outputFile, encryptionKey: encryptionKey);
          expect(contents, inputFile.readAsStringSync());
          outputFile.deleteSync(recursive: true);
        },
      );
    },
  );
}
