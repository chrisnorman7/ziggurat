/// Provides the [Door] class.
import '../box.dart';
import '../message.dart';
import '../runner.dart';
import 'actors/actor.dart';
import 'base.dart';

/// The door box type.
class Door extends BoxType {
  /// Create a door.
  Door(
      {this.open = true,
      this.closeAfter,
      this.openMessage,
      this.closeMessage,
      this.collideMessage});

  /// Whether or not this door is open.
  bool open;

  /// If this value is not `null`, this door will automatically close after the
  /// specified time.
  final Duration? closeAfter;

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

  /// Returns `true` if this door should open for [actor].
  ///
  /// Be aware that [actor] may not always be the player.
  bool shouldOpen(Box<Actor> actor) => true;
}
