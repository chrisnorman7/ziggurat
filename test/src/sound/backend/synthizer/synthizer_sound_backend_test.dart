import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:test/test.dart';
import 'package:ziggurat/notes.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

/// The asset to use for testing.
const assetReference = AssetReference.file('sound.wav');

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
    'Synthizer',
    () {
      tearDownAll(backend.shutdown);
      group(
        'SynthizerSoundBackend',
        () {
          test(
            'Initialise',
            () {
              expect(
                backend.defaultPannerStrategy,
                DefaultPannerStrategy.stereo,
              );
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
              expect(channel.source, isA<DirectSource>());
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
              expect(channel.source, isA<AngularPannedSource>());
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
              expect(channel.source, isA<ScalarPannedSource>());
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
              expect(channel.source, isA<Source3D>());
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

          test(
            '.createReverb',
            () async {
              const preset = ReverbPreset(name: 'Test Reverb Preset', t60: 2.0);
              final reverb = backend.createReverb(preset);
              expect(reverb.backend, backend);
              expect(reverb.reverb, isA<GlobalFdnReverb>());
              expect(reverb.synthizer, synthizer);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              final synthizerReverb = reverb.reverb;
              expect(synthizerReverb.gain.value, 0.5);
              expect(synthizerReverb.t60.value, 2.0);
              reverb.destroy();
            },
          );

          test(
            '.createEcho',
            () async {
              final echo = backend.createEcho(
                [const EchoTap(delay: 0.5, gainL: 1.0, gainR: 1.0)],
              );
              expect(echo.backend, backend);
              expect(echo.echo, isA<GlobalEcho>());
              await Future<void>.delayed(const Duration(milliseconds: 100));
              echo.destroy();
            },
          );

          test(
            '.listenerPosition',
            () async {
              final position = backend.listenerPosition;
              expect(
                position,
                predicate<ListenerPosition>(
                  (final value) =>
                      value.x == 0.0 && value.y == 0.0 && value.z == 0.0,
                ),
              );
              backend.listenerPosition = const ListenerPosition(1.0, 2.0, 3.0);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(
                backend.listenerPosition,
                predicate<ListenerPosition>(
                  (final value) =>
                      value.x == 1.0 && value.y == 2.0 && value.z == 3.0,
                ),
              );
              expect(
                context.position.value,
                predicate<Double3>(
                  (final value) =>
                      value.x == 1.0 && value.y == 2.0 && value.z == 3.0,
                ),
              );
              backend.listenerPosition = const ListenerPosition(9.0, 8.0, 7.0);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(
                backend.listenerPosition,
                predicate<ListenerPosition>(
                  (final value) =>
                      value.x == 9.0 && value.y == 8.0 && value.z == 7.0,
                ),
              );
              expect(
                context.position.value,
                predicate<Double3>(
                  (final value) =>
                      value.x == 9.0 && value.y == 8.0 && value.z == 7.0,
                ),
              );
            },
          );

          test(
            '.listenerOrientation',
            () async {
              expect(
                backend.listenerOrientation,
                predicate<ListenerOrientation>(
                  (final value) =>
                      value.x1 == 0.0 &&
                      value.y1 == 1.0 &&
                      value.z1 == 0.0 &&
                      value.x2 == 0.0 &&
                      value.y2 == 0.0 &&
                      value.z2 == 1.0,
                ),
              );
              final newOrientation = ListenerOrientation.fromAngle(90.0);
              backend.listenerOrientation = newOrientation;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(
                backend.listenerOrientation,
                predicate<ListenerOrientation>(
                  (final value) =>
                      value.x1 == newOrientation.x1 &&
                      value.y1 == newOrientation.y1 &&
                      value.z1 == newOrientation.z1 &&
                      value.x2 == newOrientation.x2 &&
                      value.y2 == newOrientation.y2 &&
                      value.z2 == newOrientation.z2,
                ),
              );
              expect(
                context.orientation.value,
                predicate<Double6>(
                  (final value) =>
                      value.x1 == newOrientation.x1 &&
                      value.y1 == newOrientation.y1 &&
                      value.z1 == newOrientation.z1 &&
                      value.x2 == newOrientation.x2 &&
                      value.y2 == newOrientation.y2 &&
                      value.z2 == newOrientation.z2,
                ),
              );
              backend.listenerOrientation = const ListenerOrientation(
                0,
                1,
                0,
                0,
                0,
                1,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(
                backend.listenerOrientation,
                predicate<ListenerOrientation>(
                  (final value) =>
                      value.x1 == 0 &&
                      value.y1 == 1 &&
                      value.z1 == 0 &&
                      value.x2 == 0 &&
                      value.y2 == 0 &&
                      value.z2 == 1,
                ),
              );
            },
          );

          test(
            '.defaultPannerStrategy',
            () async {
              expect(
                context.defaultPannerStrategy.value,
                PannerStrategy.stereo,
              );
              expect(
                backend.defaultPannerStrategy,
                DefaultPannerStrategy.stereo,
              );
              backend.defaultPannerStrategy = DefaultPannerStrategy.hrtf;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(backend.defaultPannerStrategy, DefaultPannerStrategy.hrtf);
              expect(context.defaultPannerStrategy.value, PannerStrategy.hrtf);
              backend.defaultPannerStrategy = DefaultPannerStrategy.stereo;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(
                backend.defaultPannerStrategy,
                DefaultPannerStrategy.stereo,
              );
              expect(
                context.defaultPannerStrategy.value,
                PannerStrategy.stereo,
              );
            },
          );
        },
      );

      group(
        'SynthizerSoundChannel',
        () {
          test(
            'Initialise',
            () {
              final channel = backend.createSoundChannel();
              expect(channel.backend, backend);
              expect(backend.context, context);
              expect(channel.synthizer, synthizer);
              channel.destroy();
            },
          );

          test(
            '.gain',
            () async {
              final channel = backend.createSoundChannel();
              await Future<void>.delayed(const Duration(milliseconds: 100));
              channel.gain = 0.4;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(channel.gain, 0.4);
              expect(channel.source.gain.value, 0.4);
              channel.gain = 1.0;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(channel.gain, 1.0);
              expect(channel.source.gain.value, 1.0);
              channel.destroy();
            },
          );

          test(
            '.position',
            () async {
              var channel = backend.createSoundChannel();
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(channel.position, unpanned);
              final throwsPositionMismatchError = throwsA(
                isA<PositionMismatchError>(),
              );
              expect(
                () => channel.position = const SoundPositionAngular(
                  azimuth: 90.0,
                ),
                throwsUnimplementedError,
              );
              expect(
                () => channel.position = const SoundPosition3d(),
                throwsUnimplementedError,
              );
              expect(
                () => channel.position = unpanned,
                throwsUnimplementedError,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(channel.position, unpanned);
              expect(channel.source, isA<DirectSource>());
              channel.destroy();
              var soundPositionAngular = const SoundPositionAngular(
                azimuth: 45.0,
                elevation: 90.0,
              );
              channel = backend.createSoundChannel(
                position: soundPositionAngular,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(
                channel.position,
                predicate<SoundPositionAngular>(
                  (final value) =>
                      value.azimuth == 45.0 && value.elevation == 90.0,
                ),
              );
              expect(
                channel.source as AngularPannedSource,
                predicate<AngularPannedSource>(
                  (final value) =>
                      value.azimuth.value == soundPositionAngular.azimuth &&
                      value.elevation.value == soundPositionAngular.elevation,
                ),
              );
              soundPositionAngular = const SoundPositionAngular(
                azimuth: 90.0,
                elevation: 45.0,
              );
              channel.position = soundPositionAngular;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(
                channel.position,
                predicate<SoundPositionAngular>(
                  (final value) =>
                      value.azimuth == 90.0 && value.elevation == 45.0,
                ),
              );
              expect(
                channel.source as AngularPannedSource,
                predicate<AngularPannedSource>(
                  (final value) =>
                      value.azimuth.value == soundPositionAngular.azimuth &&
                      value.elevation.value == soundPositionAngular.elevation,
                ),
              );
              expect(
                () => channel.position = unpanned,
                throwsPositionMismatchError,
              );
              expect(
                () => channel.position = const SoundPosition3d(),
                throwsPositionMismatchError,
              );
              channel.destroy();
              channel = backend.createSoundChannel(
                position: const SoundPosition3d(x: 1.0, y: 2.0, z: 3.0),
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(
                channel.position,
                predicate<SoundPosition3d>(
                  (final value) =>
                      value.x == 1.0 && value.y == 2.0 && value.z == 3.0,
                ),
              );
              expect(
                (channel.source as Source3D).position.value,
                predicate<Double3>(
                  (final value) =>
                      value.x == 1.0 && value.y == 2.0 && value.z == 3.0,
                ),
              );
              expect(
                () => channel.position = unpanned,
                throwsPositionMismatchError,
              );
              expect(
                () => channel.position = const SoundPositionAngular(),
                throwsPositionMismatchError,
              );
              channel.position = const SoundPosition3d(x: 7, y: 8, z: 9);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(
                channel.position,
                predicate<SoundPosition3d>(
                  (final value) =>
                      value.x == 7.0 && value.y == 8.0 && value.z == 9.0,
                ),
              );
              expect(
                (channel.source as Source3D).position.value,
                predicate<Double3>(
                  (final value) =>
                      value.x == 7.0 && value.y == 8.0 && value.z == 9.0,
                ),
              );
              channel.destroy();
            },
          );

          test(
            'Filtering',
            () async {
              // Since there is currently no way to read synthizer filters, the
              // best we can do here is run the filtering functions, and ensure
              // there are no errors thrown.
              final channel = backend.createSoundChannel();
              final sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
                looping: true,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              channel.filterBandpass(a4, 50);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              channel.filterHighpass(10000);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              channel.filterLowpass(500);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              channel.clearFilter();
              await Future<void>.delayed(const Duration(milliseconds: 100));
              sound.destroy();
              channel.destroy();
            },
          );
        },
      );
    },
  );
}
