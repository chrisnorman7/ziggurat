import 'package:test/test.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/src/game.dart';

void main() {
  final game = Game('Sound Event Tests');
  group(
    'automation_fade.dart',
    () {
      test(
        'AutomationFade',
        () {
          final fade = AutomationFade(
            game: game,
            id: 5,
            preFade: 0.2,
            fadeLength: 5.0,
            startGain: 1.0,
            endGain: 0.0,
          );
          expect(
            fade.toString(),
            '<AutomationFade id: 5, from: 1.0, pre fade: 0.2, length: 5.0, '
            'end gain: 0.0>',
          );
        },
      );
      test(
        'CancelAutomationFade',
        () {
          const cancelFade = CancelAutomationFade(9);
          expect(
            cancelFade.toString(),
            '<CancelAutomationFade id: 9>',
          );
        },
      );
    },
  );
  group(
    'global.dart',
    () {
      test(
        'ListenerPositionEvent',
        () {
          const event = ListenerPositionEvent(5.0, 9.0, 22.0);
          expect(
            event.toString(),
            '<ListenerPositionEvent x: 5.0, y: 9.0, z: 22.0>',
          );
        },
      );
      test(
        'ListenerOrientationEvent',
        () {
          const event = ListenerOrientationEvent(1.0, 2.0, 3.0, 4.0, 5.0, 6.0);
          expect(
            event.toString(),
            '<ListenerOrientationEvent x1: 1.0, y1: 2.0, z1: 3.0, '
            'x2: 4.0, y2: 5.0, z2: 6.0>',
          );
        },
      );
      test(
        'SetDefaultPannerStrategy',
        () {
          const event = SetDefaultPannerStrategy(DefaultPannerStrategy.hrtf);
          expect(
            event.toString(),
            '<SetDefaultPannerStrategy strategy: DefaultPannerStrategy.hrtf>',
          );
        },
      );
    },
  );
}
