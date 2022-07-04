/// Provides the [SilentSoundBackend] class.
import '../../../json/reverb_preset.dart';
import '../effects/backend_echo.dart';
import '../listener.dart';
import '../sound_backend.dart';
import '../sound_position.dart';
import 'effects/silent_backend_echo.dart';
import 'effects/silent_backend_reverb.dart';
import 'silent_sound_channel.dart';

/// A silent sound backend.
///
/// This backend is used primarily for testing.
class SilentSoundBackend implements SoundBackend {
  /// Create an instance.
  SilentSoundBackend({
    this.defaultPannerStrategy = DefaultPannerStrategy.stereo,
    this.listenerOrientation = const ListenerOrientation(0, 0, 0, 0, 0, 0),
    this.listenerPosition = const ListenerPosition(0, 0, 0),
  });

  @override
  DefaultPannerStrategy defaultPannerStrategy;

  @override
  ListenerOrientation listenerOrientation;

  @override
  ListenerPosition listenerPosition;

  @override
  SilentBackendEcho createEcho(final Iterable<EchoTap> taps) =>
      const SilentBackendEcho();

  @override
  SilentBackendReverb createReverb(final ReverbPreset preset) =>
      const SilentBackendReverb();

  @override
  SilentSoundChannel createSoundChannel({
    final SoundPosition position = unpanned,
    final double gain = 0.7,
  }) =>
      SilentSoundChannel(
        gain: gain,
        position: position,
      );

  @override
  void shutdown() {}
}
