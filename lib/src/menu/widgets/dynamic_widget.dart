// ignore_for_file: prefer_final_parameters
/// Provides the [DynamicWidget] class.
import '../../json/message.dart';
import '../menu_item.dart';
import 'widgets_base.dart';

/// A widget whose label is dynamic.
class DynamicWidget extends Widget {
  /// Create an instance.
  const DynamicWidget(
    this.onGetLabel, {
    super.onActivate,
    super.activateSound,
  });

  /// The method that should be used to get the label.
  final Message Function(MenuItem menuItem) onGetLabel;

  @override
  Message? getLabel(final MenuItem menuItem) => onGetLabel(menuItem);
}
