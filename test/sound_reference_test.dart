import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group(
      'Test the SoundReference class',
      () => test('Initialisation', () {
            var sr = SoundReference('test', SoundType.file);
            expect(sr.name, equals('test'));
            expect(sr.type, equals(SoundType.file));
            sr = SoundReference.collection('collection');
            expect(sr.name, equals('collection'));
            expect(sr.type, equals(SoundType.collection));
            sr = SoundReference.file('file');
            expect(sr.name, equals('file'));
            expect(sr.type, equals(SoundType.file));
          }));
}
