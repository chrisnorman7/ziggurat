/// Provides the [SimpleSound] class.
import 'package:dart_synthizer/dart_synthizer.dart';

/// A simple sound.
class SimpleSound {
  /// Create an instance.
  SimpleSound({
    required this.source,
    required this.generator,
    this.reverb,
    this.echo,
  });

  /// The source to use.
  final Source source;

  /// The generator to use.
  final BufferGenerator generator;

  /// The reverb that [source] is connected to.
  GlobalFdnReverb? reverb;

  /// The echo that [source] is connected to.
  GlobalEcho? echo;
}
