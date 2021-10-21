/// Provides classes relating to multi grids.
import 'json/message.dart';
import 'levels/multi_grid_level.dart';

/// An action in a [MultiGridLevelRow].
///
/// Actions appear before the list of entries.
class MultiGridLevelRowAction {
  /// Create an instance.
  const MultiGridLevelRowAction(this.label, this.func);

  /// The label of this action.
  final Message label;

  /// The method to call when this action is activated.
  final void Function() func;
}

/// A row in a [MultiGridLevel].
class MultiGridLevelRow {
  /// Create an instance.
  const MultiGridLevelRow(
      {required this.label,
      required this.getNumberOfEntries,
      required this.getEntryLabel,
      required this.onActivate,
      this.actions = const []});

  /// Create an instance with a dictionary of [commands]:
  factory MultiGridLevelRow.fromDict(
          Message label, Map<Message, void Function(int index)> commands,
          {List<MultiGridLevelRowAction>? actions}) =>
      MultiGridLevelRow(
          label: label,
          getNumberOfEntries: () => commands.length,
          getEntryLabel: (int value) => commands.keys.elementAt(value),
          onActivate: (int index) => commands.values.elementAt(index)(index),
          actions: actions ?? []);

  /// The label of this row.
  ///
  /// This value will be shown between the list of [actions], and the contents
  /// of this row.
  final Message label;

  /// A function which should return the maximum number of entries in this row.
  ///
  /// If not using something like the length of a list, it is important to note
  /// this value must be the number of entries + 1.
  final int Function() getNumberOfEntries;

  /// A function that should return a label for the entry at the given `index`.
  ///
  /// The result of this function will be used when moving through the list of
  /// the entries for this row.
  final Message Function(int index) getEntryLabel;

  /// The function that will be called when the current entry is activated.
  ///
  /// This function will be called when an entry on this row is selected, and
  /// the index of the value will be passed.
  final void Function(int index) onActivate;

  /// The list of actions supported by this row.
  ///
  /// These actions will be shown to the left of [label].
  final List<MultiGridLevelRowAction> actions;
}
