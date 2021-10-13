/// Provides the [BoxCollision] class.
import '../levels/box_map_level.dart';
import 'box.dart';

/// This class specifies what should happen when a player collides with a [Box]
/// instance on a [BoxMapLevel].
class BoxCollision {
  /// Make an instance.
  const BoxCollision(this.distance, this.onCollide);

  /// The distance the player must be from this [Box] before [onCollide] is
  /// called.
  final double distance;

  /// The method that should be called when the player comes within [distance]
  /// of this [Box].
  final void Function(double distance) onCollide;
}
