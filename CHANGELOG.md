# Changelog

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
