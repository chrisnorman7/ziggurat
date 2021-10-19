import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

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
  MultiGridLevelGame()
      : messages = [],
        super('Test Game');

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
  PlaySound? outputMessage(Message message,
      {PlaySound? oldSound, SoundChannel? soundChannel}) {
    final context = OutputMessageContext(message, oldSound, soundChannel);
    messages.add(context);
    return super
        .outputMessage(message, oldSound: oldSound, soundChannel: soundChannel);
  }
}

void main() {
  group('MultiGridLevel', () {
    final game = MultiGridLevelGame();
    test('Initialise', () {
      var level = MultiGridLevel(
          game: game, title: Message(text: 'Test Level'), rows: []);
      expect(level.activateScanCode, equals(ScanCode.SCANCODE_SPACE));
      expect(level.axisDispatcher, isA<ControllerAxisDispatcher>());
      expect(level.cancelScanCode, equals(ScanCode.SCANCODE_ESCAPE));
      expect(level.currentRow, isNull);
      expect(level.downScanCode, equals(ScanCode.SCANCODE_DOWN));
      expect(level.horizontalPosition, isNull);
      expect(level.leftScanCode, equals(ScanCode.SCANCODE_LEFT));
      expect(level.onCancel, isNull);
      expect(level.rightScanCode, equals(ScanCode.SCANCODE_RIGHT));
      expect(level.rows, isEmpty);
      expect(level.title,
          predicate((value) => value is Message && value.text == 'Test Level'));
      expect(level.upScanCode, equals(ScanCode.SCANCODE_UP));
      expect(level.verticalPosition, isNull);
      level = MultiGridLevel(
          game: game,
          title: level.title,
          rows: level.rows,
          verticalPosition: 0,
          horizontalPosition: 1);
      expect(level.verticalPosition, isZero);
      expect(level.horizontalPosition, equals(1));
    });
    test('.currentRow', () {
      final row = MultiGridLevelRow(
          label: Message(),
          getNumberOfEntries: () => 2,
          getEntryLabel: (int value) => Message(text: value.toString()),
          onActivate: (int value) {});
      final level = MultiGridLevel(game: game, title: Message(), rows: [row]);
      expect(level.currentRow, isNull);
      level.verticalPosition = 0;
      expect(level.currentRow, equals(row));
      level.verticalPosition = null;
      expect(level.currentRow, isNull);
    });
    test('.showCurrent', () {
      final row = MultiGridLevelRow(
          label: Message(
              keepAlive: true,
              text: 'Test Row',
              sound: AssetReference.file('row.wav')),
          getNumberOfEntries: () => 3,
          getEntryLabel: (int value) => Message(
              keepAlive: true,
              sound: AssetReference.file('file$value.wav'),
              text: 'Entry $value'),
          onActivate: (int value) {},
          actions: [
            MultiGridLevelRowAction(
                Message(sound: AssetReference.file('action.wav')), () {})
          ]);
      final level = MultiGridLevel(
          game: game,
          title: Message(sound: AssetReference.file('sound.wav')),
          rows: [row]);
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
      final row1Messages = [Message(text: '1.0'), Message(text: '1.1')];
      final row2Messages = [
        Message(text: '2.0'),
        Message(text: '2.1'),
        Message(text: '2.2')
      ];
      final row1 = MultiGridLevelRow(
          label: Message(text: 'Row 1'),
          getNumberOfEntries: () => row1Messages.length,
          getEntryLabel: row1Messages.elementAt,
          onActivate: (int value) {},
          actions: [MultiGridLevelRowAction(Message(text: 'Action'), () {})]);
      final row2 = MultiGridLevelRow(
          label: Message(text: 'Row 2'),
          getNumberOfEntries: () => row2Messages.length,
          getEntryLabel: row2Messages.elementAt,
          onActivate: row1.onActivate);
      final level = MultiGridLevel(
          game: game, title: Message(text: 'Grid Level'), rows: [row1, row2]);
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
    });
  });
}
