// Licensed to the Limeslice Software Foundation (LSF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.
// The LSF licenses this file to You under the MIT License (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://limeslice.org/license.txt
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';
import 'package:commons_lang/commons_lang.dart';

/// Lookup implementation that gets values from the platform environment.
/// This can be used to retrieve environment variables.
/// See <code>Platform.fromEnvironment</code>
class EnvStrLookup extends StrLookup {
  /// Lookup a variable from the platform environment.
  @override
  String? lookup(String? key) {
    if (key == null) {
      return null;
    }
    return Platform.environment[key];
  }
}
