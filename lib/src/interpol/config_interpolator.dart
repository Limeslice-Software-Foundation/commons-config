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

import 'package:commons_config/src/lookup/env_str_lookup.dart';
import 'package:commons_lang/commons_lang.dart';

/// A class that handles interpolation (variable substitution) for
/// configuration objects.
/// Each instance of <code>Configuration</code> is associated with an
/// object of this class. All interpolation tasks are delegated to this object.
/// <code>ConfigurationInterpolator</code> works together with the
/// <code>StrSubstitutor</code> class from <a
/// href="https://pub.dev/packages/commons_lang">Commons Lang</a>. By extending
/// <code>StrLookup</code> it is able to provide values for variables that
/// appear in expressions.
/// The basic idea of this class is that it can maintain a set of primitive
/// <code>StrLookup</code> objects, each of which is identified by a special
/// prefix. The variables to be processed have the form
/// <code>${prefix:name}</code>. <code>ConfigurationInterpolator</code> will
/// extract the prefix and determine, which primitive lookup object is registered
/// for it. Then the name of the variable is passed to this object to obtain the
/// actual value. It is also possible to define a default lookup object, which
/// will be used for variables that do not have a prefix or that cannot be
/// resolved by their associated lookup object.
/// When a new instance of this class is created it is initialized with a default
/// set of primitive lookup objects. Per default it contains the
/// following standard lookup objects:
/// <code>EnvStrLookup</code> mapped to the <code>env</code> prefix.
/// <code>CfgEnvStrLookup</code> mapped to the <code>cfg</code> prefix.
/// After an instance has been created the current set of lookup objects can be
/// modified using the <code>registerLookup()</code> and
/// <code>deregisterLookup()</code> methods. The default lookup object (that is
/// invoked for variables without a prefix) can be set with the
/// <code>setDefaultLookup()</code> method. (If a
/// <code>ConfigurationInterpolator</code> instance is created by a
/// configuration object, this lookup points to the configuration itself, so that
/// variables are resolved using the configuration's properties.
class ConfigurationInterpolator extends StrLookup {
  /// Prefix of the lookup object for resolving configuration environment
  /// properties.
  static final String cfgEnvironmentPrefix = "cfg";

  /// Prefix of the lookup object for resolving environment properties.
  static final String environmentPrefix = "env";

  /// The prefix separator
  static final String prefixSeparator = ':';

  /// The default lookups
  static final Map<String, StrLookup> _globalLookups = {
    environmentPrefix: EnvStrLookup(),
    cfgEnvironmentPrefix: CfgEnvStrLookup()
  };

  /// Caller configured lookups
  Map<String, StrLookup> localLookups;

  /// Default lookup to use
  StrLookup? defaultLookup;

  /// The parent interpolator
  ConfigurationInterpolator? parentInterpolator;

  /// Create a new instance with the given default lookup.
  ConfigurationInterpolator({this.defaultLookup})
      : localLookups = Map.from(_globalLookups);

  /// Register a lookup with the given prefix
  void registerLookup(String prefix, StrLookup lookup) {
    localLookups[prefix] = lookup;
  }

  /// Remove a lookup with the given prefix
  void deregisterLookup(String prefix) {
    localLookups.remove(prefix);
  }

  /// Registers the local lookup instances for the given interpolator.
  void registerLocalLookups(ConfigurationInterpolator interpolator) {
    interpolator.localLookups.addAll(localLookups);
  }

  /// The set of prefix keys
  Iterable<String> prefixSet() {
    return localLookups.keys;
  }

  StrLookup _fetchNoPrefixLookup() {
    return defaultLookup ?? StrLookup.noneLookup;
  }

  StrLookup _fetchLookupForPrefix(String prefix) {
    StrLookup? lookup = localLookups[prefix];
    lookup ??= StrLookup.noneLookup;
    return lookup;
  }

  /// Lookup a value from the set of lookups using the given key.
  @override
  String? lookup(String? key) {
    if (key == null) {
      return null;
    }

    int prefixPos = key.indexOf(prefixSeparator);
    if (prefixPos >= 0) {
      String prefix = key.substring(0, prefixPos);
      String name = key.substring(prefixPos + 1);
      String? value = _fetchLookupForPrefix(prefix).lookup(name);
      if (value == null && parentInterpolator != null) {
        value = parentInterpolator!.lookup(name);
      }
      if (value != null) {
        return value;
      }
    }
    String? value = _fetchNoPrefixLookup().lookup(key);
    if (value == null && parentInterpolator != null) {
      value = parentInterpolator!.lookup(key);
    }
    return value;
  }
}
