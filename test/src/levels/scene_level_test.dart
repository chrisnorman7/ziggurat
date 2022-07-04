import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import '../../helpers.dart';

void main() {
  final sdl = Sdl();
  group('SceneLevel', () {
    test('Initialise', () {
      var done = 0;
      final game = Game(
        title: 'SceneLevel',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      const message = Message(text: 'Done.', keepAlive: true);
      const skipScanCode = ScanCode.return_;
      const skipControllerButton = GameControllerButton.a;
      var sceneLevel = SceneLevel(
        game: game,
        message: message,
        onDone: () => done++,
        skipScanCode: skipScanCode,
        skipControllerButton: skipControllerButton,
      );
      expect(sceneLevel.game, equals(game));
      expect(sceneLevel.message, equals(message));
      expect(sceneLevel.duration, isNull);
      expect(sceneLevel.skipControllerButton, equals(skipControllerButton));
      expect(sceneLevel.skipScanCode, equals(skipScanCode));
      expect(done, isZero);
      sceneLevel.onDone();
      expect(done, equals(1));
      sceneLevel = SceneLevel(
        game: game,
        message: message,
        onDone: () {},
        duration: 1234,
      );
      expect(sceneLevel.duration, equals(1234));
      expect(sceneLevel.skipControllerButton, isNull);
      expect(sceneLevel.skipScanCode, isNull);
      expect(
        () => SceneLevel(game: game, message: message, onDone: () {}),
        throwsA(
          predicate(
            (final value) =>
                value is AssertionError &&
                value.message ==
                    'At least one of `duration`, `skipControllerButton`, or '
                        '`skipScanCode` must not be null.',
          ),
        ),
      );
      expect(
        () => SceneLevel(
          game: game,
          message: const Message(),
          duration: 15,
          onDone: () {},
        ),
        throwsA(
          predicate(
            (final value) =>
                value is AssertionError &&
                value.message ==
                    'If `keepAlive` is not `true`, then `onPop` will not '
                        'function properly.',
          ),
        ),
      );
    });
    test('.skip', () {
      final game = Game(
        title: 'SceneLevel.skip',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      var done = 0;
      const message = Message(keepAlive: true);
      final sceneLevel = SceneLevel(
        game: game,
        message: message,
        onDone: () {
          done++;
          game.popLevel();
        },
        duration: 54321,
      );
      expect(done, isZero);
      game.pushLevel(sceneLevel);
      expect(game.tasks.length, equals(1));
      expect(game.tasks.first.value.func, equals(sceneLevel.onDone));
      expect(game.tasks.first.value.runAfter, equals(sceneLevel.duration));
      sceneLevel.skip();
      expect(done, equals(1));
      expect(game.currentLevel, isNull);
      expect(game.tasks, isEmpty);
    });
    test('.handleSdlValue', () {
      final game = Game(
        title: 'SceneLevel.handleSdlValue',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      var done = 0;
      const message = Message(keepAlive: true);
      final sceneLevel = SceneLevel(
        game: game,
        message: message,
        onDone: () => done++,
        skipScanCode: ScanCode.return_,
        skipControllerButton: GameControllerButton.a,
      );
      expect(done, isZero);
      game.pushLevel(sceneLevel);
      expect(sceneLevel.onDoneTask, isNull);
      sceneLevel.handleSdlEvent(
        makeKeyboardEvent(sdl, sceneLevel.skipScanCode!, KeyCode.return_),
      );
      expect(done, isZero);
      expect(game.currentLevel, equals(sceneLevel));
      sceneLevel.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          sceneLevel.skipScanCode!,
          KeyCode.return_,
          state: PressedState.pressed,
        ),
      );
      expect(done, equals(1));
      expect(game.currentLevel, equals(sceneLevel));
      sceneLevel.handleSdlEvent(
        makeControllerButtonEvent(sdl, sceneLevel.skipControllerButton!),
      );
      expect(done, equals(1));
      expect(game.currentLevel, equals(sceneLevel));
      sceneLevel.handleSdlEvent(
        makeControllerButtonEvent(
          sdl,
          sceneLevel.skipControllerButton!,
          state: PressedState.pressed,
        ),
      );
      expect(done, equals(2));
      expect(game.currentLevel, equals(sceneLevel));
    });
    test('.duration', () async {
      final game = Game(
        title: 'SceneLevel.duration',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      var done = 0;
      const duration = 3;
      final sceneLevel = SceneLevel(
        game: game,
        message: const Message(keepAlive: true),
        onDone: () {
          done++;
          game.popLevel();
        },
        duration: duration,
      );
      expect(sceneLevel.duration, duration);
      game.pushLevel(sceneLevel);
      expect(done, isZero);
      expect(game.tasks.length, 1);
      final runner = game.tasks.first;
      expect(runner.value, sceneLevel.onDoneTask);
      expect(runner.value.runAfter, duration);
      expect(runner.numberOfRuns, isZero);
      expect(runner.runAfter, isZero);
      for (var i = 1; i < duration; i++) {
        await game.tick(1);
        expect(done, isZero, reason: 'Done increments after $i');
        expect(game.tasks.length, equals(1));
        expect(game.tasks, contains(runner));
        expect(game.currentLevel, equals(sceneLevel));
        expect(runner.numberOfRuns, isZero);
        expect(runner.runAfter, i);
      }
      expect(runner.runAfter, duration - 1);
      await game.tick(1);
      expect(runner.numberOfRuns, 1);
      expect(runner.runAfter, isZero);
      expect(game.tasks, isEmpty);
      expect(done, equals(1));
      expect(game.currentLevel, isNull);
    });
    test('.onPush', () {
      final game = Game(
        title: 'SceneLevel.onPush',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      const message =
          Message(keepAlive: true, sound: AssetReference.file('test.wav'));
      var sceneLevel = SceneLevel(
        game: game,
        message: message,
        onDone: () {},
        duration: 1234,
      );
      game.pushLevel(sceneLevel);
      var sound = sceneLevel.sound!;
      expect(sound.channel, game.interfaceSounds);
      final soundChannel = game.createSoundChannel();
      sceneLevel = SceneLevel(
        game: game,
        message: message,
        onDone: () {},
        duration: 1234,
        soundChannel: soundChannel,
      );
      game.pushLevel(sceneLevel);
      sound = sceneLevel.sound!;
      expect(sound.channel, soundChannel);
    });
  });
}
