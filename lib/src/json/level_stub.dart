/// Provides the [LevelStub] class.
import 'ambiance.dart';
import 'random_sound.dart';

/// A stub which can be used to create a basic level.
///
/// Stubs can also be used with more complimented invocations of level
/// subclasses by simply accessing the [ambiances] and [randomSounds]
/// properties.
class LevelStub {
  /// Create an instance.
  const LevelStub(this.ambiances, this.randomSounds);

  /// The ambiances for this stub.
  final List<Ambiance> ambiances;

  /// The random sounds for this stub.
  final List<RandomSound> randomSounds;
}
