import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('AxisSetting', () {
    test('Initialise', () {
      const setting = AxisSetting(GameControllerAxis.leftx, 0.5, 500);
      expect(setting.axis, equals(GameControllerAxis.leftx));
      expect(setting.interval, equals(500));
      expect(setting.sensitivity, equals(0.5));
    });
  });
}
