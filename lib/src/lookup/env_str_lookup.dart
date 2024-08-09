
import 'dart:io';

import 'package:commons_lang/commons_lang.dart';

/// Lookup implementation that gets values from the platform environment.
/// This can be used to retrieve environment variables.
/// See <code>Platform.fromEnvironment</code>
class EnvStrLookup extends StrLookup {

  /// Lookup a variable from the platform environment.
  @override
  String? lookup(String? key) {
    if(key==null) {
      return null;
    }
    return Platform.environment[key];
  }

}