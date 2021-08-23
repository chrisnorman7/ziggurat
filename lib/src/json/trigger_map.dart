/// Provides the [TriggerMap] class.
import 'package:json_annotation/json_annotation.dart';

import 'command_trigger.dart';

part 'trigger_map.g.dart';

/// A class for holding trigger-to-command mappings.
@JsonSerializable()
class TriggerMap {
  /// Create an instance.
  TriggerMap(this.triggers);

  /// Create an instance from a JSON object.
  factory TriggerMap.fromJson(Map<String, dynamic> json) =>
      _$TriggerMapFromJson(json);

  /// The trigger mapping.
  ///
  /// Keys are command names.
  final Map<String, CommandTrigger> triggers;

  /// Register a new command with the given [name] and [trigger].
  void registerCommand(
          {required String name, required CommandTrigger trigger}) =>
      triggers[name] = trigger;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$TriggerMapToJson(this);
}
