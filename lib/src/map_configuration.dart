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
import 'package:deepcopy/deepcopy.dart';

import 'configuration.dart';

/// Provides a <code>Configuration</code> implementation backed by a
/// <code>Map</code> object.
class MapConfiguration extends Configuration {
  /// The Map to use.
  final Map<String, Object?> map;

  /// Create a new instance using the given map.
  MapConfiguration({required this.map});

  /// Adds a key/value pair to the Configuration.
  @override
  void addPropertyDirect(String key, Object value) {
    Object? previousValue;
    if (map.containsKey(key)) {
      previousValue = map[key];
    }

    if (previousValue == null) {
      map[key] = value;
    } else if (previousValue is List) {
      previousValue.add(value);
    } else {
      List list = [previousValue, value];
      map[key] = list;
    }
  }

  /// Removes the specified property from this configuration.
  @override
  void clearPropertyDirect(String key) {
    map.remove(key);
  }

  /// Check if the configuration contains the specified key.
  @override
  bool containsKey(String key) {
    return map.containsKey(key);
  }

  /// Get the list of the keys contained in the configuration.
  @override
  Iterator<String> getKeys() {
    return map.keys.iterator;
  }

  /// Gets a property from the configuration.
  @override
  Object? getProperty(String? key) {
    return map[key];
  }

  /// Check if the configuration is empty.
  @override
  bool isEmpty() {
    return map.isEmpty;
  }

  @override
  Configuration clone() {
    Map<String, Object?> newMap = map.deepcopy().cast<String, Object?>();
    return MapConfiguration(map: newMap);
  }
}
