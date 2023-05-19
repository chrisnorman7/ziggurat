# Ziggurat

## Description

This package allows you to build audio games with Dart.

It started out as tools for making maps, but has since expanded to provide a
general set of APIs for making audio games.

## Sounds

Please note that since version 0.50.0, Ziggurat has full sound support in the
library, by way of the
[SoundBackend](https://pub.dev/documentation/ziggurat/latest/sound/SoundBackend-class.html)
class, and in particular, the
[SynthizerSoundBackend](https://pub.dev/documentation/ziggurat/latest/sound/SynthizerSoundBackend-class.html)
class, which handles playing sounds through
[Synthizer](https://synthizer.github.io/).

As such, there is no longer any need for the
[ziggurat_sounds](https://pub.dev/packages/ziggurat_sounds) package, and this
has been discontinued.

## Engine Support

To cut down on the amount of non-creative code I had to write for my own projects, I created the [Crossbow](https://github.com/chrisnorman7/crossbow) game engine.
