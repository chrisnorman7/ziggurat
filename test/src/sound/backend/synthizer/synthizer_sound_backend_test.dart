import 'dart:io';
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:test/test.dart';
import 'package:ziggurat/notes.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/wave_types.dart';
import 'package:ziggurat/ziggurat.dart';

/// The asset to use for testing.
const assetReference = AssetReference.file('sound.wav');

/// A silent asset reference.
const silence = AssetReference.file('silence.wav');
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

          test(
            'Reverb',
            () async {
              final channel = backend.createSoundChannel();
              final sound = channel.playSound(
                assetReference: assetReference,
                looping: true,
                keepAlive: true,
              );
              final reverb = backend.createReverb(
                const ReverbPreset(
                  name: 'Test Reverb',
                  gain: 1.0,
                  t60: 1.0,
                ),
              );
              await Future<void>.delayed(const Duration(seconds: 1));
              channel.addReverb(
                reverb: reverb,
              );
              await Future<void>.delayed(const Duration(seconds: 1));
              channel.removeReverb(
                reverb: reverb,
              );
              await Future<void>.delayed(const Duration(seconds: 1));
              reverb.destroy();
              sound.destroy();
              channel.destroy();
            },
          );

          test(
            'Echo',
            () async {
              final channel = backend.createSoundChannel();
              final echo = backend.createEcho(
                [
                  const EchoTap(delay: 0.5, gainL: 1.0, gainR: 0.0),
                  const EchoTap(
                    delay: 0.75,
                    gainL: 0.0,
                    gainR: 0.75,
                  ),
                  const EchoTap(
                    delay: 1.0,
                    gainL: 0.5,
                    gainR: 0.0,
                  )
                ],
              );
              final sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
                looping: true,
              );
              await Future<void>.delayed(const Duration(seconds: 1));
              channel.addEcho(
                echo: echo,
                fadeTime: 0.5,
              );
              await Future<void>.delayed(const Duration(seconds: 1));
              channel.removeEcho(echo: echo, fadeTime: 0.5);
              await Future<void>.delayed(const Duration(seconds: 2));
              sound.destroy();
              echo.destroy();
              channel.destroy();
            },
          );

          test(
            '.playSaw',
            () async {
              final channel = backend.createSoundChannel();
              final wave = channel.playSaw(
                a1,
                gain: 0.5,
              ) as SynthizerWave;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(wave.backend, backend);
              expect(wave.gain, 0.5);
              expect(wave.generator.frequency.value, a1);
              wave.destroy();
              channel.destroy();
            },
          );

          test(
            '.playSine',
            () async {
              final channel = backend.createSoundChannel();
              final wave = channel.playSine(frequency: a2, gain: 0.6);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(wave.backend, backend);
              expect(wave.gain, 0.6);
              expect(wave.generator.frequency.value, a2);
              wave.destroy();
              channel.destroy();
            },
          );

          test(
            '.playSquare',
            () async {
              final channel = backend.createSoundChannel();
              final wave = channel.playSquare(
                frequency: a3,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(wave.backend, backend);
              expect(wave.gain, 0.7);
              expect(wave.generator.frequency.value, a3);
              wave.destroy();
              channel.destroy();
            },
          );

          test(
            '.playTriangle',
            () async {
              final channel = backend.createSoundChannel();
              final wave = channel.playTriangle(
                frequency: a4,
                gain: 0.8,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(wave.backend, backend);
              expect(wave.gain, 0.8);
              expect(wave.generator.frequency.value, a4);
              wave.destroy();
              channel.destroy();
            },
          );

          test(
            '.playWave',
            () async {
              final channel = backend.createSoundChannel();
              expect(
                () => channel.playWave(
                  waveType: WaveType.saw,
                  frequency: a4,
                  partials: 0,
                ),
                throwsStateError,
              );
            },
          );

          test(
            '.playSound',
            () async {
              final channel = backend.createSoundChannel();
              var sound = channel.playSound(assetReference: assetReference);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.backend, backend);
              expect(sound.channel, channel);
              expect(() => sound.gain, throwsStateError);
              expect(sound.generator, isA<BufferGenerator>());
              expect(sound.keepAlive, isFalse);
              expect(() => sound.looping, throwsStateError);
              expect(() => sound.pitchBend, throwsStateError);
              expect(() => sound.position, throwsStateError);
              expect(sound.destroy, throwsStateError);
              sound = channel.playSound(
                assetReference: assetReference,
                gain: 0.5,
                keepAlive: true,
                looping: true,
                pitchBend: 2.0,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.backend, backend);
              expect(sound.channel, channel);
              expect(sound.gain, 0.5);
              expect(sound.generator, isA<BufferGenerator>());
              expect(sound.keepAlive, isTrue);
              expect(sound.looping, isTrue);
              expect(sound.pitchBend, 2.0);
              expect(sound.position, isNonZero);
              sound.destroy();
            },
          );

          test(
            '.playString',
            () async {
              final channel = backend.createSoundChannel();
              final file = File(assetReference.name);
              final bytes = file.readAsBytesSync();
              final string = String.fromCharCodes(bytes);
              var sound = channel.playString(string: string);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.backend, backend);
              expect(sound.channel, channel);
              expect(() => sound.gain, throwsStateError);
              expect(sound.generator, isA<BufferGenerator>());
              expect(sound.keepAlive, isFalse);
              expect(() => sound.looping, throwsStateError);
              expect(() => sound.pitchBend, throwsStateError);
              expect(() => sound.position, throwsStateError);
              expect(sound.destroy, throwsStateError);
              sound = channel.playString(
                string: string,
                gain: 0.5,
                keepAlive: true,
                looping: true,
                pitchBend: 0.7,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.backend, backend);
              expect(sound.channel, channel);
              expect(sound.gain, 0.5);
              expect(sound.generator, isA<BufferGenerator>());
              expect(sound.keepAlive, isTrue);
              expect(sound.looping, isTrue);
              expect(sound.pitchBend, 0.7);
              expect(sound.position, greaterThan(0.05));
              sound.destroy();
            },
          );

          test(
            '.removeAllEffects',
            () async {
              const seconds = 1;
              final channel = backend.createSoundChannel();
              const reverbPreset = ReverbPreset(
                name: 'Test Reverb',
                gain: 1.0,
                t60: 2.0,
              );
              final reverb = backend.createReverb(reverbPreset);
              final echo = backend.createEcho(
                [
                  for (var i = 0.1; i <= 2.0; i++)
                    EchoTap(delay: i, gainL: i, gainR: i)
                ],
              );
              final sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
                looping: true,
              );
              await Future<void>.delayed(const Duration(seconds: seconds));
              channel.addEcho(echo: echo);
              await Future<void>.delayed(const Duration(seconds: seconds));
              channel.addReverb(reverb: reverb);
              await Future<void>.delayed(const Duration(seconds: seconds));
              channel.removeAllEffects();
              echo.destroy();
              reverb.destroy();
              await Future<void>.delayed(const Duration(seconds: seconds));
              sound.destroy();
              channel.destroy();
            },
          );
        },
      );

      group(
        'SynthizerBackendEcho',
        () {
          final channel = backend.createSoundChannel();
          tearDownAll(channel.destroy);
          test(
            'Initialise',
            () async {
              final echo = backend.createEcho([]);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(echo.backend, backend);
              expect(echo.echo, isA<GlobalEcho>());
              echo.destroy();
            },
          );

          test(
            '.setTaps',
            () async {
              final sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
                looping: true,
              );
              await Future<void>.delayed(const Duration(seconds: 1));
              final echo = backend.createEcho(
                [
                  for (var i = 1; i < 11; i++)
                    EchoTap(delay: i * 0.1, gainL: i / 11, gainR: i / 11)
                ],
              );
              channel.addEcho(echo: echo);
              await Future<void>.delayed(const Duration(seconds: 1));
              echo.setTaps([const EchoTap(delay: 0.5, gainL: 1.0, gainR: 0.0)]);
              await Future<void>.delayed(const Duration(seconds: 1));
              echo.destroy();
              sound.destroy();
            },
          );

          test(
            '.reset',
            () async {
              final sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
                looping: true,
              );
              final echo = backend.createEcho(
                [
                  const EchoTap(delay: 0.5, gainL: 1.0, gainR: 0.0),
                  const EchoTap(delay: 1.0, gainL: 0.0, gainR: 1.0),
                ],
              );
              channel.addEcho(echo: echo);
              await Future<void>.delayed(const Duration(seconds: 1));
              echo.reset();
              await Future<void>.delayed(const Duration(seconds: 1));
              echo.destroy();
              sound.destroy();
            },
          );
        },
      );

      group(
        'SynthizerBackendReverb',
        () {
          final channel = backend.createSoundChannel();
          const reverbPreset =
              ReverbPreset(name: 'Test Reverb', gain: 1.0, t60: 3.0);
          tearDownAll(channel.destroy);

          test(
            'Initialise',
            () async {
              final reverb = backend.createReverb(reverbPreset);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(reverb.backend, backend);
              expect(reverb.reverb, isA<GlobalFdnReverb>());
              expect(reverb.synthizer, synthizer);
              final r = reverb.reverb;
              expect(
                r.meanFreePath.value,
                reverbPreset.meanFreePath,
              );
              expect(
                r.t60.value,
                reverbPreset.t60,
              );
              expect(
                r.lateReflectionsLfRolloff.value,
                reverbPreset.lateReflectionsLfRolloff,
              );
              expect(
                r.lateReflectionsLfReference.value,
                reverbPreset.lateReflectionsLfReference,
              );
              expect(
                r.lateReflectionsHfRolloff.value,
                reverbPreset.lateReflectionsHfRolloff,
              );
              expect(
                r.lateReflectionsHfReference.value,
                reverbPreset.lateReflectionsHfReference,
              );
              expect(
                r.lateReflectionsDiffusion.value,
                reverbPreset.lateReflectionsDiffusion,
              );
              expect(
                r.lateReflectionsModulationDepth.value,
                reverbPreset.lateReflectionsModulationDepth,
              );
              expect(
                r.lateReflectionsModulationFrequency.value,
                reverbPreset.lateReflectionsModulationFrequency,
              );
              expect(
                r.lateReflectionsDelay.value,
                reverbPreset.lateReflectionsDelay,
              );
              expect(r.gain.value, reverbPreset.gain);
              reverb.destroy();
            },
          );

          test(
            '.setPreset',
            () async {
              final reverb = backend.createReverb(reverbPreset);
              channel.addReverb(reverb: reverb);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              const newPreset = ReverbPreset(
                name: 'New Preset',
                t60: 5.0,
              );
              reverb.setPreset(newPreset);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              final r = reverb.reverb;
              expect(
                r.meanFreePath.value,
                reverbPreset.meanFreePath,
              );
              expect(
                r.t60.value,
                newPreset.t60,
              );
              expect(
                r.lateReflectionsLfRolloff.value,
                reverbPreset.lateReflectionsLfRolloff,
              );
              expect(
                r.lateReflectionsLfReference.value,
                reverbPreset.lateReflectionsLfReference,
              );
              expect(
                r.lateReflectionsHfRolloff.value,
                reverbPreset.lateReflectionsHfRolloff,
              );
              expect(
                r.lateReflectionsHfReference.value,
                reverbPreset.lateReflectionsHfReference,
              );
              expect(
                r.lateReflectionsDiffusion.value,
                reverbPreset.lateReflectionsDiffusion,
              );
              expect(
                r.lateReflectionsModulationDepth.value,
                reverbPreset.lateReflectionsModulationDepth,
              );
              expect(
                r.lateReflectionsModulationFrequency.value,
                reverbPreset.lateReflectionsModulationFrequency,
              );
              expect(
                r.lateReflectionsDelay.value,
                reverbPreset.lateReflectionsDelay,
              );
              expect(r.gain.value, newPreset.gain);
              reverb.destroy();
            },
          );

          test(
            'Filtering',
            () async {
              // Since there is currently no way to read synthizer filters, the
              // best we can do here is run the filtering functions, and ensure
              // there are no errors thrown.
              final sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
                looping: true,
              );
              final reverb = backend.createReverb(reverbPreset);
              channel.addReverb(reverb: reverb);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              reverb.filterBandpass(a4, 50);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              reverb.filterHighpass(10000);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              reverb.filterLowpass(500);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              reverb.clearFilter();
              await Future<void>.delayed(const Duration(milliseconds: 100));
              sound.destroy();
              reverb.destroy();
            },
          );

          test(
            '.reset',
            () async {
              final reverb = backend.createReverb(reverbPreset);
              channel.addReverb(reverb: reverb);
              final sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
                looping: true,
              );
              await Future<void>.delayed(const Duration(seconds: 1));
              reverb.reset();
              await Future<void>.delayed(const Duration(seconds: 1));
              reverb.destroy();
              sound.destroy();
            },
          );
        },
      );

      group(
        'SynthizerSound',
        () {
          final channel = backend.createSoundChannel();
          tearDownAll(channel.destroy);

          test(
            'Initialise',
            () async {
              final sound = channel.playSound(assetReference: assetReference);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.backend, backend);
              expect(sound.channel, channel);
              expect(sound.context, context);
              expect(sound.generator, isA<BufferGenerator>());
              expect(sound.keepAlive, isFalse);
              expect(sound.source, channel.source);
            },
          );

          test(
            '.cancelFade',
            () async {
              final sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
              )..fade(length: 1.0);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              sound.cancelFade();
              final gain = sound.gain;
              expect(gain, inClosedOpenRange(0.2, 1.0));
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.gain, gain);
              sound.destroy();
            },
          );

          test(
            '.checkSound',
            () {
              var sound = channel.playSound(assetReference: assetReference);
              expect(sound.checkDeadSound, throwsStateError);
              sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
              );
              expect(sound.checkDeadSound, returnsNormally);
              sound.destroy();
            },
          );

          test(
            '.fade',
            () async {
              final sound = channel.playSound(
                assetReference: assetReference,
                gain: 1.0,
                keepAlive: true,
              )..fade(
                  length: 0.5,
                  startGain: 1.0,
                );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.gain, inExclusiveRange(0.0, 1.0));
              await Future<void>.delayed(const Duration(milliseconds: 500));
              expect(sound.gain, isZero);
              sound.destroy();
            },
          );

          test(
            '.gain',
            () async {
              var sound = channel.playSound(assetReference: assetReference);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(() => sound.gain, throwsStateError);
              expect(() => sound.gain = 1.0, throwsStateError);
              sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.gain, 0.7);
              sound.gain = 1.0;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.gain, 1.0);
              sound.destroy();
            },
          );

          test(
            '.looping',
            () async {
              var sound = channel.playSound(assetReference: assetReference);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(() => sound.looping, throwsStateError);
              expect(() => sound.looping = true, throwsStateError);
              sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.looping, isFalse);
              sound.looping = true;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.looping, isTrue);
              sound.destroy();
            },
          );

          test(
            '.pause and .unpause',
            () async {
              var sound = channel.playSound(assetReference: assetReference);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.pause, throwsStateError);
              sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              sound.pause();
              final position = sound.position;
              expect(position, greaterThan(0.0));
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.position, greaterThan(position));
              sound.unpause();
              await Future<void>.delayed(const Duration(milliseconds: 100));
              final newPosition = sound.position;
              expect(newPosition, greaterThan(position));
              sound.destroy();
            },
          );

          test(
            '.pitchBend',
            () async {
              var sound = channel.playSound(assetReference: assetReference);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(() => sound.pitchBend, throwsStateError);
              expect(() => sound.pitchBend = 2.0, throwsStateError);
              sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.pitchBend, 1.0);
              sound.pitchBend = 0.5;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.pitchBend, 0.5);
              sound.pitchBend = 0.25;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.pitchBend, 0.25);
            },
          );

          test(
            '.position',
            () async {
              var sound = channel.playSound(assetReference: assetReference);
              expect(() => sound.position, throwsStateError);
              expect(() => sound.position = 2.0, throwsStateError);
              sound = channel.playSound(
                assetReference: assetReference,
                keepAlive: true,
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              final position = sound.position;
              expect(position, greaterThan(0.0));
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound.position, greaterThan(position));
              sound.destroy();
            },
          );
        },
      );

      group(
        'BufferCache',
        () {
          final cache = BufferCache(
            synthizer: synthizer,
            maxSize: 1.gb,
            random: random,
          );
          tearDownAll(cache.destroy);

          test(
            'Initialise',
            () {
              expect(cache.maxSize, 1.gb);
              expect(cache.random, random);
              expect(cache.size, isZero);
              expect(cache.synthizer, synthizer);
            },
          );

          test(
            '.getBuffer',
            () {
              final buffer = cache.getBuffer(assetReference);
              expect(buffer, isA<Buffer>());
              final size = cache.size;
              expect(size, buffer.size);
              expect(cache.getBuffer(assetReference), buffer);
              expect(cache.size, size);
              final silentBuffer = cache.getBuffer(
                const AssetReference.file('silence.wav'),
              );
              expect(cache.size, buffer.size + silentBuffer.size);
              expect(
                () => cache.getBuffer(const AssetReference.file('Nothing.wav')),
                throwsA(isA<NoSuchBufferError>()),
              );
            },
          );

          test(
            '.prune',
            () {
              final cache = BufferCache(
                synthizer: synthizer,
                maxSize: 1.gb,
                random: random,
              )
                ..getBuffer(assetReference)
                ..prune();
              expect(cache.size, isZero);
              final buffer1 = cache.getBuffer(assetReference);
              expect(cache.size, buffer1.size);
              final buffer2 = cache.getBuffer(silence);
              expect(cache.size, buffer1.size + buffer2.size);
              cache.prune();
              expect(cache.size, buffer2.size);
            },
          );

          test(
            '.destroy',
            () async {
              final cache = BufferCache(
                synthizer: synthizer,
                maxSize: pow(1024, 3).floor(),
                random: random,
              );
              final buffer1 = cache.getBuffer(
                assetReference,
              );
              final buffer2 = cache.getBuffer(
                silence,
              );
              expect(cache.size, equals(buffer1.size + buffer2.size));
              cache.destroy();
              expect(cache.size, isZero);
              final newBuffer1 = cache.getBuffer(assetReference);
              expect(cache.size, newBuffer1.size);
              expect(newBuffer1.hashCode, isNot(buffer1.hashCode));
            },
          );
        },
      );

      group(
        'Game',
        () {
          final sdl = Sdl();
          final game = Game(
            title: 'Test `playSimpleSound`',
            sdl: sdl,
            soundBackend: backend,
          );

          test(
            '.playSimpleSound',
            () async {
              var sound = game.playSimpleSound(sound: assetReference);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              expect(sound, isA<SynthizerSound>());
              expect(sound.channel, game.interfaceSounds);
              expect(() => sound.gain, throwsStateError);
              expect(sound.keepAlive, isFalse);
              expect(() => sound.looping, throwsStateError);
              expect(() => sound.pitchBend, throwsStateError);
              expect(() => sound.position, throwsStateError);
              expect(sound.destroy, throwsStateError);
              sound = game.playSimpleSound(
                sound: assetReference,
                gain: 0.5,
                looping: true,
                pitchBend: 0.7,
                position: const SoundPosition3d(
                  x: 1.0,
                  y: 2.0,
                  z: 3.0,
                ),
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              final channel = sound.channel;
              expect(channel.gain, 0.7);
              expect(
                channel.position,
                predicate<SoundPosition3d>(
                  (final value) =>
                      value.x == 1.0 && value.y == 2.0 && value.z == 3.0,
                ),
              );
              expect(sound.gain, 0.5);
              expect(sound.keepAlive, isTrue);
              expect(sound.looping, isTrue);
              expect(sound.pitchBend, 0.7);
              expect(sound.position, greaterThan(0.0));
              sound.destroy();
              channel.destroy();
            },
          );
        },
      );
    },
  );
}
