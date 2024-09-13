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

import 'properties_configuration.dart';

class PropertiesConfigurationWriter {
  
  /// The configuration to load properties for.
  final PropertiesConfiguration configuration;

  PropertiesConfigurationWriter({required this.configuration});

  String _escapeValue(Object? value, bool inList) {
    if(value == null) {
      return '';
    }
    String valueStr = value.toString();
    if(valueStr.contains(configuration.separartor)) {
      valueStr = valueStr.replaceAll(configuration.separartor, '${configuration.escapeChar}${configuration.separartor}');
    }
    return valueStr;
  }

  String _escapeKey(String key) {
    String result = key;
    if (key.contains(configuration.separartor)) {
      result = key.replaceAll(
          configuration.separartor, '${configuration.escapeChar}$key');
    }
    return result;
  }

  String _makeSingleLineValue(List values) {
    if (values.isNotEmpty) {
      StringBuffer buffer = StringBuffer();
      Iterator it = values.iterator;
      while (it.moveNext()) {
        String lastValue = _escapeValue(it.current, true);
      }
      return buffer.toString();
    } else {
      return '';
    }
  }

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
    buffer.write(v);
  }

  StringBuffer writeToString() {
    StringBuffer buffer = StringBuffer();
    Iterator<String> it = configuration.getKeys();
    while (it.moveNext()) {
      String key = it.current;
      _writeProperty(buffer, key, configuration.getProperty(key), !configuration.delimiterParsingDisabled);
    }
    return buffer;
  }

  Future<void> saveToFile(File file) async {
    await file.writeAsString(writeToString().toString());
  }

  void saveToFileSync(File file) {
    file.writeAsStringSync(writeToString().toString());
  }
}
