// ignore_for_file: avoid_print

import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:ziggurat/basic_interface.dart';
import 'package:ziggurat/ziggurat.dart';

Future<void> main() async {
  final sdl = Sdl()..init();
  final window = sdl.createWindow('Test');
  final synthizer = Synthizer()..initialize();
  final ctx = synthizer.createContext();
  final eventLoop = BasicInterface(
      sdl,
      Runner<Object>(ctx, BufferStore(Random(), synthizer), Object(),
          Box('Player', Point(0, 0), Point(0, 0), Player())),
      SoundReference('test', SoundType.file));
  await for (final event in eventLoop.run()) {
    if (event is KeyboardEvent) {
      if (event.key.scancode == ScanCode.SCANCODE_Q) {
        break;
      } else if (event.key.scancode == ScanCode.SCANCODE_U) {
        window.title = 'Updating game controllers.';
        sdl.sdl.SDL_GameControllerUpdate();
      }
    } else if (event is ControllerDeviceEvent) {
      if (event.state == DeviceState.added) {
        final controller = sdl.openGameController(event.joystickId);
        print(controller.name);
        print(controller.attached);
      } else {
        print('Controller removed.');
      }
    } else if (event is ControllerButtonEvent) {
      window.title = 'Controller button #${event.button}';
    } else if (event is JoyButtonEvent) {
      window.title = 'Joystick #${event.button}';
    } else {
      window.title = event.toString();
    }
  }
  window.destroy();
  sdl.quit();
}
