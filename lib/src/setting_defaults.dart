/// Provides the [SettingDefaults] class.

/// Defaults for a setting..
class SettingDefaults<T extends num> {
  /// Create an instance.
  const SettingDefaults(this.defaultValue, this.min, this.max);

  /// The default value.
  final T defaultValue;

  /// The minimum value.
  final T min;

  /// The maximum value.
  final T max;
}
