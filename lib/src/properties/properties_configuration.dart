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

import '../configuration.dart';
import '../file_configuration.dart';
import 'properties.dart';

class PropertiesConfiguration extends FileConfiguration {

  final Properties properties;

  factory PropertiesConfiguration() {
    return PropertiesConfiguration._internal(Properties());
  }

  PropertiesConfiguration._internal(Properties props) : properties = props;

  @override
  void addPropertyDirect(String key, Object value) {
    properties.setProperty(key, value.toString());
  }

  @override
  void clearPropertyDirect(String key) {
    properties.removeProperty(key);
  }

  @override
  Configuration clone() {
    return PropertiesConfiguration._internal(properties.clone());
  }

  @override
  bool containsKeyDirect(String key) {
    return properties.containsKey(key);
  }

  @override
  Iterator<String> getKeysDirect() {
    return properties.getKeys();
  }

  @override
  Object? getPropertyDirect(String? key) {
    if(key==null) {
      return null;
    }
    return properties.getProperty(key);
  }

  @override
  bool isEmptyDirect() {
    return properties.isEmpty();
  }

  @override
  void loadFromFileSync(File file) {
    properties.loadSync(file);
  }

  @override
  void saveToFileSync(File file) {
    properties.saveSync(file);
  }
  
  @override
  Future<void> loadFromFile(File file) async {
    await properties.load(file);
  }
  
  @override
  Future<void> saveToFile(File file) async {
    await properties.save(file);
  }

}