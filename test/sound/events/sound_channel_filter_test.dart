import 'package:test/test.dart';
import 'package:ziggurat/sound.dart';

void main() {
  group(
    'sound_channel_filter.dart',
    () {
      test(
        'SoundChannelFilter',
        () {
          const event = SoundChannelFilter(4321);
          expect(event.toString(), '<SoundChannelFilter id: 4321>');
        },
      );
      test(
        'SoundChannelLowpass',
        () {
          const event = SoundChannelLowpass(1, 440.0, 0.98);
          expect(
            event.toString(),
            '<SoundChannelLowpass id: 1, frequency: 440.0, q: 0.98>',
          );
        },
      );
      test(
        'SoundChannelHighpass',
        () {
          const event = SoundChannelHighpass(1, 440.0, 0.98);
          expect(
            event.toString(),
            '<SoundChannelHighpass id: 1, frequency: 440.0, q: 0.98>',
          );
        },
      );
      test(
        'SoundChannelBandpass',
        () {
          const event = SoundChannelBandpass(
            id: 1,
            frequency: 440.0,
            bandwidth: 50.0,
          );
          expect(
            event.toString(),
            '<SoundChannelBandpass id: 1, frequency: 440.0, bandwidth: 50.0>',
          );
        },
      );
    },
  );
}
