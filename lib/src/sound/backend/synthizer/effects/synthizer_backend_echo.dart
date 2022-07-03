/// Provides the [SynthizerBackendEcho] class.
import 'package:dart_synthizer/dart_synthizer.dart';

import '../../effects/backend_echo.dart';
import '../synthizer_sound_backend.dart';

/// A synthizer echo.
class SynthizerBackendEcho implements BackendEcho {
  /// Create an instance.
  const SynthizerBackendEcho({
    required this.backend,
    required this.echo,
  });

  /// The backend to use.
  final SynthizerSoundBackend backend;

  /// The echo to work with.
  final GlobalEcho echo;

  @override
  void destroy() {
    echo.destroy();
  }

  @override
  void setTaps(final Iterable<EchoTap> taps) {
    echo.setTaps(
      taps
          .map<EchoTapConfig>(
            (final e) => EchoTapConfig(e.delay, e.gainL, e.gainR),
          )
          .toList(),
    );
  }

  @override
  void reset() {
    echo.reset();
  }
}
