# Changelog

## [0.44.2]

### Added

* Allow instances of `AssetReferenceMenu` to be cancelled.

## [0.44.0]

### Changed

* Updated dependencies.
* Code clean-up.

## [0.43.1]

### Added

* Added the `angleBetween` extension method on `Point<double>`.

## [0.43.0]

### Changed

* `Editor.toggleShift` is now a `shiftPressed` property.

## [0.42.2]

### Changed

* Downgraded lints.
* Upgraded dart_sdl.

## [0.42.1]

### Added

* Automatically open joysticks.

## [0.42.0]

### Fixed

* Fixed some bugs around command scheduling.

### Changed

* Updated dart_sdl.

## [0.41.1]

### Fixed

* Fixed a menu crash when there are no menu items.

## [0.41.0]

### Added

* Added a `soundChannel` property to the `Menu` class.

## [0.40.2]

### Fixed

* Handle level music properly.

## [0.40.1]

### Fixed

* The `ParameterMenu` class no longer inadvertently changes the type of its `.menuItems` property.

## [0.40.0]

### Changed

* Added a `gain` property to the `music` class.

## [0.39.1]

### Fixed

* Export the `Music` class.

## [0.39.0]

### Added

* Added the `Music` class.
* Added a `music` field to the `Level` class.
* Added `music` arguments to the constructors of all `Level` subclasses.

### Fixed

* Added `music`, `ambiances`, and `randomSounds` arguments to the constructors of the `FilePickerMenu` class.

### Changed

* Updated the minimum Dart version.

## [0.38.1]

### Changed

* Downgraded path.

## [0.38.0]

### Added

* Tasks can now be bound to levels.

## [0.37.0]

### Changed

* Use faster SDL-based timestamps.
* Start using relative timings for tasks.
* Rip out unmaintained and under-tested mapping code.
* Moved a load of functions into their proper places.

## [0.36.0]

### Fixed

* Stop handling commands after the first one.

### Changed

* The `level.startCommand` and `level.stopCommand` methods now return boolean values.

## [0.35.0]

### Changed

* Make `SoundChannel.reverb` a property.

## [0.34.0]

### Added

* There is now the ability to set custom IDs on `PlaySound` instances.

## [0.33.0]

### Changed

* Fixed a bug where it became impossible to navigate with the arrow keys in menus with number lock on.

## [0.32.0]

### Changed

* Changed a bunch of constructors to use keyword-only arguments.

## [0.31.1]

### Fixed

* Fixed links in changelog.

## [0.31.0]

### Added

* Added the `SoundChannel.playWave` method.
* Added convenience methods on `SoundChannel` for playing waves.

### Changed

* Added a `channel` argument to the `PlayWave` constructor.

## [0.30.0]

### Added

* Added the ability o pause and unpause waves.
* Added more tests.

## [0.29.0]

### Added

* Added the ability to play waves.

## [0.28.1]

### Fixed

* Fixed a link in the readme.

### Changed

* Updated the package description to bring it more in line with what pub.dev expects.

## [0.28.0]

### Changed

* Made the `ReverbPreset` class serializable.

## [0.27.1]

### Changed

*( Include the asset type in `PlaySound` descriptions`)

## [0.27.0]

### Added

* Added useful descriptions to sound events.
* Added the `AssetReferenceMenu` class.

### Changed

* Renamed `LoopSound` to `SetSoundLooping`.

## [0.26.1]

### Changed

* Updated dependencies.

## [0.26.0]

### Added

* Made it possible to serialize many classes.
* Added the `ParameterMenu` class.

### Changed

* Changed the signatures for A lot of functions to use named arguments.
* Moved some files into the `json` directory.
* Changed the relevant exports so that normal `package:ziggurat/xxx.dart` imports will work without changes.
* Reformatted some code.

### Fixed

* Fixed an oversight in `game.handleSdlEvent` where controllers would get removed when `remap` event was received.

## [0.25.7]

### Added

* Added the `LevelStub` class.
* Added the `Level.fromStub` constructor.

### Removed

* Removed random sound and ambiance playback storage to the `Level` class.

## [0.25.6]

### Added

* Added the `SimpleMenuItem` class.

## [0.25.5]

### Fixed

* Fixed a bug where empty text input events were used for menu searches.

## [0.25.4]

### Added

* Added an `onStart` parameter to `Game.run`.

## [0.25.3]

### Added

* Added the `FilePickerMenu` class.

## [0.25.2]

### Added

* Instances of `CommandKeyboardKey` are now printable.

## [0.25.1]

### Fixed

* Random sounds now get rescheduled after playing for the first time.

## [0.25.0]

### Changed

* Changed the way random sound playback is handled.

## [0.24.0]

### Added

* Added the `emptyMessage` constant.

### Changed

* Any widget can now specify an `onActivate` method.

## [0.23.6]

### Added

* Added the `DynamicWidget` class.

## [0.23.5]

### Changed

* Fixed a bug with the `MultiGridLevel` class.

## [0.23.4]

### Added

* Added a `after` argument to `Game.pushLevel`, so that levels can be pushed after a specified delay.

## [0.23.3]

### Added

* Added the `MultiGridLevelRow.fromDict` factory constructor.

## [0.23.2]

### Added

* Added the ability to search menus.
* Expose the current position in a menu.

## [0.23.1]

### Fixed

* Fixed a crash when moving right in a multi grid level with a single item in a row.

## [0.23.0]

### Added

* Added the `MultiGridLevel`.

### Changed

* Split the package up a little bit.

## [0.22.9]

### Changed

* Swapped the default axes used for tile map movement.

## [0.22.8]

### Fixed

* Old menu sounds are now destroyed when menus are popped.

## [0.22.7]

### Changed

* You can now turn and move simultaneously with `TileMapLevel` instances.

## [0.22.6]

### Added

* Reminders to call super methods on the `TileMapLevel` class.

## [0.22.5]

### Added

* Added the `SceneLevel` class.
* Added the `DialogueLevel` class.
* Added the `TileMapLevel` class.
* Added the `AxisSetting` class.
* Added the `Level.tick` method.
* Added some direction enums for use with `TileMapLevel`.

### Changed

* Renamed `Directions` to `CardinalDirections`.

## [0.22.4]

### Added

* Added the `SoundChannelGroup` class.

## [0.22.3]

### Changed

* Changing the reverb changes the reverb ID again.

## [0.22.2]

### Changed

* Changing channel reverb no longer changes the stored reverb ID.

## [0.22.1]

Added

* You can now set (or clear) reverbs for sound channels.

## [0.22.0]

### Changed

* Changed the signature for the `Box` constructor.
* The `Box.onActivate` callback is now an instance variable, rather than a class method.
* Renamed `Surface.moveInterval` to `maxMoveInterval`.
* Make `Box.sound` a `List`.
* Rename `Box.sound` to `sounds`.

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

* Moved the `AssetStore` class to the [ziggurat_sounds](https://pub.dev/packages/ziggurat_sounds) package.

## [0.16.1]

### Added

* Added a `getFile` method to the `AssetReference` class.

## [0.16.0]

### Added

* Added the ability to load files (and random files) via the `AssetReference.load` method.
* Added the `AssetStore` class, which will be used by [ziggurat_utils](https://pub.dev/packages/ziggurat_utils).
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

* Updated the API to reflect changes in [dart_synthizer](https://pub.dev/packages/dart_synthizer).

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
