/// Provides the [EventLoop] class.
import 'package:meta/meta.dart';

import 'error.dart';
import 'runner.dart';

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
  EventLoop(this.runner, {int framesPerSecond = 60})
      : _state = EventLoopState.notStarted,
        _timeBetweenTicks = 1000 / framesPerSecond;

  /// The runner to use in this loop.
  final Runner runner;
  EventLoopState _state;

  /// How often to wait between ticks.
  final double _timeBetweenTicks;

  /// The state of this loop.
  EventLoopState get state => _state;

  /// Start the event loop.
  @mustCallSuper
  Stream<int> run() async* {
    if (_state != EventLoopState.notStarted) {
      throw InvalidStateError(this);
    }
    _state = EventLoopState.running;
    while (_state != EventLoopState.stopped) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_state == EventLoopState.running) {
        final randomSounds = runner.ziggurat?.randomSounds;
        if (randomSounds != null) {
          for (final sound in randomSounds) {
            final nextPlay = sound.nextPlay;
            if (nextPlay == null || now >= nextPlay) {
              if (nextPlay != null) {
                runner.playRandomSound(sound);
              }
              final interval =
                  sound.minInterval + runner.random.nextInt(sound.maxInterval);
              sound.nextPlay = now + interval;
            }
          }
        }
      }
      tick();
      final tickTime = now - DateTime.now().millisecondsSinceEpoch;
      if (tickTime < _timeBetweenTicks) {
        await Future<void>.delayed(
            Duration(milliseconds: (_timeBetweenTicks - tickTime).floor()));
      }
      yield tickTime;
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
  void tick() async {}
}
