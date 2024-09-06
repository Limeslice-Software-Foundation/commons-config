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

import 'package:commons_config/src/exception.dart';

import 'configuration.dart';
import 'reloading/reloading_strategy.dart';

/// A persistent configuration loaded and saved to a file.
abstract class FileConfiguration extends Configuration {
  /// The underlying File to use.
  File? file;

  /// The auto save flag.
  /// Default is false.
  bool autoSave = false;

  /// Holds a reference to the reloading strategy.
  /// Default is <code>InavriantReloadingStrategy</code>.
  ReloadingStrategy strategy = ReloadingStrategy.inavriantReloadingStrategy();

  /// Create a new instance with the given File.
  FileConfiguration({this.file});

  //---------------------------------------------------------------------------
  // Abstract methods that need to be implemented by sub classes.
  //---------------------------------------------------------------------------

  /// Gets a property from the configuration. This is the most basic get
  /// method for retrieving values of properties. In a typical implementation
  /// of the <code>FileConfiguration</code> interface the other get methods
  /// (that return specific data types) will internally make use of this method.
  /// On this level variable substitution is not yet performed. The returned
  /// object is an internal representation of the property value for the passed
  /// in key. It is owned by the <code>FileConfiguration</code> object. So a
  /// caller should not modify this object.
  Object? getPropertyDirect(String? key);

  /// Check if the configuration is empty.
  bool isEmptyDirect();

  /// Check if the configuration contains the specified key.
  bool containsKeyDirect(String key);

  /// Get the list of the keys contained in the configuration. The returned
  /// iterator can be used to obtain all defined keys.
  Iterator<String> getKeysDirect();

  /// Load the configuration from the specified file. Implementers should throw
  /// <code>ConfigurationException</code> if an error occurs during the load
  /// operation.
  void loadFromFileSync(File file);

  /// Load the configuration from the specified file. Implementers should throw
  /// <code>ConfigurationException</code> if an error occurs during the load
  /// operation.
  Future<void> loadFromFile(File file);

  /// Save the configuration to the specified file. Implementers should throw
  /// <code>ConfigurationException</code> if an error occurs during the save
  /// operation.
  void saveToFileSync(File file);

  /// Save the configuration to the specified file. Implementers should throw
  /// <code>ConfigurationException</code> if an error occurs during the save
  /// operation.
  Future<void> saveToFile(File file);

  //---------------------------------------------------------------------------

  /// Load the configuration from the underlying File. Throws
  /// <code>ConfigurationException</code> if an error occurs during the load
  /// operation.
  void load() {
    if (file == null) {
      throw ConfigurationException('File has not been set.');
    }
    try {
      loadFromFile(file!);
    } catch (exception) {
      throw ConfigurationException('Failed to load file: $exception');
    }
  }

  /// Save the configuration to the underlying File. Throws
  /// <code>ConfigurationException</code> if an error occurs during the save
  /// operation.
  void save() {
    if (file == null) {
      throw ConfigurationException('File has not been set.');
    }
    try {
      saveToFile(file!);
    } catch (exception) {
      throw ConfigurationException('Failed to save file: $exception');
    }
  }

  /// Performs a reload operation if necessary. This method is called on each
  /// access of this configuration. It asks the associated reloading strategy
  /// whether a reload should be performed. If this is the case, the
  /// configuration is cleared and loaded again from its source.
  void reload() {
    if (strategy.reloadingRequired()) {
      refresh();
    }
  }

  /// Save the configuration if the automatic persistence is enabled.
  void possiblySave() {
    if (autoSave && file != null) {
      save();
    }
  }

  /// Add a property to the configuration. If it already exists then the value
  // will be converted to a list containing the values.
  @override
  void addProperty(String key, Object value) {
    super.addProperty(key, value);
    possiblySave();
  }

  /// Set a property, this will replace any previously set values.
  @override
  void setProperty(String key, Object value) {
    super.setProperty(key, value);
    possiblySave();
  }

  /// Removes the specified property from this configuration.
  @override
  void clearProperty(String key) {
    super.clearProperty(key);
    possiblySave();
  }

  /// Reloads the associated configuration file. This method first clears the
  /// content of this configuration, then the associated configuration file is
  /// loaded again. Updates on this configuration which have not yet been saved
  /// are lost. Calling this method would be like invoking
  /// <code>reload()</code> without checking the reloading strategy.
  void refresh() {
    bool autoSaveBackup = autoSave;
    autoSave = false;
    try {
      clear();
      load();
    } finally {
      autoSave = autoSaveBackup;
    }
  }

  /// Gets a property from the configuration.
  @override
  Object? getProperty(String? key) {
    reload();
    return getPropertyDirect(key);
  }

  /// Check if the configuration is empty.
  @override
  bool isEmpty() {
    reload();
    return isEmptyDirect();
  }

  /// Check if the configuration contains the specified key.
  @override
  bool containsKey(String key) {
    reload();
    return containsKeyDirect(key);
  }

  /// Get the list of the keys contained in the configuration.
  /// Returns an <code>Iterator</code> with the keys contained in this
  /// configuration. This implementation performs a reload if necessary before
  /// obtaining the keys. The iterator returned by this method
  /// points to a snapshot taken when this method was called. Later changes at
  /// the set of keys (including those caused by a reload) won't be visible.
  /// This is because a reload can happen at any time during iteration, and it
  /// is impossible to determine how this reload affects the current iteration.
  /// When using the iterator a client has to be aware that changes of the
  /// configuration are possible at any time. For instance, if after a reload
  /// operation some keys are no longer present, the iterator will still return
  /// those keys because they were found when it was created.
  @override
  Iterator<String> getKeys() {
    reload();
    return getKeysDirect();
  }
}
