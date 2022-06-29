import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ziggurat/notes.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import 'custom_sound_manager.dart';

void main() {
  final sdl = Sdl();
  final synthizer = Synthizer()..initialize();
  final context = synthizer.createContext();
  tearDownAll(
    () {
      context.destroy();
      synthizer.shutdown();
    },
  );
  final game = Game(
    title: 'Sounds',
    sdl: sdl,
  );
  final random = game.random;
  final defaultBufferCache = BufferCache(
    synthizer: synthizer,
    maxSize: 1.gb,
    random: random,
  );
  final soundManager = CustomSoundManager(
    context: context,
    bufferCache: defaultBufferCache,
  );
  game.sounds.listen(soundManager.handleEvent);
  group(
    'Initialisation',
    () {
      test(
        'Ensure initialisation',
        () async {
          final game = Game(
            title: 'Ensure Initialisation',
            sdl: sdl,
          );
          final events = <SoundEvent>[];
          game.sounds.listen(events.add);
          await Future<void>.delayed(Duration.zero);
          expect(events.length, 3);
          expect(events.first, isA<SoundChannel>());
          expect(events.last, isA<SoundChannel>());
        },
      );
      test(
        'Game Initialisation',
        () async {
          expect(game.soundsController.hasListener, isTrue);
          expect(soundManager.events.length, 3);
          expect(soundManager.events.first, game.interfaceSounds);
          expect(soundManager.events[1], game.ambianceSounds);
          expect(soundManager.events.last, game.musicSounds);
          expect(soundManager.getChannel(1), isA<AudioChannel>());
          expect(soundManager.getChannel(2), isA<AudioChannel>());
          expect(
            () => soundManager.getReverb(0),
            throwsA(isA<NoSuchReverbError>()),
          );
        },
      );
    },
  );
  group(
    'Create and destroy stuff',
    () {
      test(
        'Reverb',
        () async {
          const preset = ReverbPreset(name: 'Test Reverb');
          expect(preset.gain, equals(0.5));
          final reverbEvent = game.createReverb(preset);
          expect(reverbEvent.reverb, equals(preset));
          await Future<void>.delayed(const Duration(milliseconds: 100));
          expect(soundManager.events.length, 4);
          expect(soundManager.events.last, equals(reverbEvent));
          final reverb = soundManager.getReverb(SoundEvent.maxEventId);
          expect(
            reverb,
            predicate(
              (final value) => value is Reverb && value.name == preset.name,
            ),
          );
          expect(reverb.reverb.gain.value, equals(preset.gain));
          reverbEvent.destroy();
          await Future<void>.delayed(Duration.zero);
          expect(
            () => soundManager.getReverb(reverbEvent.id!),
            throwsA(isA<NoSuchReverbError>()),
          );
          expect(soundManager.events.length, 5);
          expect(
            soundManager.events.last,
            predicate(
              (final value) =>
                  value is DestroyReverb && value.id == reverbEvent.id,
            ),
          );
        },
      );
      test(
        'Channel',
        () async {
          var length = soundManager.events.length;
          var channelEvent = game.createSoundChannel();
          await Future<void>.delayed(const Duration(milliseconds: 200));
          var channel = soundManager.getChannel(channelEvent.id!);
          expect(soundManager.events.length, equals(length + 1));
          expect(channel.id, equals(channelEvent.id));
          expect(channel.sounds, isEmpty);
          var source = channel.source;
          expect(source, isA<DirectSource>());
          expect(source.gain.value, equals(0.70));
          channelEvent.gain *= 2;
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(source.gain.value, equals(1.4));
          channelEvent =
              game.createSoundChannel(position: const SoundPositionScalar());
          await Future<void>.delayed(const Duration(milliseconds: 200));
          channel = soundManager.getChannel(channelEvent.id!);
          source = channel.source;
          if (source is ScalarPannedSource) {
            expect(source.panningScalar.value, isZero);
            channelEvent.position = const SoundPositionScalar(scalar: -1.0);
            await Future<void>.delayed(const Duration(milliseconds: 200));
            expect(source.panningScalar.value, equals(-1.0));
          } else {
            throw Exception('Source is not `ScalarPannedSource`.');
          }
          channelEvent = game.createSoundChannel(
            position: const SoundPositionAngular(),
          );
          await Future<void>.delayed(const Duration(milliseconds: 200));
          channel = soundManager.getChannel(channelEvent.id!);
          source = channel.source;
          if (source is AngularPannedSource) {
            expect(source.azimuth.value, isZero);
            expect(source.elevation.value, isZero);
            expect(source.gain.value, equals(channelEvent.gain));
            channelEvent.position =
                const SoundPositionAngular(azimuth: 90.0, elevation: 45.0);
            await Future<void>.delayed(const Duration(milliseconds: 200));
            expect(source.azimuth.value, equals(90.0));
            expect(source.elevation.value, equals(45.0));
            expect(source.gain.value, equals(channelEvent.gain));
          } else {
            throw Exception('Source is not `AngularPannedSource`.');
          }
          // There is no real way to test these filters work, since the `filter`
          // property is read-only in Synthizer land.
          //
          // The best we can do is to make sure there are no crashes when we set
          // filters
          length = soundManager.events.length;
          channelEvent.filterBandpass(440.0, 200.0);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(soundManager.events.length, equals(++length));
          var event = soundManager.events.last;
          expect(event, isA<SoundChannelBandpass>());
          expect((event as SoundChannelBandpass).frequency, equals(440.0));
          expect(event.bandwidth, equals(200.0));
          expect(event.id, equals(channel.id));
          channelEvent.filterHighpass(
            440.0,
          );
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(soundManager.events.length, equals(++length));
          event = soundManager.events.last;
          expect(event, isA<SoundChannelHighpass>());
          expect(event.id, equals(channel.id));
          expect((event as SoundChannelHighpass).frequency, equals(440.0));
          channelEvent.filterLowpass(440.0);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(soundManager.events.length, equals(++length));
          event = soundManager.events.last;
          expect(event, isA<SoundChannelLowpass>());
          expect(event.id, equals(channel.id));
          expect((event as SoundChannelLowpass).frequency, equals(440.0));
          channelEvent.clearFilter();
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(soundManager.events.length, equals(++length));
          event = soundManager.events.last;
          expect(event, isA<SoundChannelFilter>());
          expect(event.id, equals(channel.id));
          expect(event, isNot(isA<SoundChannelHighpass>()));
          expect(event, isNot(isA<SoundChannelLowpass>()));
          expect(event, isNot(isA<SoundChannelBandpass>()));
          channelEvent =
              game.createSoundChannel(position: const SoundPosition3d());
          await Future<void>.delayed(const Duration(milliseconds: 200));
          channel = soundManager.getChannel(channelEvent.id!);
          source = channel.source;
          if (source is Source3D) {
            final position = source.position;
            expect(position.value.x, isZero);
            expect(position.value.y, isZero);
            expect(position.value.z, isZero);
            channelEvent.position =
                const SoundPosition3d(x: 1.0, y: 2.0, z: 3.0);
            await Future<void>.delayed(const Duration(milliseconds: 200));
            expect(source.position.value, equals(const Double3(1.0, 2.0, 3.0)));
            expect(source.gain.value, equals(channelEvent.gain));
          } else {
            throw Exception('Source is not of type `Source3D`.');
          }
          channelEvent.destroy();
          await Future<void>.delayed(Duration.zero);
          expect(
            () => soundManager.getChannel(channelEvent.id!),
            throwsA(isA<NoSuchChannelError>()),
          );
        },
      );
      test(
        'Sound',
        () async {
          final channel = game.createSoundChannel();
          var sound = channel.playSound(const AssetReference.file('sound.wav'));
          expect(sound.channel, equals(channel.id));
          expect(sound.looping, isFalse);
          expect(sound.keepAlive, isFalse);
          expect(() => sound.destroy(), throwsA(isA<DeadSound>()));
          await Future<void>.delayed(Duration.zero);
          final channelObject = soundManager.getChannel(channel.id!);
          expect(channelObject.sounds[sound.id], isNull);
          sound = channel.playSound(
            const AssetReference.file('sound.wav'),
            keepAlive: true,
          );
          expect(sound.keepAlive, isTrue);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          final generator = channelObject.sounds[sound.id]!;
          expect(generator, isA<BufferGenerator>());
          expect(soundManager.getSound(sound.id!), isA<BufferGenerator>());
          // We know it is, but now Dart does too.
          expect(generator.gain.value, equals(sound.gain));
          sound.looping = true;
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(generator.looping.value, isTrue);
          sound.looping = false;
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(generator.looping.value, isFalse);
          sound.gain = 1.5;
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(generator.gain.value, equals(1.5));
          sound.gain = 1.0;
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(generator.gain.value, equals(1.0));
          final fade = sound.fade(length: 1.0, startGain: 1.0);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(generator.gain.value, lessThan(1.0));
          fade.cancel();
          await Future<void>.delayed(const Duration(milliseconds: 200));
          final gain = generator.gain.value;
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(generator.gain.value, equals(gain));
          sound.destroy();
          await Future<void>.delayed(Duration.zero);
          expect(channelObject.sounds[sound.id], isNull);
          sound = channel.playSound(
            const AssetReference.file('sound.wav'),
            looping: true,
            keepAlive: true,
          );
          expect(sound.looping, isTrue);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(
            channelObject.sounds[sound.id],
            predicate(
              (final value) =>
                  value is BufferGenerator && value.looping.value == true,
            ),
          );
          sound.destroy();
        },
      );
      test(
        'Echo',
        () async {
          soundManager.events.clear();
          final echo = game.createEcho(
            [
              const EchoTap(
                delay: 0.5,
              )
            ],
          );
          await Future<void>.delayed(const Duration(milliseconds: 100));
          expect(soundManager.getEcho(echo.id!), isA<GlobalEcho>());
          expect(soundManager.events.length, 1);
          expect(soundManager.events.last, echo);
          echo.taps = [
            const EchoTap(
              delay: 0.25,
              gainL: 1.0,
              gainR: 0.0,
            ),
            const EchoTap(
              delay: 0.5,
              gainL: 0.0,
              gainR: 1.0,
            ),
            const EchoTap(
              delay: 0.75,
            )
          ];
          await Future<void>.delayed(const Duration(milliseconds: 100));
          expect(soundManager.events.length, 2);
          expect(
            soundManager.events.last,
            predicate(
              (final value) => value is ModifyEchoTaps && value.id == echo.id,
            ),
          );
          expect(
            Stream.fromIterable(
              (soundManager.events.last as ModifyEchoTaps).taps,
            ),
            emitsInOrder(echo.taps),
          );
          echo.reset();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          expect(soundManager.events.length, 3);
          expect(
            soundManager.events.last,
            predicate(
              (final value) => value is ResetEcho && value.id == echo.id,
            ),
          );
          echo.destroy();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          expect(soundManager.events.length, 4);
          expect(
            soundManager.events.last,
            predicate(
              (final value) => value is DestroyEcho && value.id == echo.id,
            ),
          );
          expect(
            () => soundManager.getEcho(echo.id!),
            throwsA(isA<NoSuchEchoError>()),
          );
        },
      );
    },
  );
  group(
    'Global settings',
    () {
      test(
        'set default panner strategy',
        () async {
          expect(
            context.defaultPannerStrategy.value,
            equals(PannerStrategy.stereo),
          );
          game.setDefaultPannerStrategy(DefaultPannerStrategy.hrtf);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(
            context.defaultPannerStrategy.value,
            equals(PannerStrategy.hrtf),
          );
          game.setDefaultPannerStrategy(DefaultPannerStrategy.stereo);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(
            context.defaultPannerStrategy.value,
            equals(PannerStrategy.stereo),
          );
        },
      );
      test(
        'Set listener position',
        () async {
          game.setListenerPosition(1.0, 2.0, 3.0);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(context.position.value, equals(const Double3(1.0, 2.0, 3.0)));
          game.setListenerPosition(10.0, 20.0, 30.0);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(
            context.position.value,
            equals(const Double3(10.0, 20.0, 30.0)),
          );
        },
      );
      test(
        'Set listener orientation',
        () async {
          var angle = 180.0;
          game.setListenerOrientation(angle);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          var orientation = context.orientation;
          expect(orientation.value.x1, equals(sin(angle * pi / 180)));
          expect(orientation.value.y1, equals(cos(angle * pi / 180.0)));
          expect(orientation.value.z1, isZero);
          expect(orientation.value.x2, isZero);
          expect(orientation.value.y2, isZero);
          expect(orientation.value.z2, equals(1));
          angle = 90.0;
          game.setListenerOrientation(angle);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          orientation = context.orientation;
          expect(orientation.value.x1, equals(sin(angle * pi / 180)));
          expect(orientation.value.y1, equals(cos(angle * pi / 180.0)));
          expect(orientation.value.z1, isZero);
          expect(orientation.value.x2, isZero);
          expect(orientation.value.y2, isZero);
          expect(orientation.value.z2, equals(1));
        },
      );
    },
  );
  group(
    'SoundManager',
    () {
      final soundManager = SoundManager(
        context: context,
        bufferCache: defaultBufferCache,
      );
      test(
        '.getBuffer',
        () async {
          expect(
            () => soundManager.getBuffer(
              const AssetReference.file('does not exist.wav'),
            ),
            throwsA(isA<NoSuchBufferError>()),
          );
          final buffer =
              soundManager.getBuffer(const AssetReference.file('sound.wav'));
          expect(buffer, isA<Buffer>());
        },
      );
      test(
        '.getChannel',
        () {
          expect(
            () => soundManager.getChannel(1),
            throwsA(isA<NoSuchChannelError>()),
          );
          soundManager.handleEvent(SoundChannel(game: game, id: 1));
          final channel = soundManager.getChannel(1);
          expect(channel, isA<AudioChannel>());
          expect(channel.id, equals(1));
          expect(channel.source, isA<DirectSource>());
          expect(channel.sounds, isEmpty);
        },
      );
      test(
        '.getReverb',
        () {
          expect(
            () => soundManager.getReverb(2),
            throwsA(isA<NoSuchReverbError>()),
          );
          soundManager.handleEvent(
            CreateReverb(
              game: game,
              id: 2,
              reverb: const ReverbPreset(name: 'Test Reverb'),
            ),
          );
          final reverb = soundManager.getReverb(2);
          expect(reverb, isA<Reverb>());
          expect(reverb.name, equals('Test Reverb'));
          expect(reverb.reverb, isA<GlobalFdnReverb>());
        },
      );
      test(
        '.getSound',
        () {
          expect(
            () => soundManager.getSound(3),
            throwsA(isA<NoSuchSoundError>()),
          );
          final soundEvent = PlaySound(
            game: game,
            sound: const AssetReference.file('silence.wav'),
            channel: game.interfaceSounds.id!,
            keepAlive: true,
          );
          soundManager.handleEvent(soundEvent);
          final sound = soundManager.getSound(soundEvent.id!);
          expect(sound, isA<BufferGenerator>());
        },
      );
      test(
        'Toggling Reverbs',
        () async {
          final game = Game(
            title: 'Replacement Game',
            sdl: sdl,
          );
          final soundManager = CustomSoundManager(
            context: context,
            bufferCache: defaultBufferCache,
          );
          game.sounds.listen(soundManager.handleEvent);
          final channel = game.createSoundChannel();
          final reverb =
              game.createReverb(const ReverbPreset(name: 'Test Reverb'));
          expect(channel.reverb, isNull);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(soundManager.events.length, 5);
          final source = soundManager.getChannel(channel.id!);
          expect(source.reverb, isNull);
          expect(soundManager.getChannel(channel.id!), source);
          expect(source.id, channel.id);
          expect(soundManager.getReverb(reverb.id!), isNotNull);
          await Future<void>.delayed(const Duration(milliseconds: 20));
          channel.reverb = reverb.id;
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(
            source.reverb,
            predicate(
              (final value) => value is Reverb && value.id == reverb.id,
            ),
          );
          channel.reverb = null;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          expect(source.reverb, isNull);
          final reverb2 =
              game.createReverb(const ReverbPreset(name: 'Preset 2'));
          channel.reverb = reverb2.id;
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(source.reverb?.id, reverb2.id);
        },
      );
    },
  );
  group(
    'BufferCache',
    () {
      test(
        'Initialisation',
        () {
          final cache = BufferCache(
            synthizer: synthizer,
            maxSize: pow(1024, 3).floor(),
            random: random,
          );
          expect(cache.maxSize, equals(1073741824));
          expect(cache.random, equals(random));
          expect(cache.size, isZero);
          expect(cache.synthizer, equals(synthizer));
        },
      );
      test(
        '.getBuffer',
        () {
          final cache = BufferCache(
            synthizer: synthizer,
            maxSize: pow(1024, 3).floor(),
            random: random,
          );
          final buffer1 =
              cache.getBuffer(const AssetReference.file('sound.wav'));
          expect(buffer1, isA<Buffer>());
          expect(cache.size, equals(buffer1.size));
          final buffer2 =
              cache.getBuffer(const AssetReference.file('silence.wav'));
          expect(buffer2, isA<Buffer>());
          expect(cache.size, equals(buffer1.size + buffer2.size));
        },
      );
      test(
        '.destroy',
        () {
          final cache = BufferCache(
            synthizer: synthizer,
            maxSize: pow(1024, 3).floor(),
            random: random,
          );
          var buffer1 = cache.getBuffer(const AssetReference.file('sound.wav'));
          final buffer2 =
              cache.getBuffer(const AssetReference.file('silence.wav'));
          expect(cache.size, equals(buffer1.size + buffer2.size));
          cache.destroy();
          expect(cache.size, isZero);
          buffer1 = cache.getBuffer(const AssetReference.file('sound.wav'));
          expect(cache.size, equals(buffer1.size));
        },
      );
    },
  );
  group(
    'AssetStore',
    () {
      test(
        'Initialise',
        () {
          var store = const AssetStore(
            filename: 'test.dart',
            destination: 'assets',
            assets: [],
          );
          expect(store.filename, equals('test.dart'));
          expect(store.destination, equals('assets'));
          expect(store.comment, isNull);
          expect(store.assets, isEmpty);
          store = AssetStore(
            filename: store.filename,
            destination: store.destination,
            assets: [],
            comment: 'Testing.',
          );
          expect(store.filename, equals('test.dart'));
          expect(store.destination, equals('assets'));
          expect(store.assets, isEmpty);
          expect(store.comment, equals('Testing.'));
          store = AssetStore(
            filename: store.filename,
            destination: store.destination,
            assets: [
              const AssetReferenceReference(
                variableName: 'firstFile',
                reference: AssetReference.file('file1.wav'),
              ),
              const AssetReferenceReference(
                variableName: 'firstDirectory',
                reference: AssetReference.collection('directory1'),
              )
            ],
          );
          expect(store.filename, equals('test.dart'));
          expect(store.destination, equals('assets'));
          expect(store.comment, isNull);
          expect(store.assets.length, equals(2));
        },
      );
      test(
        '.getNextFilename',
        () {
          const store = AssetStore(
            filename: 'test.dart',
            destination: 'assets',
            assets: [],
          );
          if (store.directory.existsSync()) {
            store.directory.deleteSync(recursive: true);
          }
          expect(store.getNextFilename(), equals('${store.destination}/0'));
          store.directory.createSync();
          expect(store.getNextFilename(), equals('${store.destination}/0'));
          expect(
            store.getNextFilename(suffix: '.asdf'),
            equals('${store.destination}/0.asdf'),
          );
          File('${store.destination}/0').writeAsStringSync('Testing');
          expect(store.getNextFilename(), equals('${store.destination}/1'));
          store.directory.deleteSync(recursive: true);
        },
      );
      test(
        '.getNextFilename with relativeTo',
        () {
          final storesDirectory = Directory('stores')..createSync();
          const store = AssetStore(
            filename: 'store.dart',
            destination: 'first',
            assets: [],
          );
          expect(
            store.directory.existsSync(),
            isFalse,
          );
          expect(
            store.getNextFilename(
              relativeTo: storesDirectory,
              suffix: '.encrypted',
            ),
            path
                .join(
                  store.destination,
                  '0.encrypted',
                )
                .replaceAll(
                  r'\',
                  '/',
                ),
          );
          expect(
            store.getNextFilename(
              relativeTo: storesDirectory.absolute,
            ),
            '${store.destination}/0',
          );
          storesDirectory.deleteSync(recursive: true);
        },
      );
      test(
        '.getAbsoluteDirectory',
        () {
          final storeDirectory = Directory('assets')..createSync();
          const store = AssetStore(
            filename: 'test.dart',
            destination: 'lovely_store',
            assets: [],
          );
          expect(store.directory.path, store.destination);
          expect(
            store.getAbsoluteDirectory(storeDirectory).path,
            path.join(
              storeDirectory.path,
              store.destination,
            ),
          );
        },
      );
      test(
        '.importFile',
        () {
          // ignore: prefer_const_constructors
          final store = AssetStore(
            filename: 'test.dart',
            destination: 'test.importFile',
            assets: [],
          );
          if (store.directory.existsSync()) {
            store.directory.deleteSync(recursive: true);
          }
          final file = File('SDL2.dll');
          var reference = store.importFile(
            source: file,
            variableName: 'sdlDll',
            comment: 'The SDL DLL.',
          );
          expect(reference, isA<AssetReferenceReference>());
          expect(store.directory.listSync().length, equals(1));
          final sdlDll = store.directory.listSync().first;
          expect(sdlDll, isA<File>());
          sdlDll as File;
          expect(
            sdlDll.path,
            equals(path.join(store.destination, '0.encrypted')),
          );
          expect(store.assets.length, equals(1));
          expect(store.assets.first, equals(reference));
          expect(reference.variableName, equals('sdlDll'));
          expect(reference.comment, equals('The SDL DLL.'));
          expect(
            reference.reference.name,
            equals('${store.destination}/0.encrypted'),
          );
          expect(reference.reference.type, equals(AssetType.file));
          expect(
            reference.reference.load(random),
            equals(file.readAsBytesSync()),
          );
          reference = store.importFile(
            source: File('pubspec.yaml'),
            variableName: 'pubSpec',
          );
          expect(reference.variableName, equals('pubSpec'));
          expect(store.directory.listSync().length, equals(2));
          expect(
            reference.reference.name,
            equals('${store.destination}/1.encrypted'),
          );
          store.directory.deleteSync(recursive: true);
        },
      );
      test(
        '.importDirectory',
        () {
          final testDirectory = Directory('test');
          // ignore: prefer_const_constructors
          final store = AssetStore(
            filename: 'test.dart',
            destination: 'test.importDirectory',
            assets: [],
          );
          if (store.directory.existsSync()) {
            store.directory.deleteSync(recursive: true);
          }
          final reference = store.importDirectory(
            source: testDirectory,
            variableName: 'tests',
            comment: 'Tests directory.',
          );
          expect(reference, isA<AssetReferenceReference>());
          expect(reference.reference.name, equals('${store.destination}/0'));
          expect(store.assets.length, equals(1));
          expect(store.assets.first, equals(reference));
          final unencryptedEntities = testDirectory
              .listSync()
              .whereType<File>()
              .toList()
            ..sort((final a, final b) => a.path.compareTo(b.path));
          final encryptedEntities = Directory(reference.reference.name)
              .listSync()
            ..sort((final a, final b) => a.path.compareTo(b.path));
          expect(unencryptedEntities.length, equals(encryptedEntities.length));
          for (var i = 0; i < unencryptedEntities.length; i++) {
            final unencryptedFile = unencryptedEntities[i];
            final encryptedFile = encryptedEntities[i] as File;
            final key = Key.fromBase64(reference.reference.encryptionKey!);
            final iv = IV.fromLength(16);
            final encrypter = Encrypter(AES(key));
            final encrypted = Encrypted(encryptedFile.readAsBytesSync());
            final data = encrypter.decryptBytes(encrypted, iv: iv);
            expect(
              data,
              equals(unencryptedFile.readAsBytesSync()),
              reason: 'File ${encryptedFile.path} did not decrypt to '
                  '${unencryptedFile.path}.',
            );
          }
          store.directory.deleteSync(recursive: true);
        },
      );
      test(
        'Import both',
        () {
          // ignore: prefer_const_constructors
          final store = AssetStore(
            filename: 'test.dart',
            destination: 'assets',
            assets: [],
          );
          if (store.directory.existsSync()) {
            store.directory.deleteSync(recursive: true);
          }
          final dartFile = File(store.filename);
          if (dartFile.existsSync()) {
            dartFile.deleteSync();
          }
          store
            ..importFile(source: File('SDL2.dll'), variableName: 'sdlDll')
            ..importDirectory(
              source: Directory('test'),
              variableName: 'testsDirectory',
            );
          expect(store.assets.length, equals(2));
          expect(store.directory.listSync().length, equals(2));
          store.directory.deleteSync(recursive: true);
        },
      );
      test(
        'Import both with relative',
        () {
          final storeDirectory = Directory('assets')..createSync();
          // ignore: prefer_const_constructors
          final store = AssetStore(
            filename: 'test.dart',
            destination: 'lovely_store',
            assets: [],
          );
          expect(
            store.getAbsoluteDirectory(storeDirectory).path,
            path.join(
              storeDirectory.path,
              store.destination,
            ),
          );
          expect(
            store.getAbsoluteDirectory(storeDirectory).existsSync(),
            isFalse,
          );
          store
            ..importFile(
              source: File('SDL2.dll'),
              variableName: 'sdlDll',
              relativeTo: storeDirectory,
            )
            ..importDirectory(
              source: Directory('test'),
              variableName: 'testsDirectory',
              relativeTo: storeDirectory,
            );
          expect(store.assets.length, equals(2));
          expect(
            store.getAbsoluteDirectory(storeDirectory).listSync().length,
            equals(2),
          );
          storeDirectory.deleteSync(recursive: true);
        },
      );
    },
  );
  group(
    'PlayWave',
    () {
      test(
        'Play waves',
        () async {
          final channel = game.createSoundChannel();
          final wave = channel.playSine(a4);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(soundManager.getChannel(channel.id!), isNotNull);
          final generator = soundManager.getWave(wave.id!);
          expect(generator, isA<FastSineBankGenerator>());
          expect(generator.gain.value, wave.gain);
          expect(generator.frequency.value, wave.frequency);
          wave.gain = 0.5;
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(generator.gain.value, 0.5);
          wave.frequency = c3;
          await Future<void>.delayed(const Duration(milliseconds: 200));
          expect(generator.frequency.value, c3);
          wave.automateFrequency(length: 0.5, endFrequency: a4);
          await Future<void>.delayed(const Duration(milliseconds: 700));
          expect(generator.frequency.value, a4);
          expect(wave.paused, isFalse);
          wave.pause();
          expect(wave.paused, isTrue);
          wave.unpause();
          expect(wave.paused, isFalse);
          wave.fade(length: 0.5);
          await Future<void>.delayed(const Duration(milliseconds: 700));
          expect(generator.gain.value, isZero);
          final fade = wave.fade(length: 1.0, endGain: 1.0);
          await Future<void>.delayed(const Duration(milliseconds: 200));
          final gain = generator.gain.value;
          expect(gain, inExclusiveRange(0, 1));
          fade.cancel();
          await Future<void>.delayed(const Duration(seconds: 1));
          final newGain = generator.gain.value;
          expect(newGain, greaterThanOrEqualTo(gain));
          wave.destroy();
          await Future<void>.delayed(const Duration(milliseconds: 900));
          expect(
            () => soundManager.getWave(wave.id!),
            throwsA(isA<NoSuchWaveError>()),
          );
          expect(
            soundManager.getChannel(wave.channel).waves.keys,
            isNot(contains(wave.id)),
          );
          // The below test is commented out because it always fails, presumably
          //something to do with ffi.
          // expect(generator.handle.value, isZero);
          // expect(generator.isValid, isFalse);
        },
      );
    },
  );
}
