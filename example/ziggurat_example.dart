// ignore_for_file: avoid_print
/// An example map.
import 'dart:io';
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:ziggurat/ziggurat.dart';

/// Game state to keep track of progress.
class GameState {}

/// An even loop with an overridden [outputText] method.
class ExampleEventLoop extends EventLoop<GameState> {
  /// Create an instance.
  ExampleEventLoop(this.window,
      {required BufferStore bufferStore,
      required CommandHandler commandHandler,
      required Context context,
      required Sdl sdl})
      : super(
            bufferStore: bufferStore,
            commandHandler: commandHandler,
            gameState: GameState(),
            context: context,
            sdl: sdl);

  /// The sdl window to use.
  final Window window;

  /// Override the output function.
  @override
  void outputText(String value) => window.title = value;
}

/// The temple used in this example.
class Temple extends Ziggurat {
  /// Create an instance.
  Temple(BufferStore bufferStore) : super('Temple') {
    final lightsSound = bufferStore
        .getSoundReference('ambiances/546153__ssssrt__buzzing-lights.wav');
    final defaultReverb = ReverbPreset('Default');
    final wallSound =
        bufferStore.getSoundReference('misc/249618__vincentm400__invalid.mp3');
    final westWall = Box<Wall>('West Wall', Point(0, 1), Point(1, 21), Wall(),
        sound: wallSound);
    final storageRoom = Box<Surface>(
        'Storage room',
        westWall.cornerSe + Point(1, 0),
        westWall.end + Point(20, 0),
        Surface(reverbPreset: defaultReverb),
        sound: bufferStore.getSoundReference('footsteps/wood'));
    final dividingWall = Box<Wall>(
        'Dividing Wall',
        storageRoom.cornerSe + Point(1, 0),
        storageRoom.end + Point(1, -3),
        Wall(),
        sound: wallSound);
    final doorway = Box(
        'Doorway',
        dividingWall.cornerNw + Point(0, 1),
        storageRoom.end + Point(dividingWall.width, 0),
        Door(
            reverbPreset: defaultReverb,
            open: false,
            openMessage: Message(
                sound: bufferStore.getSoundReference(
                    'doors/431117__inspectorj__door-front-opening-a.wav')),
            closeAfter: 1000,
            closeMessage: Message(
                sound: bufferStore.getSoundReference(
                    'doors/431118__inspectorj__door-front-closing-a.wav'))),
        sound: bufferStore.getSoundReference('footsteps/metal'));
    final mainFloor = Box<Surface>(
        'Main floor',
        dividingWall.cornerSe + Point(1, 0),
        doorway.end + Point(20, 0),
        Surface(reverbPreset: ReverbPreset('Main Floor Reverb', t60: 5.0)),
        sound: bufferStore.getSoundReference('footsteps/concrete'));
    final eastWall = Box<Wall>('East Wall', mainFloor.cornerSe + Point(1, 0),
        mainFloor.end + Point(1, 0), Wall(),
        sound: wallSound);
    final northWall = Box<Wall>('North Wall', westWall.cornerNw + Point(0, 1),
        eastWall.end + Point(0, 1), Wall(),
        sound: wallSound);
    final southWall = Box<Wall>('South Wall', westWall.start - Point(0, 1),
        eastWall.cornerSe - Point(0, 1), Wall(),
        sound: wallSound);
    boxes.addAll([
      westWall,
      storageRoom,
      dividingWall,
      doorway,
      mainFloor,
      eastWall,
      northWall,
      southWall
    ]);
    randomSounds.addAll([
      RandomSound(bufferStore.getSoundReference('misc/random'),
          mainFloor.start.toDouble(), mainFloor.end.toDouble(), 5000, 15000,
          minGain: 0.1, maxGain: 0.5)
    ]);
    ambiances.addAll([
      Ambiance(lightsSound,
          Point<double>(storageRoom.end.x.toDouble(), doorway.centre.y),
          gain: 2.0),
      Ambiance(lightsSound,
          Point<double>(mainFloor.cornerNw.x.toDouble(), doorway.centre.y),
          gain: 2.0),
      Ambiance(
          bufferStore.getSoundReference(
              'ambiances/325647__shadydave__expressions-of-the-mind-piano-loop.mp3'),
          null,
          gain: 0.25)
    ]);
    initialCoordinates = mainFloor.start.toDouble();
  }
}

/// The runner for this example.
class ExampleRunner extends Runner {
  /// Create an instance.
  ExampleRunner(EventLoop eventLoop, RunnerSettings runnerSettings, this.window,
      Ziggurat z)
      : super(eventLoop, Box('Player', Point(0, 0), Point(0, 0), Player()),
            runnerSettings: runnerSettings) {
    ziggurat = z;
  }

  final Window window;

  /// Output the new tile name.
  @override
  void onBoxChange(
      {required Box<Agent> agent,
      required Box? newBox,
      required Box? oldBox,
      required Point<double> oldPosition,
      required Point<double> newPosition}) {
    super.onBoxChange(
        agent: agent,
        newBox: newBox,
        oldBox: oldBox,
        oldPosition: oldPosition,
        newPosition: newPosition);
    if (newBox != null) {
      eventLoop.outputText(newBox.name);
    }
  }
}

/// Run the example.
Future<void> main() async {
  final synthizer = Synthizer()..initialize();
  final ctx = synthizer.createContext()
    ..defaultPannerStrategy = PannerStrategies.hrtf;
  final bufferStore = BufferStore(Random(), synthizer)
    ..addVaultFile(await VaultFile.fromFile(
        File('loading.dat'), 'nNxiqTmQ/G1qWtSIm6YcjrxpwJrPwdUS4W97wWfTOkg='));
  final buffer = bufferStore.getBuffer(
      'loading/269169__heshl__transition-from-loading-screen-into-fps-game.wav',
      SoundType.file);
  final directSource = DirectSource(ctx)
    ..gain = 0.7
    ..addGenerator(BufferGenerator(ctx)
      ..setBuffer(buffer)
      ..configDeleteBehavior(linger: true)
      ..looping = true);
  final sdl = Sdl()..init();
  final window = sdl.createWindow('Loading...');
  bufferStore
    ..addVaultFile(await VaultFile.fromFile(
        File('misc.dat'), 'e9x6CC+NUK2dLlo+WR6l1NOAEIkBsoNc9OO3aZM0eEs='))
    ..addVaultFile(await VaultFile.fromFile(
        File('ambiances.dat'), 'q8I/PKPHPQSlBSsfTrMtlFIcEr+SkBmdZTNpl53D/oc='))
    ..addVaultFile(await VaultFile.fromFile(
        File('doors.dat'), 'bXEt385EY8Y13dxPpu6gXSi2tvmQGTh7tAJcnegu91g='))
    ..addVaultFile(await VaultFile.fromFile(
        File('footsteps.dat'), 'mBZ587QH7nPY8cv+zqP41O8wJVuSWkLzEUAsdB+aUeo='))
    ..addVaultFile(await VaultFile.fromFile(
        File('radar.dat'), 'VnNyQvdM71VklKZvGyO2aQkrET6JnSHC2y3EtmAb1pQ='));
  final runnerSettings = RunnerSettings(
      directionalRadarEmptySpaceSound:
          bufferStore.getSoundReference('radar/empty_space.wav'),
      directionalRadarWallSound:
          bufferStore.getSoundReference('radar/walls.wav'),
      directionalRadarDoorSound:
          bufferStore.getSoundReference('radar/doors.wav'));
  window.title = 'Ziggurat Example';
  final interface = ExampleEventLoop(window,
      context: ctx,
      bufferStore: bufferStore,
      sdl: sdl,
      commandHandler: CommandHandler())
    ..registerDefaultCommands();
  final t = Temple(bufferStore);
  final r = ExampleRunner(interface, runnerSettings, window, t);
  interface.commandHandler.registerCommand(Command(
      name: 'pause',
      description: 'Pause or unpause the game',
      defaultTrigger: CommandTrigger(
        button: GameControllerButton.rightShoulder,
        keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_P),
      ),
      onStart: () {
        if (interface.state == EventLoopState.running) {
          interface
            ..pause()
            ..outputText('Paused.');
        } else if (interface.state == EventLoopState.paused) {
          interface
            ..unpause()
            ..outputText('Unpaused.');
        }
      }));
  final triggerFile = File('triggers.json');
  if (triggerFile.existsSync()) {
    interface.commandHandler.loadTriggers(triggerFile);
  }
  directSource.destroy();
  interface.runner = r;
  await for (final event in interface.run()) {
    if (event is ControllerDeviceEvent) {
      if (event.state == DeviceState.added) {
        sdl.openGameController(event.joystickId);
      }
    }
  }
  window.destroy();
  interface.commandHandler.dumpTriggers(triggerFile);
}
