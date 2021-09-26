import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group(
      'Test the SoundReference class',
      () => test('Initialisation', () {
            var sr = SoundReference('test', SoundType.file);
            expect(sr.name, equals('test'));
            expect(sr.type, equals(SoundType.file));
            expect(sr.encryptionKey, isNull);
            sr = SoundReference.collection('collection');
            expect(sr.name, equals('collection'));
            expect(sr.type, equals(SoundType.collection));
            expect(sr.encryptionKey, isNull);
            sr = SoundReference.file('file');
            expect(sr.name, equals('file'));
            expect(sr.type, equals(SoundType.file));
            expect(sr.encryptionKey, isNull);
            sr = SoundReference.collection('collection',
                encryptionKey: 'asdf123');
            expect(sr.name, equals('collection'));
            expect(sr.type, equals(SoundType.collection));
            expect(sr.encryptionKey, equals('asdf123'));
            sr = SoundReference.file('file', encryptionKey: 'asdf123');
            expect(sr.name, equals('file'));
            expect(sr.type, equals(SoundType.file));
            expect(sr.encryptionKey, equals('asdf123'));
          }));
}
