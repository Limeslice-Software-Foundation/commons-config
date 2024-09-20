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
import 'package:deepcopy/deepcopy.dart';

import 'package:commons_config/commons_config.dart';

import 'properties_configuration_reader.dart';
import 'properties_configuration_writer.dart';

class PropertiesConfiguration extends FileConfiguration {
  /// The fedault include keyword is 'include'
  static final String defaultInclude = 'include';

  /// The default comment characters are # and !
  static final String defaultCommentChars = '#!';

  /// The default set of separartor characters are = and :
  static final String defaultSeparatorChars = '=:';

  /// The default separator char is =.
  static final String defaultSeparator = '=';

  /// The default escape char is a backslash: \
  static final String defaultEscapeChar = '\\';

  /// Are include files allowed?
  bool includesAllowed = true;

  /// The include file keyword to use.
  String include = defaultInclude;

  /// The comment characters to use.
  String commentChars = defaultCommentChars;

  /// The set of separator characters to use.
  String separatorChars = defaultSeparatorChars;

  /// The separator character to use.
  String separartor = defaultSeparator;

  /// The escape character to use.
  String escapeChar = defaultEscapeChar;

  /// Store configuration properties in this map.
  Map<String, Object?> _map;

  /// Create a new empty configuration instance.
  PropertiesConfiguration({super.file}) : _map = {};

  @override
  void addPropertyDirect(String key, Object value) {
    Object? previousValue;
    if (_map.containsKey(key)) {
      previousValue = _map[key];
    }

    if (previousValue == null) {
      _map[key] = value;
    } else if (previousValue is List) {
      previousValue.add(value);
    } else {
      List list = [previousValue, value];
      _map[key] = list;
    }
  }

  @override
  void clearPropertyDirect(String key) {
    _map.remove(key);
  }

  @override
  Configuration clone() {
    Map<String, Object?> newMap = _map.deepcopy().cast<String, Object?>();
    PropertiesConfiguration config = PropertiesConfiguration(file: file);
    config._map = newMap;
    config.commentChars = commentChars;
    config.escapeChar = escapeChar;
    config.include = include;
    config.includesAllowed = includesAllowed;
    config.autoSave = autoSave;
    config.strategy = strategy;
    config.delimiterParsingDisabled = delimiterParsingDisabled;
    config.listDelimiter = listDelimiter;
    return config;
  }

  @override
  bool containsKeyDirect(String key) {
    return _map.containsKey(key);
  }

  @override
  Iterator<String> getKeysDirect() {
    return _map.keys.iterator;
  }

  @override
  Object? getPropertyDirect(String? key) {
    return _map[key];
  }

  @override
  bool isEmptyDirect() {
    return _map.isEmpty;
  }

  @override
  Future<void> loadFromFile(File file) async {
    bool autoSaveBak = autoSave;
    autoSave = false;
    try {
      PropertiesConfigurationReader reader =
          PropertiesConfigurationReader(configuration: this);
      await reader.loadFromFile(file);
    } finally {
      autoSave = autoSaveBak;
    }
  }

  @override
  void loadFromFileSync(File file) {
    bool autoSaveBak = autoSave;
    autoSave = false;
    try {
      PropertiesConfigurationReader reader =
          PropertiesConfigurationReader(configuration: this);
      reader.loadFromFileSync(file);
    } finally {
      autoSave = autoSaveBak;
    }
  }

  @override
  Future<void> saveToFile(File file) async {
    PropertiesConfigurationWriter writer =
        PropertiesConfigurationWriter(configuration: this);
    await writer.saveToFile(file);
  }

  @override
  void saveToFileSync(File file) {
    PropertiesConfigurationWriter writer =
        PropertiesConfigurationWriter(configuration: this);
    writer.saveToFileSync(file);
  }
}
