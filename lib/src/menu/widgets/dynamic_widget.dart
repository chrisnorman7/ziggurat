/// Provides the [DynamicWidget] class.
import '../../json/asset_reference.dart';
import '../../json/message.dart';
import '../../task.dart';
import '../menu_item.dart';
import 'widgets_base.dart';

/// A widget whose label is dynamic.
class DynamicWidget extends Widget {
  /// Create an instance.
  const DynamicWidget(
    this.onGetLabel, {
    TaskFunction? onActivate,
    AssetReference? activateSound,
  }) : super(onActivate: onActivate, activateSound: activateSound);

  /// The method that should be used to get the label.
  final Message Function(MenuItem menuItem) onGetLabel;

  @override
  Message? getLabel(MenuItem menuItem) => onGetLabel(menuItem);
}
