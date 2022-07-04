/// Provides exports relating to sound.
///
/// Sounds are provided by way of a [SoundBackend] instance. By default, two
/// backends are implemented:
///
/// * The [SynthizerSoundBackend] class uses the
///   [synthizer](https://synthizer.github.io/) library.
/// * The [SilentSoundBackend] classes produces no sound, and is useful for
///   testing.
///
/// If you wish to implement your own sound backend, you must implement the
/// [SoundBackend] class, and all required machinery.
library sound;

import 'src/sound/backend/silent/silent_sound_backend.dart';
import 'src/sound/backend/sound_backend.dart';
import 'src/sound/backend/synthizer/synthizer_sound_backend.dart';

export 'src/json/ambiance.dart';
export 'src/json/music.dart';
export 'src/json/random_sound.dart';
export 'src/json/reverb_preset.dart';
export 'src/sound/_sound.dart';
