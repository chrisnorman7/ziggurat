import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import '../helpers.dart';

/// A message context.
class OutputMessageContext {
  /// Create an instance.
  const OutputMessageContext(this.message, this.oldSound, this.soundChannel);

  /// The message that was output.
  final Message message;

  /// The old sound.
  final PlaySound? oldSound;

  /// The sound channel that was to be used.
  final SoundChannel? soundChannel;
}

class MultiGridLevelGame extends Game {
  /// Create an instance.
  MultiGridLevelGame({
    required super.sdl,
  })  : messages = [],
        super(title: 'Test Game');

  /// The messages that have been output.
  final List<OutputMessageContext> messages;

  /// Get the most recent context.
  OutputMessageContext get recentContext {
    if (messages.length != 1) {
      throw Exception('There are ${messages.length} messages.');
    }
    return messages.removeLast();
  }

  @override
  PlaySound? outputMessage(
    final Message message, {
    final PlaySound? oldSound,
    final SoundChannel? soundChannel,
  }) {
    final context = OutputMessageContext(message, oldSound, soundChannel);
    messages.add(context);
    return super
        .outputMessage(message, oldSound: oldSound, soundChannel: soundChannel);
  }
}

void main() {
  final sdl = Sdl();
  group('MultiGridLevel', () {
    final game = MultiGridLevelGame(sdl: sdl);
    const minValue = -32768;
    const maxValue = 32767;
    test('Initialise', () {
      var level = MultiGridLevel(
        game: game,
        title: const Message(text: 'Test Level'),
        rows: [],
      );
      expect(level.activateScanCode, equals(ScanCode.space));
      expect(level.axisDispatcher, isA<ControllerAxisDispatcher>());
      expect(level.cancelScanCode, equals(ScanCode.escape));
      expect(level.currentRow, isNull);
      expect(level.downScanCode, equals(ScanCode.down));
      expect(level.horizontalPosition, isNull);
      expect(level.leftScanCode, equals(ScanCode.left));
      expect(level.onCancel, isNull);
      expect(level.rightScanCode, equals(ScanCode.right));
      expect(level.rows, isEmpty);
      expect(
        level.title,
        predicate(
          (final value) => value is Message && value.text == 'Test Level',
        ),
      );
      expect(level.upScanCode, equals(ScanCode.up));
      expect(level.verticalPosition, isNull);
      level = MultiGridLevel(
        game: game,
        title: level.title,
        rows: level.rows,
        verticalPosition: 0,
        horizontalPosition: 1,
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(1));
    });
    test('.currentRow', () {
      final row = MultiGridLevelRow(
        label: const Message(),
        getNumberOfEntries: () => 2,
        getEntryLabel: (final value) => Message(text: value.toString()),
        onActivate: (final value) {},
      );
      final level =
          MultiGridLevel(game: game, title: const Message(), rows: [row]);
      expect(level.currentRow, isNull);
      level.verticalPosition = 0;
      expect(level.currentRow, equals(row));
      level.verticalPosition = null;
      expect(level.currentRow, isNull);
    });
    test('.showCurrent', () {
      final row = MultiGridLevelRow(
        label: const Message(
          keepAlive: true,
          text: 'Test Row',
          sound: AssetReference.file('row.wav'),
        ),
        getNumberOfEntries: () => 3,
        getEntryLabel: (final value) => Message(
          keepAlive: true,
          sound: AssetReference.file('file$value.wav'),
          text: 'Entry $value',
        ),
        onActivate: (final value) {},
        actions: [
          MultiGridLevelRowAction(
            const Message(sound: AssetReference.file('action.wav')),
            () {},
          )
        ],
      );
      final level = MultiGridLevel(
        game: game,
        title: const Message(sound: AssetReference.file('sound.wav')),
        rows: [row],
      );
      expect(level.verticalPosition, isNull);
      expect(level.currentRow, isNull);
      game.messages.clear();
      level.showCurrent();
      var context = game.recentContext;
      expect(context.message, equals(level.title));
      expect(context.oldSound, isNull);
      expect(context.soundChannel, isNull);
      level.verticalPosition = 0;
      expect(level.currentRow, equals(row));
      expect(game.messages, isEmpty);
      level.showCurrent();
      context = game.recentContext;
      expect(context.message, equals(row.label));
      expect(context.oldSound?.sound, equals(level.title.sound));
      expect(context.soundChannel, isNull);
      expect(level.horizontalPosition, isNull);
      level.right();
      expect(level.horizontalPosition, isZero);
      context = game.recentContext;
      final message = context.message;
      expect(message.text, equals('Entry 0'));
      expect(message.sound?.type, equals(AssetType.file));
      expect(message.sound?.name, equals('file0.wav'));
      expect(context.oldSound?.sound, equals(row.label.sound));
      level.left();
      expect(game.messages.length, equals(1));
      level.left();
      expect(level.horizontalPosition, equals(-1));
      expect(game.messages.length, equals(2));
      context = game.messages.removeLast();
      expect(context.message, equals(row.actions.first.label));
      expect(context.oldSound?.sound, equals(row.label.sound));
    });
    test('Movement', () {
      final row1Messages = [
        const Message(text: '1.0'),
        const Message(text: '1.1')
      ];
      final row2Messages = [
        const Message(text: '2.0'),
        const Message(text: '2.1'),
        const Message(text: '2.2')
      ];
      final row1 = MultiGridLevelRow(
        label: const Message(text: 'Row 1'),
        getNumberOfEntries: () => row1Messages.length,
        getEntryLabel: row1Messages.elementAt,
        onActivate: (final value) {},
        actions: [
          MultiGridLevelRowAction(const Message(text: 'Action'), () {})
        ],
      );
      final row2 = MultiGridLevelRow(
        label: const Message(text: 'Row 2'),
        getNumberOfEntries: () => row2Messages.length,
        getEntryLabel: row2Messages.elementAt,
        onActivate: row1.onActivate,
      );
      var level = MultiGridLevel(
        game: game,
        title: const Message(text: 'Grid Level'),
        rows: [row1, row2],
      );
      expect(level.verticalPosition, isNull);
      game.messages.clear();
      level.down();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.down();
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row2.label));
      level.down();
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row2.label));
      level.left();
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row2.label));
      level.right();
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row2Messages.first));
      level.down();
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row2Messages.first));
      level.right();
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(1));
      expect(game.recentContext.message, equals(row2Messages[1]));
      level.right();
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(2));
      expect(game.recentContext.message, equals(row2Messages.last));
      level.right();
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(2));
      expect(game.recentContext.message, equals(row2Messages.last));
      level.up();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.left();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      expect(game.recentContext.message, equals(row1.actions.first.label));
      level.left();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      expect(game.recentContext.message, equals(row1.actions.first.label));
      level.right();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.right();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row1Messages.first));
      level.right();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(1));
      expect(game.recentContext.message, equals(row1Messages.last));
      level.right();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(1));
      expect(game.recentContext.message, equals(row1Messages.last));
      level.left();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row1Messages.first));
      level.left();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.left();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      expect(game.recentContext.message, equals(row1.actions.first.label));
      level.up();
      expect(level.verticalPosition, isNull);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(level.title));
      level.down();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      level.down();
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(2));
      row1Messages.removeLast();
      level = MultiGridLevel(game: game, title: level.title, rows: level.rows)
        ..down()
        ..right();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isZero);
      level.right();
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isZero);
    });
    test('.handleSdlValue (scancode)', () {
      const keyCode = KeyCode.digit0;
      var cancelled = 0;
      final row1Messages = [
        const Message(text: '1.0'),
        const Message(text: '1.1')
      ];
      final row2Messages = [
        const Message(text: '2.0'),
        const Message(text: '2.1'),
        const Message(text: '2.2')
      ];
      final row1 = MultiGridLevelRow(
        label: const Message(text: 'Row 1'),
        getNumberOfEntries: () => row1Messages.length,
        getEntryLabel: row1Messages.elementAt,
        onActivate: (final value) {},
        actions: [
          MultiGridLevelRowAction(const Message(text: 'Action'), () {})
        ],
      );
      final row2 = MultiGridLevelRow(
        label: const Message(text: 'Row 2'),
        getNumberOfEntries: () => row2Messages.length,
        getEntryLabel: row2Messages.elementAt,
        onActivate: row1.onActivate,
      );
      final level = MultiGridLevel(
        game: game,
        title: const Message(text: 'Grid Level'),
        rows: [row1, row2],
        onCancel: () => cancelled++,
      );
      expect(level.verticalPosition, isNull);
      game.messages.clear();
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.downScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.downScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row2.label));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.downScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row2.label));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.leftScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row2.label));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.rightScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row2Messages.first));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.downScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row2Messages.first));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.rightScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(1));
      expect(game.recentContext.message, equals(row2Messages[1]));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.rightScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(2));
      expect(game.recentContext.message, equals(row2Messages.last));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.rightScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(2));
      expect(game.recentContext.message, equals(row2Messages.last));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.upScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.leftScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      expect(game.recentContext.message, equals(row1.actions.first.label));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.leftScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      expect(game.recentContext.message, equals(row1.actions.first.label));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.rightScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.rightScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row1Messages.first));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.rightScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(1));
      expect(game.recentContext.message, equals(row1Messages.last));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.rightScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(1));
      expect(game.recentContext.message, equals(row1Messages.last));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.leftScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row1Messages.first));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.leftScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.leftScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      expect(game.recentContext.message, equals(row1.actions.first.label));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.upScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isNull);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(level.title));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.downScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.downScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(2));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.cancelScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(cancelled, equals(1));
      level.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          level.cancelScanCode,
          keyCode,
          state: PressedState.pressed,
        ),
      );
      expect(cancelled, equals(2));
    });
    test('.handleSdlValue (axis)', () {
      var cancelled = 0;
      final upEvent =
          makeControllerAxisEvent(sdl, GameControllerAxis.lefty, minValue);
      final downEvent =
          makeControllerAxisEvent(sdl, GameControllerAxis.lefty, maxValue);
      final leftEvent =
          makeControllerAxisEvent(sdl, GameControllerAxis.leftx, minValue);
      final rightEvent =
          makeControllerAxisEvent(sdl, GameControllerAxis.leftx, maxValue);
      final row1Messages = [
        const Message(text: '1.0'),
        const Message(text: '1.1')
      ];
      final row2Messages = [
        const Message(text: '2.0'),
        const Message(text: '2.1'),
        const Message(text: '2.2')
      ];
      final row1 = MultiGridLevelRow(
        label: const Message(text: 'Row 1'),
        getNumberOfEntries: () => row1Messages.length,
        getEntryLabel: row1Messages.elementAt,
        onActivate: (final value) {},
        actions: [
          MultiGridLevelRowAction(const Message(text: 'Action'), () {})
        ],
      );
      final row2 = MultiGridLevelRow(
        label: const Message(text: 'Row 2'),
        getNumberOfEntries: () => row2Messages.length,
        getEntryLabel: row2Messages.elementAt,
        onActivate: row1.onActivate,
      );
      final level = MultiGridLevel(
        game: game,
        title: const Message(text: 'Grid Level'),
        rows: [row1, row2],
        onCancel: () => cancelled++,
        axisInterval: 0,
      );
      expect(level.verticalPosition, isNull);
      expect(level.horizontalPosition, isNull);
      game.messages.clear();
      level.handleSdlEvent(downEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.handleSdlEvent(downEvent);
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row2.label));
      level.handleSdlEvent(downEvent);
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row2.label));
      level.handleSdlEvent(leftEvent);
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row2.label));
      level.handleSdlEvent(rightEvent);
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row2Messages.first));
      level.handleSdlEvent(downEvent);
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row2Messages.first));
      level.handleSdlEvent(rightEvent);
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(1));
      expect(game.recentContext.message, equals(row2Messages[1]));
      level.handleSdlEvent(rightEvent);
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(2));
      expect(game.recentContext.message, equals(row2Messages.last));
      level.handleSdlEvent(rightEvent);
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(2));
      expect(game.recentContext.message, equals(row2Messages.last));
      level.handleSdlEvent(upEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.handleSdlEvent(leftEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      expect(game.recentContext.message, equals(row1.actions.first.label));
      level.handleSdlEvent(leftEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      expect(game.recentContext.message, equals(row1.actions.first.label));
      level.handleSdlEvent(rightEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.handleSdlEvent(rightEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row1Messages.first));
      level.handleSdlEvent(rightEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(1));
      expect(game.recentContext.message, equals(row1Messages.last));
      level.handleSdlEvent(rightEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(1));
      expect(game.recentContext.message, equals(row1Messages.last));
      level.handleSdlEvent(leftEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isZero);
      expect(game.recentContext.message, equals(row1Messages.first));
      level.handleSdlEvent(leftEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(row1.label));
      level.handleSdlEvent(leftEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      expect(game.recentContext.message, equals(row1.actions.first.label));
      level.handleSdlEvent(upEvent);
      expect(level.verticalPosition, isNull);
      expect(level.horizontalPosition, isNull);
      expect(game.recentContext.message, equals(level.title));
      level.handleSdlEvent(downEvent);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(-1));
      level.handleSdlEvent(downEvent);
      expect(level.verticalPosition, equals(1));
      expect(level.horizontalPosition, equals(2));
    });
    test('.onCancel', () {
      var cancelled = 0;
      final cancelEvent = makeControllerAxisEvent(
        sdl,
        GameControllerAxis.triggerleft,
        maxValue,
      );
      final row1Messages = [
        const Message(text: '1.0'),
        const Message(text: '1.1')
      ];
      final row2Messages = [
        const Message(text: '2.0'),
        const Message(text: '2.1'),
        const Message(text: '2.2')
      ];
      final row1 = MultiGridLevelRow(
        label: const Message(text: 'Row 1'),
        getNumberOfEntries: () => row1Messages.length,
        getEntryLabel: row1Messages.elementAt,
        onActivate: (final value) {},
        actions: [
          MultiGridLevelRowAction(const Message(text: 'Action'), () {})
        ],
      );
      final row2 = MultiGridLevelRow(
        label: const Message(text: 'Row 2'),
        getNumberOfEntries: () => row2Messages.length,
        getEntryLabel: row2Messages.elementAt,
        onActivate: row1.onActivate,
      );
      final level = MultiGridLevel(
        game: game,
        title: const Message(text: 'Grid Level'),
        rows: [row1, row2],
        onCancel: () => cancelled++,
        axisInterval: 0,
      );
      expect(cancelled, isZero);
      level.handleSdlEvent(cancelEvent);
      expect(cancelled, equals(1));
      level.handleSdlEvent(cancelEvent);
      expect(cancelled, equals(2));
      final cancelKeyboardEvent = makeKeyboardEvent(
        sdl,
        level.cancelScanCode,
        KeyCode.digit0,
        state: PressedState.pressed,
      );
      level.handleSdlEvent(cancelKeyboardEvent);
      expect(cancelled, equals(3));
      level.handleSdlEvent(cancelKeyboardEvent);
      expect(cancelled, equals(4));
    });
    test('.activate', () {
      var i = 0;
      var j = 0;
      var k = 0;
      final activateEvent = makeControllerAxisEvent(
        sdl,
        GameControllerAxis.triggerright,
        maxValue,
      );
      final row1Messages = [
        const Message(text: '1.0'),
        const Message(text: '1.1')
      ];
      final row2Messages = [
        const Message(text: '2.0'),
        const Message(text: '2.1'),
        const Message(text: '2.2')
      ];
      final row1 = MultiGridLevelRow(
        label: const Message(text: 'Row 1'),
        getNumberOfEntries: () => row1Messages.length,
        getEntryLabel: row1Messages.elementAt,
        onActivate: (final value) => i += value + 1,
        actions: [
          MultiGridLevelRowAction(const Message(text: 'Action'), () {})
        ],
      );
      final row2 = MultiGridLevelRow(
        label: const Message(text: 'Row 2'),
        getNumberOfEntries: () => row2Messages.length,
        getEntryLabel: row2Messages.elementAt,
        onActivate: (final value) => j += value + 1,
        actions: [MultiGridLevelRowAction(const Message(), () => k++)],
      );
      final level = MultiGridLevel(
        game: game,
        title: const Message(text: 'Grid Level'),
        rows: [row1, row2],
        axisInterval: 0,
      );
      final activateKeyboardEvent = makeKeyboardEvent(
        sdl,
        level.activateScanCode,
        KeyCode.digit0,
        state: PressedState.pressed,
      );
      expect(i, isZero);
      expect(j, isZero);
      level
        ..handleSdlEvent(activateKeyboardEvent)
        ..handleSdlEvent(activateEvent);
      expect(i, isZero);
      expect(j, isZero);
      level.down();
      expect(i, isZero);
      expect(j, isZero);
      level
        ..handleSdlEvent(activateKeyboardEvent)
        ..handleSdlEvent(activateEvent);
      expect(i, isZero);
      expect(j, isZero);
      level.right();
      expect(i, isZero);
      expect(j, isZero);
      level.handleSdlEvent(activateKeyboardEvent);
      expect(i, equals(1));
      expect(j, isZero);
      level.handleSdlEvent(activateEvent);
      expect(i, equals(2));
      expect(j, isZero);
      level.right();
      expect(i, equals(2));
      expect(j, isZero);
      level.handleSdlEvent(activateKeyboardEvent);
      expect(i, equals(4));
      expect(j, isZero);
      level.handleSdlEvent(activateEvent);
      expect(i, equals(6));
      expect(j, isZero);
      level.down();
      expect(i, equals(6));
      expect(j, isZero);
      level
        ..handleSdlEvent(activateKeyboardEvent)
        ..handleSdlEvent(activateEvent);
      expect(i, equals(6));
      expect(j, isZero);
      level.left();
      expect(i, equals(6));
      expect(j, isZero);
      level.handleSdlEvent(activateKeyboardEvent);
      expect(k, equals(1));
      level.handleSdlEvent(activateEvent);
      expect(k, equals(2));
      level
        ..right()
        ..right();
      expect(i, equals(6));
      expect(j, isZero);
      expect(k, equals(2));
      level.handleSdlEvent(activateEvent);
      expect(i, equals(6));
      expect(j, equals(1));
      level.handleSdlEvent(activateKeyboardEvent);
      expect(i, equals(6));
      expect(j, equals(2));
      level.right();
      expect(i, equals(6));
      expect(j, equals(2));
      level.handleSdlEvent(activateKeyboardEvent);
      expect(i, equals(6));
      expect(j, equals(4));
      level.handleSdlEvent(activateEvent);
      expect(i, equals(6));
      expect(j, equals(6));
    });
    test('defaultVerticalPosition', () {
      final row1 = MultiGridLevelRow.fromDict(const Message(), {});
      final row2 = MultiGridLevelRow.fromDict(const Message(), {});
      final level = MultiGridLevel(
        game: game,
        title: const Message(),
        rows: [row1, row2],
        verticalPosition: 1,
      );
      expect(level.currentRow, equals(row2));
      game.messages.clear();
      game.pushLevel(level);
      expect(game.messages.length, equals(1));
      expect(game.messages.first.message, equals(row2.label));
    });
  });
}
