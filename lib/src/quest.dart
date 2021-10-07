/// Provides the [Quest] class.
import 'package:meta/meta.dart';

import 'json/message.dart';

/// A quest.
///
/// All in-game quests should subclass this class.
///
/// A quest has a type which is used for quest progress. This type should
/// probably be an enum, but could be anything.
@immutable
class Quest<T> {
  /// Create a quest.
  const Quest(this.defaultState);

  /// The default state for this quest.
  final T defaultState;

  /// Return the given [state] as a string.
  Message getStateMessage(T state) => Message(text: state.toString());
}
