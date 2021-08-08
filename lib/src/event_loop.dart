/// Provides the [EventLoop] class.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';

import 'command.dart';
import 'error.dart';

/// The state of an [EventLoop] instance.
enum EventLoopState {
  /// The instance has not yet had its [EventLoop.run] method called.
  notStarted,

  /// The event loop is running normally.
  running,

  /// The event loop has been paused with the [EventLoop.pause] method.
  paused,

  /// The event loop has been stopped with its [EventLoop.stop] method.
  stopped,
}

/// An event loop.
///
/// Instances of this class can be used to run the game without relying on any
/// asynchronous code.
class EventLoop {
  /// Create a loop.
  EventLoop(this.sdl, {this.commandHandler, int framesPerSecond = 60})
      : _state = EventLoopState.notStarted,
        _timeBetweenTicks = (1000 / framesPerSecond).floor();

  /// The sdl bindings to use.
  final Sdl sdl;

  /// The command handler to use in this loop.
  CommandHandler? commandHandler;

  EventLoopState _state;

  /// How often to wait between ticks.
  final int _timeBetweenTicks;

  /// The state of this loop.
  EventLoopState get state => _state;

  /// Returns `true` if [state] is either [EventLoopState.running] or
  /// [EventLoopState.paused].
  bool get isRunning =>
      _state == EventLoopState.paused || _state == EventLoopState.running;

  /// Start the event loop.
  @mustCallSuper
  Stream<Event> run() async* {
    if (_state != EventLoopState.notStarted) {
      throw InvalidStateError(this);
    }
    _state = EventLoopState.running;
    var tickStart = 0;
    var tickEnd = DateTime.now().millisecondsSinceEpoch;
    while (isRunning) {
      tickStart = DateTime.now().millisecondsSinceEpoch;
      yield* tick(tickStart - tickEnd, tickStart);
      tickEnd = DateTime.now().millisecondsSinceEpoch;
      final tickTime = tickEnd - tickStart;
      if (tickTime < _timeBetweenTicks) {
        await Future<void>.delayed(
            Duration(milliseconds: _timeBetweenTicks - tickTime));
      }
    }
  }

  /// Pause the loop.
  @mustCallSuper
  void pause() {
    if (_state != EventLoopState.running) {
      throw InvalidStateError(this);
    }
    _state = EventLoopState.paused;
  }

  /// Unpause (resume) the loop.
  @mustCallSuper
  void unpause() {
    if (_state != EventLoopState.paused) {
      throw InvalidStateError(this);
    }
    _state = EventLoopState.running;
  }

  /// Stop the loop entirely.
  ///
  /// The [run] method will need to be used to restart this instance.
  @mustCallSuper
  void stop() {
    if (_state != EventLoopState.running && _state != EventLoopState.paused) {
      throw InvalidStateError(this);
    }
    _state = EventLoopState.stopped;
  }

  /// Tick the loop.
  @mustCallSuper
  Stream<Event> tick(int timeDelta, int now) async* {
    final handler = commandHandler;
    // Get SDL events.
    while (true) {
      final event = sdl.pollEvent();
      if (event == null) {
        break;
      }
      yield event;
      if (handler != null) {
        if (event is KeyboardEvent) {
          if (event.repeat == false) {
            handler.handleKeyboardEvent(event);
          }
        } else if (event is ControllerButtonEvent) {
          handler.handleButtonEvent(event);
        }
      }
    }
    if (handler != null) {
      for (final command in handler.commands) {
        if (command.nextRun >= now) {
          handler.startCommand(command, now);
        }
      }
    }
  }
}
