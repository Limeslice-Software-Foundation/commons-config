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
import 'package:deepcopy/deepcopy.dart';

/// Represents a set of key value pairs that can be saved to or read from file.
/// Each key and value is a String.
/// Supports synchronous and asynchronous file operations.
class Properties {
  static final String _delimStart = "\${";
  static final String _delimStop = '}';
  static final int _delimStartLen = 2;
  static final int _delimStopLen = 1;

  static final String defaultSeparator = '=';
  static final String commentChars = '#!';
  static final String include = 'include';

  bool includesAllowed = true;
  String separator = defaultSeparator;

  final Map<String, String> _map;

  /// Create a new empty set of properties.
  factory Properties() {
    return Properties._internal({});
  }

  Properties._internal(Map<String, String> map) : _map = map;

  String? getProperty(String key, [String? defaultValue]) {
    return _map[key] ?? defaultValue;
  }

  /// set the property identified by key to the given value. Note that
  /// subsequent calls to this method will overwrite any previous values.
  void setProperty(String key, String value) {
    _map[key] = value;
  }

  /// Remove the property identified by key.
  void removeProperty(String key) {
    _map.remove(key);
  }

  /// Removes all properties.
  void clear() {
    _map.clear();
  }

  int length() {
    return _map.length;
  }

  /// Check whether this property set is empty.
  bool isEmpty() {
    return _map.isEmpty;
  }

  bool containsKey(String key) {
    return _map.containsKey(key);
  }

  Iterator<String> getKeys() {
    return _map.keys.iterator;
  }

  /// Return a string representation of this set of properties. Each property
  /// appears on a separate line in the form key=value.
  @override
  String toString() {
    String result = '';
    _map.forEach((key, value) {
      result += '$key=$value\n';
    });
    return result;
  }

  void _loadFromLines(List<String> lines) {
    for (String l in lines) {
      String line = l.trim();
      if(line.isNotEmpty && !_isCommentLine(line)) {
        List<String> tokens = StringUtils.split(line, '=:');
        if (tokens.length == 1) {
          _map[tokens[0]] = '';
        } else if (tokens.length > 1) {
          _map[tokens[0]] = tokens[1];
        }
      }
    }
  }

  /// Load the set of properties synchronously from the file.
  void loadSync(File file) {
    List<String> lines = file.readAsLinesSync();
    _loadFromLines(lines);
  }

  /// Load the set of propertis asynchronously from the file.
  Future<void> load(File file) async {
    List<String> lines = await file.readAsLines();
    _loadFromLines(lines);
  }

  /// Save the set of properties synchronously to the file.
  void saveSync(File file) {
    file.writeAsStringSync(toString());
  }

  /// Save the set of properties asynchronously to the file.
  Future<void> save(File file) async {
    await file.writeAsString(toString());
  }

  /// Returns a subset of properties where the keys all start with the given
  /// prefix.
  Properties subset(String prefix) {
    Properties properties = Properties();
    _map.forEach((key, value) {
      if (key.startsWith(prefix)) {
        properties._map[key] = value;
      }
    });
    return properties;
  }

  /// Convenience method to return a bool value from a property.
  /// Returns true for 'true', 'True' and 'TRUE'. All other values
  /// return false.
  bool getBool(String key) {
    String? value = getProperty(key);
    if (value != null && value.isNotEmpty) {
      if (value.toLowerCase().trim() == 'true') {
        return true;
      }
    }
    return false;
  }

  /// Convenience method to return an int value from a property.
  /// Returns 0 if the property does not exist. Attempts to convert
  /// the String to an int using tryParse. Returns 0 if the string
  /// cannot be converted to an int.
  int getInt(String key) {
    String? value = getProperty(key);
    if (value != null && value.isNotEmpty) {
      int? result = int.tryParse(value);
      if (result != null) {
        return result;
      }
    }
    return 0;
  }

  /// Convenience method to return an double value from a property.
  /// Returns 0 if the property does not exist. Attempts to convert
  /// the String to an double using tryParse. Returns 0 if the string
  /// cannot be converted to an double.
  double getDouble(String key) {
    String? value = getProperty(key);
    if (value != null && value.isNotEmpty) {
      double? result = double.tryParse(value);
      if (result != null) {
        return result;
      }
    }
    return 0;
  }

  /// Find the value corresponding to key in the given properties. Then perform
  /// variable substitution on the found value.
  String findAndSubstitute(String key) {
    String? value = getProperty(key);
    if (value != null && value.isNotEmpty) {
      return substituteVars(value);
    }
    return '';
  }

  /// Perform variable substitution in string val from the values of key
  /// found in the given properties.
  ///
  /// The variable substitution delimeters are ${ and }
  ///
  /// For example, if the properties contains "key=value", then the call
  /// String s = OptionConverter.substituteVars("Value of key is ${key}.");
  /// will set the variable s to "Value of key is value."
  ///
  /// If no value could be found for the specified key, then substitution
  /// defaults to the empty string.
  String substituteVars(String val) {
    String buf = '';
    int i = 0;
    int j, k;

    while (true) {
      j = val.indexOf(_delimStart, i);
      if (j == -1) {
        // No DELIM found
        if (i == 0) {
          // this is a simple string
          return val;
        } else {
          buf += val.substring(i, val.length);
          return buf;
        }
      } else {
        // DELIM found
        buf += val.substring(i, j);
        k = val.indexOf(_delimStop, j);
        if (k == -1) {
          throw ArgumentError(
              '"$val" has no closing brace. Opening brace at position $j.');
        } else {
          j += _delimStartLen;
          String key = val.substring(j, k);
          String? replacement = getProperty(key);

          if (replacement != null) {
            // Do variable substitution on the replacement string
            // such that we can solve "Hello ${x2}" as "Hello p1"
            // the where the properties are
            // x1=p1
            // x2=${x1}
            buf += substituteVars(replacement);
          }
          i = k + _delimStopLen;
        }
      }
    }
  }

  Properties clone() {
    return Properties._internal(_map.deepcopy().cast<String, String>());
  }

  bool _isCommentLine(String line) {
    StrBuilder builder = StrBuilder(value: line);
    return builder.isEmpty || commentChars.contains(builder.charAt(0));
  }

  bool _checkCombineLines(String line) {
    return _countTrailingBS(line) % 2 != 0;
  }

  int _countTrailingBS(String line) {
    StrBuilder builder = StrBuilder(value: line);
    int bsCount = 0;
    for (int idx = builder.length() - 1;
        idx >= 0 && builder.charAt(idx) == '\\';
        idx--) {
      bsCount++;
    }

    return bsCount;
  }
}
