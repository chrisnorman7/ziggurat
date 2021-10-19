/// Provides exports relating to sound.
///
/// It is worth noting that Ziggurat does not generate any sound on it's own.
/// For that you need a package like
/// [ziggurat_sounds](https://pub.dev/packages/ziggurat_sounds).
library sound;

export 'src/sound/ambiance.dart';
export 'src/sound/events/automation_fade.dart';
export 'src/sound/events/events_base.dart';
export 'src/sound/events/global.dart';
export 'src/sound/events/playback.dart';
export 'src/sound/events/reverb.dart';
export 'src/sound/events/sound_channel.dart';
export 'src/sound/events/sound_channel_filter.dart';
export 'src/sound/events/sound_channel_group.dart';
export 'src/sound/events/sound_position.dart';
export 'src/sound/random_sound.dart';
export 'src/sound/reverb_preset.dart';
