import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import '../../helpers.dart';

void main() {
  final sdl = Sdl();
  group('DialogueLevel', () {
    test('Initialise', () {
      final game = Game(
        title: 'DialogueLevel',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      var done = 0;
      expect(
        () => DialogueLevel(game: game, messages: [], onDone: () => done++),
        throwsA(
          predicate(
            (final value) =>
                value is AssertionError &&
                value.message ==
                    'Both `ProgressControllerButton` and `progressScanCode` '
                        'cannot be `null`.',
          ),
        ),
      );
      const progressControllerButton = GameControllerButton.a;
      const progressScanCode = ScanCode.return_;
      final dialogueLevel = DialogueLevel(
        game: game,
        messages: [],
        onDone: () => done++,
        progressControllerButton: progressControllerButton,
        progressScanCode: progressScanCode,
      );
      expect(dialogueLevel.messages, isEmpty);
      expect(
        dialogueLevel.progressControllerButton,
        equals(GameControllerButton.a),
      );
      expect(dialogueLevel.progressScanCode, equals(ScanCode.return_));
      expect(dialogueLevel.position, isZero);
    });
    test('.progress', () {
      final sdl = Sdl();
      final game = Game(
        title: 'DialogueLevel.progress',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      var done = 0;
      const message1 = Message(keepAlive: true);
      const message2 = Message(keepAlive: true);
      final dialogueLevel = DialogueLevel(
        game: game,
        messages: [message1, message2],
        onDone: () {
          done++;
          game.popLevel();
        },
        progressControllerButton: GameControllerButton.a,
      );
      expect(done, isZero);
      game.pushLevel(dialogueLevel);
      expect(done, isZero);
      expect(dialogueLevel.position, equals(1));
      dialogueLevel.progress();
      expect(done, isZero);
      expect(dialogueLevel.position, equals(2));
      dialogueLevel.progress();
      expect(done, equals(1));
      expect(dialogueLevel.position, equals(2));
      expect(game.currentLevel, isNull);
    });
    test('.handleSdlValue', () {
      final game = Game(
        title: 'DialogueLevel.handleSdlValue',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      var done = 0;
      const message1 =
          Message(keepAlive: true, sound: AssetReference.file('file1.wav'));
      const message2 =
          Message(keepAlive: true, sound: AssetReference.file('file2.wav'));
      const message3 =
          Message(keepAlive: true, sound: AssetReference.file('file3.wav'));
      final dialogueLevel = DialogueLevel(
        game: game,
        messages: [message1, message2, message3],
        onDone: () => done++,
        progressScanCode: ScanCode.return_,
        progressControllerButton: GameControllerButton.a,
      );
      expect(done, isZero);
      expect(dialogueLevel.sound, isNull);
      expect(dialogueLevel.position, isZero);
      game.pushLevel(dialogueLevel);
      // Shouldn't work because we require `PressedState.pressed`.
      dialogueLevel.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          dialogueLevel.progressScanCode!,
          KeyCode.return_,
        ),
      );
      expect(done, isZero);
      expect(dialogueLevel.position, equals(1));
      var sound = dialogueLevel.sound;
      expect(sound, isNotNull);
      // Works because `state == PressedState.pressed`.
      dialogueLevel.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          dialogueLevel.progressScanCode!,
          KeyCode.return_,
          state: PressedState.pressed,
        ),
      );
      expect(done, isZero);
      expect(game.currentLevel, equals(dialogueLevel));
      expect(dialogueLevel.position, equals(2));
      expect(dialogueLevel.sound, isNot(equals(sound)));
      sound = dialogueLevel.sound;
      // Won't work.
      dialogueLevel.handleSdlEvent(
        makeControllerButtonEvent(
          sdl,
          dialogueLevel.progressControllerButton!,
        ),
      );
      expect(done, isZero);
      expect(game.currentLevel, equals(dialogueLevel));
      expect(dialogueLevel.position, equals(2));
      expect(dialogueLevel.sound, equals(sound));
      // Works.
      final event = makeControllerButtonEvent(
        sdl,
        dialogueLevel.progressControllerButton!,
        state: PressedState.pressed,
      );
      dialogueLevel.handleSdlEvent(event);
      expect(done, isZero);
      expect(game.currentLevel, equals(dialogueLevel));
      expect(dialogueLevel.position, equals(3));
      expect(dialogueLevel.sound, isNot(equals(sound)));
      sound = dialogueLevel.sound;
      // Let's make sure `onDone` gets called.
      dialogueLevel.handleSdlEvent(event);
      expect(done, equals(1));
      expect(game.currentLevel, equals(dialogueLevel));
      expect(dialogueLevel.position, equals(3));
      expect(dialogueLevel.sound, equals(sound));
    });
    test('.onPush', () {
      final game = Game(
        title: 'DialogueLevel.onPush',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      const message =
          Message(keepAlive: true, sound: AssetReference.file('test.wav'));
      var dialogueLevel = DialogueLevel(
        game: game,
        messages: [message],
        onDone: () {},
        progressControllerButton: GameControllerButton.a,
      );
      game.pushLevel(dialogueLevel);
      expect(dialogueLevel.sound, isNotNull);
      final soundChannel = game.createSoundChannel();
      dialogueLevel = DialogueLevel(
        game: game,
        messages: [message],
        onDone: () {},
        progressControllerButton: GameControllerButton.a,
        soundChannel: soundChannel,
      );
      game.pushLevel(dialogueLevel);
      expect(dialogueLevel.sound, isNotNull);
    });
  });
}
