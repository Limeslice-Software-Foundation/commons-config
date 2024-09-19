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

import 'properties_configuration.dart';
import 'properties_helper.dart';

/// This class handles writing configuration properties to a file.
/// If the properties were initially read from a file, the format and layout
/// of the file, along with any comments are NOT preserved and will be lost.
class PropertiesConfigurationWriter {
  /// The configuration to load properties for.
  final PropertiesConfiguration configuration;

  /// Create a new instance.
  PropertiesConfigurationWriter({required this.configuration});

  String _handleBackslashs(Object? value, bool inList) {
    if (value == null) {
      return '';
    }
    String doubleEsc = '${configuration.escapeChar}${configuration.escapeChar}';
    String valueStr = value.toString();
    if (inList && valueStr.contains(doubleEsc)) {
      valueStr = valueStr.replaceAll(doubleEsc, '$doubleEsc$doubleEsc');
    }
    return StringUtils.escape(valueStr);
  }

  /// Escape the given values if needed.
  String _escapeValue(Object? value, bool inList) {
    String valueStr = _handleBackslashs(value, inList);
    if (valueStr.contains(configuration.separartor)) {
      valueStr = valueStr.replaceAll(configuration.separartor,
          '${configuration.escapeChar}${configuration.separartor}');
    }
    if (valueStr.contains(configuration.listDelimiter)) {
      valueStr = valueStr.replaceAll(configuration.listDelimiter,
          '${configuration.escapeChar}${configuration.listDelimiter}');
    }
    return valueStr;
  }

  /// Escape the given key if needed.
  String _escapeKey(String key) {
    String result = key;
    if (key.contains(configuration.separartor)) {
      result = key.replaceAll(configuration.separartor,
          '${configuration.escapeChar}${configuration.separartor}');
    }
    return result;
  }

  /// Convert the list of values into a single String value using the
  /// listDelimiter from the configuration. Handles escaping if needed.
  String _makeSingleLineValue(List values) {
    if (values.isNotEmpty) {
      StringBuffer buffer = StringBuffer();
      Iterator it = values.iterator;
      bool next = it.moveNext();
      while (next) {
        String lastValue = _escapeValue(it.current, true);
        buffer.write(lastValue);
        if (lastValue.endsWith(configuration.escapeChar) &&
            (countTrailingBS(lastValue) / 2) % 2 != 0) {
          buffer.write(configuration.escapeChar);
          buffer.write(configuration.escapeChar);
        }
        next = it.moveNext();
        if (next) {
          buffer.write(configuration.listDelimiter);
        }
      }
      return buffer.toString();
    } else {
      return '';
    }
  }

  /// Write the given key and value to the given buffer.
  void _writeProperty(StringBuffer buffer, String key, Object? value,
      [bool forceSingleLine = false]) {
    String v = '';

    if (value is List) {
      if (forceSingleLine) {
        v = _makeSingleLineValue(value);
      } else {
        for (Object o in value) {
          _writeProperty(buffer, key, o);
        }
      }
    } else {
      v = _escapeValue(value, false);
    }

    buffer.write(_escapeKey(key));
    buffer.write(configuration.separartor);
    buffer.writeln(v);
  }

  /// Write the configuration to a StringBuffer.
  StringBuffer writeToString() {
    StringBuffer buffer = StringBuffer();
    Iterator<String> it = configuration.getKeys();
    while (it.moveNext()) {
      String key = it.current;
      _writeProperty(buffer, key, configuration.getProperty(key),
          !configuration.delimiterParsingDisabled);
    }
    return buffer;
  }

  /// Save the configuration to the given file asynchronously.
  Future<void> saveToFile(File file) async {
    await file.writeAsString(writeToString().toString());
  }

  /// Save the configuration to the given file synchronously.
  void saveToFileSync(File file) {
    file.writeAsStringSync(writeToString().toString());
  }
}
