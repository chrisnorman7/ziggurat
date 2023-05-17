/// Provides the [SettingDefaults] class.

/// Defaults for a setting..
class SettingDefaults<T extends num> {
  /// Create an instance.
  const SettingDefaults({
    required this.defaultValue,
    required this.min,
    required this.max,
  });

  /// The default value.
  final T defaultValue;

  /// The minimum value.
  final T min;

  /// The maximum value.
  final T max;
}
