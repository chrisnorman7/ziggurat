# Changelog

## [0.6.3]

### Changes

* `SoundChannel.playSound` now respects the `looping` argument.

## [0.6.2]

* Destroy interface and ambiance channels with `Game.destroy`.

## [0.6.1]

### Changed

* Stop menu sounds playing when returning to the top of the menu.

## [0.6.0]

### Changed

* Bumped version number.

## [0.5.0]

### Added

* Added a `keepAlive` property to the `Message` class.
* Added a `Game.outputText` method.
* Added a `Game.outputSound` method.

### Changed

* Split `Game.outputMessage` up to use the new `outputText` and `outputSound` methods.
* Made `Game.outputMessage` return a `PlaySound` instance.
* Remove `oldSound`, when passed as an argument to `outputMessage`.
* Changed the constructor for the `Ambiance` class.

## [0.4.0]

### Added

* Added a `keepAlive` property to the `PlaySound` event.

### Changed

* Calling `destroy` on a `PlaySound` event with its `keepAlive` property set to `false` will result in a `DeadSound` error being thrown.

## [0.3.2]

### Changed

* Sound events are now queued while the stream has no listeners or is paused.

## [0.3.1]

### Added

* Added a `channel` property to `DestroySound`.

## [0.3.0]

### Changed

* Changed the type of `PlaySound.channel` from `SoundChannel` to `int`.

## [0.2.0]

### Added

* Added a `destroy` method to the `CreateReverb` class.

### Changed

* Reverbs must now be destroyed with `CreateReverb.destroy`.
* Renamed `PlaySound.destroySound` to `destroy`.

### Removed

* Removed the `Game.destroyReverb` method.

## [0.1.0]

### Added

* Sound channels.

## [0.0.0]

Initial version.
