/// Provides the [Actor] class.
import '../base.dart';
import 'npc.dart';
import 'player.dart';

/// A generic actor.
///
/// This class should be subclassed whenever something that is moved is
/// required.
///
/// The most obvious subclasses are [Player] and [NonPlayerCharacter].
class Actor extends BoxType {}
