import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/ziggurat.dart';

import '../helpers.dart';

void main() {
  group('DialogueLevel', () {
    test('Initialise', () {
      final game = Game('DialogueLevel');
      var done = 0;
      expect(
          () => DialogueLevel(game: game, messages: [], onDone: () => done++),
          throwsA(predicate((value) =>
              value is AssertionError &&
              value.message ==
                  'Both `ProgressControllerButton` and `progressScanCode` '
                      'cannot be `null`.')));
      const progressControllerButton = GameControllerButton.a;
      const progressScanCode = ScanCode.SCANCODE_RETURN;
      final dialogueLevel = DialogueLevel(
          game: game,
          messages: [],
          onDone: () => done++,
          progressControllerButton: progressControllerButton,
          progressScanCode: progressScanCode);
      expect(dialogueLevel.messages, isEmpty);
      expect(dialogueLevel.progressControllerButton,
          equals(GameControllerButton.a));
      expect(dialogueLevel.progressScanCode, equals(ScanCode.SCANCODE_RETURN));
      expect(dialogueLevel.position, isZero);
    });
    test('.progress', () {
      final game = Game('DialogueLevel.progress');
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
          progressControllerButton: GameControllerButton.a);
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
      final sdl = Sdl();
      final game = Game('DialogueLevel.handleSdlValue');
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
          progressScanCode: ScanCode.SCANCODE_RETURN,
          progressControllerButton: GameControllerButton.a);
      expect(done, isZero);
      expect(dialogueLevel.sound, isNull);
      expect(dialogueLevel.position, isZero);
      game.pushLevel(dialogueLevel);
      // Shouldn't work because we require `PressedState.pressed`.
      dialogueLevel.handleSdlEvent(makeKeyboardEvent(
          sdl, dialogueLevel.progressScanCode!, KeyCode.keycode_RETURN));
      expect(done, isZero);
      expect(dialogueLevel.position, equals(1));
      var sound = dialogueLevel.sound!;
      expect(sound.sound, equals(message1.sound));
      expect(sound.channel, equals(game.interfaceSounds.id));
      // Works because `state == PressedState.pressed`.
      dialogueLevel.handleSdlEvent(makeKeyboardEvent(
          sdl, dialogueLevel.progressScanCode!, KeyCode.keycode_RETURN,
          state: PressedState.pressed));
      expect(done, isZero);
      expect(game.currentLevel, equals(dialogueLevel));
      expect(dialogueLevel.position, equals(2));
      expect(dialogueLevel.sound, isNot(equals(sound)));
      sound = dialogueLevel.sound!;
      expect(sound.sound, equals(message2.sound));
      expect(sound.channel, equals(game.interfaceSounds.id));
      // Won't work.
      dialogueLevel.handleSdlEvent(makeControllerButtonEvent(
          sdl, dialogueLevel.progressControllerButton!));
      expect(done, isZero);
      expect(game.currentLevel, equals(dialogueLevel));
      expect(dialogueLevel.position, equals(2));
      expect(dialogueLevel.sound, equals(sound));
      // Works.
      final event = makeControllerButtonEvent(
          sdl, dialogueLevel.progressControllerButton!,
          state: PressedState.pressed);
      dialogueLevel.handleSdlEvent(event);
      expect(done, isZero);
      expect(game.currentLevel, equals(dialogueLevel));
      expect(dialogueLevel.position, equals(3));
      expect(dialogueLevel.sound, isNot(equals(sound)));
      sound = dialogueLevel.sound!;
      expect(sound.sound, equals(message3.sound));
      expect(sound.channel, equals(game.interfaceSounds.id));
      // Let's make sure `onDone` gets called.
      dialogueLevel.handleSdlEvent(event);
      expect(done, equals(1));
      expect(game.currentLevel, equals(dialogueLevel));
      expect(dialogueLevel.position, equals(3));
      expect(dialogueLevel.sound, equals(sound));
    });
    test('.onPush', () {
      final game = Game('DialogueLevel.onPush');
      const message =
          Message(keepAlive: true, sound: AssetReference.file('test.wav'));
      var dialogueLevel = DialogueLevel(
          game: game,
          messages: [message],
          onDone: () {},
          progressControllerButton: GameControllerButton.a);
      game.pushLevel(dialogueLevel);
      var sound = dialogueLevel.sound!;
      expect(sound.channel, equals(game.interfaceSounds.id));
      expect(sound.sound, equals(message.sound));
      final soundChannel = game.createSoundChannel();
      dialogueLevel = DialogueLevel(
          game: game,
          messages: [message],
          onDone: () {},
          progressControllerButton: GameControllerButton.a,
          soundChannel: soundChannel);
      game.pushLevel(dialogueLevel);
      sound = dialogueLevel.sound!;
      expect(sound.channel, equals(soundChannel.id));
      expect(sound.sound, equals(message.sound));
    });
  });
}
