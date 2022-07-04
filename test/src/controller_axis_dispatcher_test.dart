import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

/// Do nothing.
void f(final double value) {}

void main() {
  group('ControllerAxisDispatcher', () {
    test('Initialise', () {
      var dispatcher = ControllerAxisDispatcher({});
      expect(dispatcher.axes, isEmpty);
      expect(dispatcher.axisSensitivity, equals(0.5));
      expect(dispatcher.functionInterval, equals(400));
      dispatcher = ControllerAxisDispatcher({GameControllerAxis.leftx: f});
      expect(dispatcher.axes.length, equals(1));
      expect(dispatcher.axes[GameControllerAxis.leftx], equals(f));
    });
    test('.handleAxisValue', () async {
      var d = 0.0;
      final dispatcher = ControllerAxisDispatcher({
        GameControllerAxis.leftx: (final value) => d -= value,
        GameControllerAxis.rightx: (final value) => d += value
      });
      expect(dispatcher.axes.length, equals(2));
      expect(d, isZero);
      dispatcher.handleAxisValue(GameControllerAxis.triggerleft, 0.1);
      expect(d, isZero);
      dispatcher.handleAxisValue(GameControllerAxis.triggerleft, 5.0);
      expect(d, isZero);
      dispatcher.handleAxisValue(
        GameControllerAxis.leftx,
        dispatcher.axisSensitivity,
      );
      expect(d, equals(-dispatcher.axisSensitivity));
      dispatcher.handleAxisValue(
        GameControllerAxis.rightx,
        dispatcher.axisSensitivity,
      );
      expect(d, equals(-dispatcher.axisSensitivity));
      await Future<void>.delayed(
        Duration(milliseconds: dispatcher.functionInterval + 1),
      );
      dispatcher.handleAxisValue(GameControllerAxis.rightx, 1.0);
      expect(d, equals(0.5));
      dispatcher.handleAxisValue(
        GameControllerAxis.leftx,
        dispatcher.axisSensitivity,
      );
      expect(d, equals(0.5));
    });
  });
}
