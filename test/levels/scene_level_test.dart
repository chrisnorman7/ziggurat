import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/ziggurat.dart';

import '../helpers.dart';

void main() {
  group('SceneLevel', () {
    test('Initialise', () {
      var done = 0;
      final game = Game('SceneLevel');
      const message = Message(text: 'Done.', keepAlive: true);
      const skipScanCode = ScanCode.SCANCODE_RETURN;
      const skipControllerButton = GameControllerButton.a;
      var sceneLevel = SceneLevel(
          game: game,
          message: message,
          onDone: () => done++,
          skipScanCode: skipScanCode,
          skipControllerButton: skipControllerButton);
      expect(sceneLevel.game, equals(game));
      expect(sceneLevel.message, equals(message));
      expect(sceneLevel.duration, isNull);
      expect(sceneLevel.skipControllerButton, equals(skipControllerButton));
      expect(sceneLevel.skipScanCode, equals(skipScanCode));
      expect(done, isZero);
      sceneLevel.onDone();
      expect(done, equals(1));
      sceneLevel = SceneLevel(
          game: game, message: message, onDone: () {}, duration: 1234);
      expect(sceneLevel.duration, equals(1234));
      expect(sceneLevel.skipControllerButton, isNull);
      expect(sceneLevel.skipScanCode, isNull);
      expect(
          () => SceneLevel(game: game, message: message, onDone: () {}),
          throwsA(predicate((value) =>
              value is AssertionError &&
              value.message ==
                  'At least one of `duration`, `skipControllerButton`, or '
                      '`skipScanCode` must not be null.')));
      expect(
          () => SceneLevel(
              game: game, message: Message(), duration: 15, onDone: () {}),
          throwsA(predicate((value) =>
              value is AssertionError &&
              value.message ==
                  'If `keepAlive` is not `true`, then `onPop` will not '
                      'function properly.')));
    });
    test('.skip', () {
      final game = Game('SceneLevel.skip');
      var done = 0;
      const message = Message(keepAlive: true);
      final sceneLevel = SceneLevel(
          game: game,
          message: message,
          onDone: () {
            done++;
            game.popLevel();
          },
          duration: 54321);
      expect(done, isZero);
      game.pushLevel(sceneLevel);
      expect(game.tasks.length, equals(1));
      expect(game.tasks.first.func, equals(sceneLevel.onDone));
      expect(game.tasks.first.runWhen, equals(sceneLevel.duration));
      sceneLevel.skip();
      expect(done, equals(1));
      expect(game.currentLevel, isNull);
      expect(game.tasks, isEmpty);
    });
    test('.handleSdlValue', () {
      final sdl = Sdl();
      final game = Game('SceneLevel.handleSdlValue');
      var done = 0;
      const message = Message(keepAlive: true);
      final sceneLevel = SceneLevel(
          game: game,
          message: message,
          onDone: () => done++,
          skipScanCode: ScanCode.SCANCODE_RETURN,
          skipControllerButton: GameControllerButton.a);
      expect(done, isZero);
      game.pushLevel(sceneLevel);
      sceneLevel.handleSdlEvent(makeKeyboardEvent(
          sdl, sceneLevel.skipScanCode!, KeyCode.keycode_RETURN));
      expect(done, isZero);
      expect(game.currentLevel, equals(sceneLevel));
      sceneLevel.handleSdlEvent(makeKeyboardEvent(
          sdl, sceneLevel.skipScanCode!, KeyCode.keycode_RETURN,
          state: PressedState.pressed));
      expect(done, equals(1));
      expect(game.currentLevel, equals(sceneLevel));
      sceneLevel.handleSdlEvent(
          makeControllerButtonEvent(sdl, sceneLevel.skipControllerButton!));
      expect(done, equals(1));
      expect(game.currentLevel, equals(sceneLevel));
      sceneLevel.handleSdlEvent(makeControllerButtonEvent(
          sdl, sceneLevel.skipControllerButton!,
          state: PressedState.pressed));
      expect(done, equals(2));
      expect(game.currentLevel, equals(sceneLevel));
    });
    test('.duration', () {
      final sdl = Sdl();
      final game = Game('SceneLevel.duration');
      var done = 0;
      final sceneLevel = SceneLevel(
          game: game,
          message: Message(keepAlive: true),
          onDone: () {
            done++;
            game.popLevel();
          },
          duration: 3);
      game.pushLevel(sceneLevel);
      expect(done, isZero);
      for (var i = 0; i <= sceneLevel.duration!; i++) {
        game
          ..tick(sdl, 1)
          ..time = i;
        expect(done, isZero, reason: 'Done increments after $i');
        expect(game.tasks.length, equals(1));
        expect(game.currentLevel, equals(sceneLevel));
      }
      game.time++;
      game.tick(sdl, 1);
      expect(game.tasks, isEmpty);
      expect(done, equals(1));
      expect(game.currentLevel, isNull);
    });
    test('.onPush', () {
      final game = Game('SceneLevel.onPush');
      const message =
          Message(keepAlive: true, sound: AssetReference.file('test.wav'));
      var sceneLevel = SceneLevel(
          game: game, message: message, onDone: () {}, duration: 1234);
      game.pushLevel(sceneLevel);
      var sound = sceneLevel.sound!;
      expect(sound.channel, equals(game.interfaceSounds.id));
      expect(sound.sound, equals(message.sound));
      final soundChannel = game.createSoundChannel();
      sceneLevel = SceneLevel(
          game: game,
          message: message,
          onDone: () {},
          duration: 1234,
          soundChannel: soundChannel);
      game.pushLevel(sceneLevel);
      sound = sceneLevel.sound!;
      expect(sound.channel, equals(soundChannel.id));
    });
  });
}
