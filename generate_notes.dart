/// Generated the `notes.dart` file.
import 'dart:io';
import 'dart:math';

/// A4.
const a4 = 440.0;

/// The note names.
const noteNames = {
  'c': -9,
  'cSharp': -8,
  'd': -7,
  'dSharp': -6,
  'e': -5,
  'f': -4,
  'fSharp': -3,
  'g': -2,
  'gSharp': -1,
  'a': 0,
  'aSharp': 1,
  'b': 2,
};

/// Run the program.
void main() {
  final stringBuffer = StringBuffer()
    ..writeln('/// Note values for playing waves.')
    ..writeln('library notes;');
  final a = pow(2.0, 1.0 / 12.0);
  var referencePitch = a4 / 8;
  var octaveNumber = 1;
  while (octaveNumber < 7) {
    for (final entry in noteNames.entries) {
      final noteName = entry.key;
      final difference = entry.value;
      final frequency = referencePitch * pow(a, difference);
      stringBuffer
        ..writeln()
        ..writeln('/// $noteName $octaveNumber.')
        ..writeln('const $noteName$octaveNumber = $frequency;');
    }
    octaveNumber++;
    referencePitch *= 2;
  }
  File('lib/notes.dart').writeAsStringSync(stringBuffer.toString());
}
