# Changelog

## [0.22.0]

### Changed

* Changed the signature for the `Box` constructor.

## [0.21.4]

### Added

* Added the `BoxMapLevel` class.

## [0.21.3]

### Added

* It is now possible to unregister game tasks.

## [0.21.2]

### Fixed

* Tasks can now be registered from within other task functions.

## [0.21.1]

### Added

* Added checked and unchecked sounds for checkboxes.
* Added the `Widget.getLabel` method.

### Changed

* Any widget can now override the `getLabel` method to override the label on its parent `MenuItem`..

## [0.21.0]

### Added

* Added a `Editor` level.
* Added a `onCancel` parameter to the `Menu` constructor, so the `cancel` method doesn't need to be overridden every time.
* When creating a `Menu` instance, it is now possible to set the initial position within the menu.
* You can now specify random sounds for `Menu` instances.
* It is now possible to specify multiple triggers with the same name.
* Added the `ControllerAxisDispatcher` class.

### Fixed

* Fixed a broken link in the documentation for `angleToRad`.

### Changed

* Cleaned up code.
* Update SDL.
* Added a bunch of parameters to the `Menu` constructor, to replace the old `registerCommands` method.
* The `TriggerMap` class now uses a list for command triggers.

### Removed

* Removed `Menu.registerCommands`, in favour of the new parameters to the constructor.
* Removed the unused `InvalidCommandNameError` error.
* Removed the unused `InvalidStateError` error.

## [0.20.1]

### Changed

* Updated SDL.

## [0.20.0]

### Changed

* The `onChanged` argument to `ListButton` is now mandatory.

## [0.19.0]

### Added

* Added the `ListButton` class.
* Added the `Checkbox` class.

### Fixed

* Ambiance positions are now respected.

### Changed

* Ambiances now store their own playback information.

### Removed

* Removed the `Level.ambianceSounds` list.

## [0.18.2]

### Added

* It is now possible to add random sounds to any level.
* It is now possible to know when a `Game` instance started running with the `started` property.
* You can now get the time that a `Game` instance has been running with the `runDurationMilliseconds` integer, and the `runDurationSeconds` double.

### Changed

* Made `Game.window` a readonly property.

## [0.18.1]

### Added

* Add events for setting global audio settings.

## [0.18.0]

### Changed

* Updated dart_sdl.

## [0.17.0]

### Removed

* Moved the `AssetStore` class to the [ziggurat_sounds]([URL](https://pub.dev/packages/ziggurat_sounds)) package.

## [0.16.1]

### Added

* Added a `getFile` method to the `AssetReference` class.

## [0.16.0]

### Added

* Added the ability to load files (and random files) via the `AssetReference.load` method.
* Added the `AssetStore` class, which will be used by [ziggurat_utils]([URL](https://pub.dev/packages/ziggurat_utils)).
* Added a load more tests.

### Changed

* Renamed `SoundReference` to `AssetReference`.

## [0.15.1]

### Added

Added a `encryptionKey` field to the `SoundReference` class.

## [0.15.0]

### Added

* Added the `SoundPositionScalar` class.
* Added the `SoundPositionAngular` class.

### Removed

* Removed the `SoundPositionPanned` class.

### Changed

* Updated the API to reflect changes in [dart_synthizer]([URL](https://pub.dev/packages/dart_synthizer)).

## [0.14.1]

### Changed

* Changed the constructor of `SoundPositionPanned` to allow the use of either  a scalar value, or an azimuth / elevation pair.

## [0.14.0]

### Removed

* Removed the `elevation` property from `SoundPositionPanned`.

## [0.13.3]

### Added

* Added the `Menu.addButton` convenience method.
* Added the `Menu.addLabel` convenience method.

## [0.13.2]

### Added

* Added the `PitchBend` sound event.
* Added events for applying filters to `SoundChannel` instances.

## [0.13.1]

### Added

* Added the `CommandTrigger.basic constructor.
* Added more tests.

## [0.13.0]

### Changed

* No longer allow changing from one sound position type to another.

## [0.12.0]

### Added

* Added the `SetSoundChannelPosition` event.

### Changed

* Made both parameters to the constructor of `SoundPositionPanned` optional.
* Made all parameters to the constructor of `SoundPosition3d` optional.

## [0.11.1]

### Added

* Added the `Game.replaceLevel` method.

## [0.11.0]

### Added

* Added the ability to specify a fade time for ambiances when popping levels.

## [0.10.2]

### Changed

* Made `Game.destroy` not a future.

## [0.10.1]

### Added

* You can now set a time to wait before applying an automation fade.

## [0.10.0]

### Changed

* The `AutomationFade.cancel` method now returns void.

## [0.9.0]

### Changed

* Changed the way sound events are created and what information they hold.

## [0.8.0]

### Added

* Added the ability to cancel a fade.

### Changed

* Added a reference to the sound that should be faded.

## [0.7.1]

### Added

* Added an `AutomationFade` sound event.

## [0.7.0]

### Removed

* Moved executable scripts and accompanying JSON schemas to to the [ziggurat_sounds](https://github.com/chrisnorman7/ziggurat_sounds) package.

## [0.6.10]

### Added

* Maintain a list of open game controllers on `Game` instances.

## [0.6.9]

### Changed

* Fixed a bug with double-playing menu ambiances.

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
