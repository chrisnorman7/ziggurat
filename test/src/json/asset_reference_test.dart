import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('AssetReference', () {
    test('.file', () {
      const sound = AssetReference.file('test.wav');
      expect(sound.name, equals('test.wav'));
      expect(sound.type, equals(AssetType.file));
    });
    test('.collection', () {
      const sound = AssetReference.collection('testing');
      expect(sound.name, equals('testing'));
      expect(sound.type, equals(AssetType.collection));
    });
  });
}
