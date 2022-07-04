/// Provides the [SoundBackend] class.
import '../../json/reverb_preset.dart';
import 'effects/backend_echo.dart';
import 'effects/backend_reverb.dart';
import 'listener.dart';
import 'sound_channel.dart';
import 'sound_position.dart';

/// A backend for playing sound.
abstract class SoundBackend {
  /// Get a channel with the given options.
  SoundChannel createSoundChannel({
    final SoundPosition position = unpanned,
    final double gain = 0.7,
  });

  /// Create a reverb.
  BackendReverb createReverb(final ReverbPreset preset);

  /// Create an echo.
  BackendEcho createEcho(final Iterable<EchoTap> taps);

  /// Get the listener position.
  ListenerPosition get listenerPosition;

  /// Set the listener position.
  set listenerPosition(final ListenerPosition value);

  /// Get the listener orientation.
  ListenerOrientation get listenerOrientation;

  /// Set the listener orientation.
  set listenerOrientation(final ListenerOrientation value);

  /// Get the default panner strategy.
  DefaultPannerStrategy get defaultPannerStrategy;

  /// Set the default panner strategy.
  set defaultPannerStrategy(final DefaultPannerStrategy value);

  /// Shut down this sound backend.
  void shutdown();
}
