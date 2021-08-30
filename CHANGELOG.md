# Changelog

## [0.6.8]

### Changed

* Menus now properly announce themselves when they're revealed.

## [0.6.7]

### Added

* Added an activate `sound` property to `Button`.

### Changed

* When activating a menu, if the current widget is a button, play the button's activate sound.

## [0.6.6]

### Added

* Added a time offset to `Game.registerTask` for tasks that are scheduled before calling `Game.run`..

## [0.6.5]

### Changed

* Show menu items with the `onPush` method, rather than `onReveal`.

## [0.6.4]

### Changed

* Show the current menu item when revealing a menu.

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
