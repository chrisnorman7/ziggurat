/// Provides the [Door] class.
import 'dart:math';

import '../../json/message.dart';
import '../../runner.dart';
import '../../sound/reverb_preset.dart';
import '../box.dart';
import 'agents/agent.dart';
import 'wall.dart';

/// The door box type.
class Door extends Wall {
  /// Create a door.
  Door(
      {ReverbPreset? reverbPreset,
      this.open = true,
      this.closeAfter,
      this.openMessage,
      this.closeMessage,
      this.collideMessage,
      double filterFrequency = 20000})
      : super(reverbPreset: reverbPreset, filterFrequency: filterFrequency);

  /// Whether or not this door is open.
  bool open;

  /// The number of milliseconds before this door closes automatically.
  final int? closeAfter;

  /// The time after which this door should close.
  ///
  /// This is only used if [closeAfter] is not `null`.
  int? closeWhen;

  /// The coordinates the close sound should play at.
  Point<double>? closeCoordinates;

  /// The message to be shown when this door opens.
  final Message? openMessage;

  /// The message to be shown when this door closes.
  final Message? closeMessage;

  /// The message which is shown when someone (maybe the player) collides with
  /// it.
  final Message? collideMessage;

  /// A function to be called when this door is opened.
  ///
  /// This function is given the [runner] which is running the game, as well as
  /// the [box] this door is attached to.
  void onOpen(Runner runner, Box<Door> box) {}

  /// A function to be called when this door is closed.
  ///
  /// This function is given the [runner] which is running the game, as well as
  /// the [box] this door is attached to.
  void onClose(Runner runner, Box<Door> box) {}

  /// Returns `true` if this door should open for [agent].
  ///
  /// Be aware that [agent] may not always be the player.
  ///
  /// If this method returns `false`, [collideMessage] will be used.
  bool shouldOpen(Box<Agent> agent) => true;
}
