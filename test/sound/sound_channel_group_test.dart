import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final sdl = Sdl();
  group('SoundChannel', () {
    test('Initialise', () {
      final game = Game(
        title: 'SoundChannelGroup',
        sdl: sdl,
      );
      final channelGroup =
          SoundChannelGroup([game.interfaceSounds, game.ambianceSounds]);
      expect(channelGroup.channels.length, equals(2));
      expect(
        channelGroup.channels,
        allOf(contains(game.ambianceSounds), contains(game.interfaceSounds)),
      );
    });
    test('.setReverb', () {
      final game = Game(
        title: 'SoundChannelGroup.setReverb',
        sdl: sdl,
      );
      final channelGroup =
          SoundChannelGroup([game.interfaceSounds, game.ambianceSounds]);
      final reverb = game.createReverb(const ReverbPreset(name: 'Test Reverb'));
      channelGroup.reverb = reverb;
      expect(game.interfaceSounds.reverb, equals(reverb.id));
      expect(game.ambianceSounds.reverb, equals(reverb.id));
      channelGroup.reverb = null;
      expect(game.interfaceSounds.reverb, isNull);
      expect(game.ambianceSounds.reverb, isNull);
    });
    test('.gain', () {
      final game = Game(
        title: 'SoundChannelGroup.gain',
        sdl: sdl,
      );
      final channelGroup =
          SoundChannelGroup([game.interfaceSounds, game.ambianceSounds]);
      expect(game.interfaceSounds.gain, equals(0.7));
      expect(game.ambianceSounds.gain, equals(0.7));
      channelGroup.gain = 0.2;
      expect(game.interfaceSounds.gain, equals(0.2));
      expect(game.ambianceSounds.gain, equals(0.2));
      channelGroup.gain = 1.0;
      expect(game.interfaceSounds.gain, equals(1.0));
      expect(game.ambianceSounds.gain, equals(1.0));
    });
    test('.clearFilters', () async {
      final events = <SoundEvent>[];
      final game = Game(
        title: 'SoundChannelGroup.gain',
        sdl: sdl,
      )..sounds.listen(
          events.add,
        );
      final channelGroup =
          SoundChannelGroup([game.interfaceSounds, game.ambianceSounds]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      events.clear();
      channelGroup.clearFilters();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(events.length, equals(2));
      var event = events.first as SoundChannelFilter;
      expect(event.id, equals(game.interfaceSounds.id));
      event = events.last as SoundChannelFilter;
      expect(event.id, equals(game.ambianceSounds.id));
    });
    test('.filterLowpass', () async {
      final events = <SoundEvent>[];
      final game = Game(
        title: 'SoundChannelGroup.gain',
        sdl: sdl,
      )..sounds.listen(events.add);
      final channelGroup =
          SoundChannelGroup([game.interfaceSounds, game.ambianceSounds]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      events.clear();
      const frequency = 1234.0;
      const q = 5678.0;
      channelGroup.filterLowpass(frequency, q: q);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(events.length, equals(2));
      var event = events.first as SoundChannelLowpass;
      expect(event.id, equals(game.interfaceSounds.id));
      expect(event.frequency, equals(frequency));
      expect(event.q, equals(q));
      event = events.last as SoundChannelLowpass;
      expect(event.id, equals(game.ambianceSounds.id));
      expect(event.frequency, equals(frequency));
      expect(event.q, equals(q));
    });
    test('.filterHighpass', () async {
      final events = <SoundEvent>[];
      final game = Game(
        title: 'SoundChannelGroup.gain',
        sdl: sdl,
      )..sounds.listen(events.add);
      final channelGroup =
          SoundChannelGroup([game.interfaceSounds, game.ambianceSounds]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      events.clear();
      const frequency = 1234.0;
      const q = 5678.0;
      channelGroup.filterHighpass(frequency, q: q);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(events.length, equals(2));
      var event = events.first as SoundChannelHighpass;
      expect(event.id, equals(game.interfaceSounds.id));
      expect(event.frequency, equals(frequency));
      expect(event.q, equals(q));
      event = events.last as SoundChannelHighpass;
      expect(event.id, equals(game.ambianceSounds.id));
      expect(event.frequency, equals(frequency));
      expect(event.q, equals(q));
    });
    test('.filterBandpass', () async {
      final events = <SoundEvent>[];
      final game = Game(
        title: 'SoundChannelGroup.gain',
        sdl: sdl,
      )..sounds.listen(events.add);
      final channelGroup =
          SoundChannelGroup([game.interfaceSounds, game.ambianceSounds]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      events.clear();
      const frequency = 1234.0;
      const bandwidth = 5678.0;
      channelGroup.filterBandpass(frequency, bandwidth);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(events.length, equals(2));
      var event = events.first as SoundChannelBandpass;
      expect(event.id, equals(game.interfaceSounds.id));
      expect(event.frequency, equals(frequency));
      expect(event.bandwidth, equals(bandwidth));
      event = events.last as SoundChannelBandpass;
      expect(event.id, equals(game.ambianceSounds.id));
      expect(event.frequency, equals(frequency));
      expect(event.bandwidth, equals(bandwidth));
    });
    test('.destroy', () async {
      final events = <SoundEvent>[];
      final game = Game(
        title: 'SoundChannelGroup.gain',
        sdl: sdl,
      )..sounds.listen(events.add);
      final channelGroup =
          SoundChannelGroup([game.interfaceSounds, game.ambianceSounds]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      events.clear();
      channelGroup.destroy();
      expect(channelGroup.channels, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(events.length, equals(2));
      expect(events.first, isA<DestroySoundChannel>());
      expect(events.first.id, equals(game.ambianceSounds.id));
      expect(events.last, isA<DestroySoundChannel>());
      expect(events.last.id, equals(game.interfaceSounds.id));
    });
  });
}
