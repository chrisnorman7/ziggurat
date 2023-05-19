/// The main library.
///
/// ## Description
///
/// This package attempts to give you common methods and classes that will be
/// useful when creating games.
///
/// The primary focus is on audio games, and honestly there are probably better
/// packages for full-on video games. That said, if you want to use this library
/// to make a video game, I'm certainly not going to stop you.
///
/// ## Tools
///
/// Writing [AssetReference]s, [Menu]s, and generally fleshing out [Level]s with
/// [Ambiance]s and [RandomSound]s - not to mention tying [CommandTrigger]s to
/// functions can be tedious. To this end, the
/// [Crossbow](https://github.com/chrisnorman7/crossbow) application
/// can be used to automate many common Ziggurat tasks, then generate the code
/// for you.
///
/// If you want to stay on the command line, the
/// [ziggurat_utils](https://pub.dev/packages/ziggurat_utils) package has
/// various utilities that you may find useful for creating and modifying
/// [AssetReference]s.
library ziggurat;

import 'levels.dart';
import 'menus.dart';
import 'sound.dart';
import 'src/json/asset_reference.dart';
import 'src/json/command_trigger.dart';

export 'src/command.dart';
export 'src/controller_axis_dispatcher.dart';
export 'src/directions.dart';
export 'src/error.dart';
export 'src/extensions.dart';
export 'src/game.dart';
export 'src/json/asset_reference.dart';
export 'src/json/asset_reference_reference.dart';
export 'src/json/asset_store.dart';
export 'src/json/axis_setting.dart';
export 'src/json/command_trigger.dart';
export 'src/json/message.dart';
export 'src/json/rumble_effect.dart';
export 'src/json/tile.dart';
export 'src/json/tile_map.dart';
export 'src/json/trigger_map.dart';
export 'src/math.dart';
export 'src/multi_grid.dart';
export 'src/next_run.dart';
export 'src/preferences.dart';
export 'src/setting_defaults.dart';
export 'src/tasks/task.dart';
export 'src/tasks/task_runner.dart';
