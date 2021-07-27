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

  /// Get a string representation of the state.
  @override
  String getStateString(QuestStates state) {
    switch (state) {
      case QuestStates.notStarted:
        return 'Not started';
      case QuestStates.accepted:
        return 'Find the test item';
      case QuestStates.firstItemFound:
        return 'Find the second test item';
      case QuestStates.completed:
        return 'Completed';
    }
  }
}

void main() {
  group('Quests test', () {
    final TestQuest q = TestQuest();
    test('Initialisation test', () {
      expect(q.defaultState, equals(QuestStates.notStarted));
    });
    test('getStateString tests', () {
      expect(q.getStateString(QuestStates.notStarted), equals('Not started'));
      expect(q.getStateString(QuestStates.completed), equals('Completed'));
    });
  });
}
