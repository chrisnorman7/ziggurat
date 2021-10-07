/// Test the [Quest] class.
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

/// Pretend quest states.
enum QuestStates {
  /// Quest hasn't been started.
  notStarted,

  /// Quest has been accepted.
  accepted,

  /// First item has been found.
  firstItemFound,

  /// The quest has been completed.
  completed,
}

/// A test.
class TestQuest extends Quest<QuestStates> {
  const TestQuest() : super(QuestStates.notStarted);

  /// Get a message to tell the player about the current state.
  @override
  Message getStateMessage(QuestStates state) {
    switch (state) {
      case QuestStates.notStarted:
        return Message(
            text: 'Not started',
            sound: AssetReference.file('quest_started.wav'));
      case QuestStates.accepted:
        return Message(
            text: 'Find the first item',
            sound: AssetReference.file('first_item.wav'));
      case QuestStates.firstItemFound:
        return Message(
            text: 'Find the second item',
            sound: AssetReference.file('second_item.wav'));
      case QuestStates.completed:
        return Message(
            text: 'Completed',
            sound: AssetReference.file('quest_completed.wav'));
    }
  }
}

void main() {
  group('Quest', () {
    final TestQuest q = TestQuest();
    test('Initialisation', () {
      expect(q.defaultState, equals(QuestStates.notStarted));
    });
    test('.getStateMessage', () {
      var message = q.getStateMessage(QuestStates.notStarted);
      expect(message, isA<Message>());
      expect(message.text, equals('Not started'));
      message = q.getStateMessage(QuestStates.completed);
      expect(message.text, equals('Completed'));
    });
  });
}
