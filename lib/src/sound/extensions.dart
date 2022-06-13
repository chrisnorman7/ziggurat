/// Provides various extensions used by this package.
import 'package:dart_synthizer/dart_synthizer.dart';

import '../json/reverb_preset.dart';

/// An extension for creating a [GlobalFdnReverb] instance from a
/// [ReverbPreset] instance.
extension MakeGlobalFdnReverb on ReverbPreset {
  /// Make a reverb object from this preset.
  GlobalFdnReverb makeReverb(final Context context) {
    final r = GlobalFdnReverb(context)
      ..meanFreePath.value = meanFreePath
      ..t60.value = t60
      ..lateReflectionsLfRolloff.value = lateReflectionsLfRolloff
      ..lateReflectionsLfReference.value = lateReflectionsLfReference
      ..lateReflectionsHfRolloff.value = lateReflectionsHfRolloff
      ..lateReflectionsHfReference.value = lateReflectionsHfReference
      ..lateReflectionsDiffusion.value = lateReflectionsDiffusion
      ..lateReflectionsModulationDepth.value = lateReflectionsModulationDepth
      ..lateReflectionsModulationFrequency.value =
          lateReflectionsModulationFrequency
      ..lateReflectionsDelay.value = lateReflectionsDelay
      ..gain.value = gain;
    return r;
  }
}
