import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:test/test.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final synthizer = Synthizer()..initialize();
  final context = synthizer.createContext();
  final random = Random();
  final bufferCache = BufferCache(
    synthizer: synthizer,
    maxSize: 1.gb,
    random: random,
  );
  final backend = SynthizerSoundBackend(
    context: context,
    bufferCache: bufferCache,
  );
  group(
    'SynthizerSoundBackend',
    () {
      tearDownAll(backend.shutdown);
      test(
        'Initialise',
        () {
          expect(backend.defaultPannerStrategy, DefaultPannerStrategy.stereo);
          expect(
            backend.listenerPosition,
            predicate(
              (final value) =>
                  value is ListenerPosition &&
                  value.x == 0.0 &&
                  value.y == 0.0 &&
                  value.z == 0.0,
            ),
          );
          expect(
            backend.listenerOrientation,
            predicate(
              (final value) =>
                  value is ListenerOrientation &&
                  value.x1 == 0.0 &&
                  value.y1 == 1.0 &&
                  value.z1 == 0.0 &&
                  value.x2 == 0.0 &&
                  value.y2 == 0.0 &&
                  value.z2 == 1.0,
            ),
          );
        },
      );

      test(
        '.createSoundChannel Unpanned',
        () async {
          final channel = backend.createSoundChannel();
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(channel.gain, 0.7);
          expect(channel.position, unpanned);
          channel.destroy();
        },
      );

      test(
        '.createSoundChannel Angular',
        () async {
          final channel = backend.createSoundChannel(
            position: const SoundPositionAngular(
              azimuth: 90.0,
              elevation: 45.0,
            ),
            gain: 0.5,
          );
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(channel.gain, 0.5);
          expect(
            channel.position,
            predicate(
              (final value) =>
                  value is SoundPositionAngular &&
                  value.azimuth == 90.0 &&
                  value.elevation == 45.0,
            ),
          );
          channel.destroy();
        },
      );

      test(
        '.createSoundChannel Scalar',
        () async {
          final channel = backend.createSoundChannel(
            gain: 0.2,
            position: const SoundPositionScalar(scalar: -1.0),
          );
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(channel.gain, 0.2);
          expect(
            channel.position,
            predicate(
              (final value) =>
                  value is SoundPositionScalar && value.scalar == -1.0,
            ),
          );
          channel.destroy();
        },
      );

      test(
        '.createSoundChannel 3d',
        () async {
          final channel = backend.createSoundChannel(
            gain: 0.8,
            position: const SoundPosition3d(
              x: 1.0,
              y: 2.0,
              z: 3.0,
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(channel.gain, 0.8);
          expect(
            channel.position,
            predicate(
              (final value) =>
                  value is SoundPosition3d &&
                  value.x == 1.0 &&
                  value.y == 2.0 &&
                  value.z == 3.0,
            ),
          );
          channel.destroy();
        },
      );
    },
  );
}
