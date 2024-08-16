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

import 'configuration.dart';
import 'interpol/config_interpolator.dart';

/// A subset of another configuration. The new Configuration object contains
/// every key from the parent Configuration that starts with prefix. The prefix
/// is removed from the keys in the subset.
class SubsetConfiguration extends Configuration {
  static final String defaultDelimiter = '.';

  /// The parent configuration.
  Configuration parent;

  /// The prefix used to select the properties.
  String prefix;

  /// The prefix delimiter.
  String delimiter;

  /// Internal constructor.
  SubsetConfiguration._internal({required this.parent, required this.prefix})
      : delimiter = defaultDelimiter;

  /// Create a SubsetConfiguration using the given config as parent and the given prefix.
  factory SubsetConfiguration.fromConfiguration(
      Configuration config, String aprefix,
      [String? delimiter]) {
    SubsetConfiguration subsetConf =
        SubsetConfiguration._internal(parent: config, prefix: aprefix);
    subsetConf.delimiterParsingDisabled = config.delimiterParsingDisabled;
    subsetConf.throwExceptionOnMissing = config.throwExceptionOnMissing;
    subsetConf.listDelimiter = config.listDelimiter;
    if (delimiter != null) {
      subsetConf.delimiter = delimiter;
    }
    return subsetConf;
  }

  /// Clone this configuration as appropriate.
  @override
  Configuration clone() {
    return SubsetConfiguration.fromConfiguration(
        parent.clone(), prefix, delimiter);
  }

  /// Return the key in the parent configuration associated to the specified
  /// key in this subset.
  String getParentKey(String? key) {
    if (key == null || key.isEmpty) {
      return prefix;
    } else {
      return '$prefix$delimiter$key';
    }
  }

  /// Return the key in the subset configuration associated to the specified
  /// key in the parent configuration.
  String getChildKey(String key) {
    if (!key.startsWith(prefix)) {
      throw ArgumentError("The parent key '$key' is not in the subset.");
    } else {
      String modifiedKey;
      if (key.length == prefix.length) {
        modifiedKey = "";
      } else {
        int i = prefix.length + delimiter.length;
        modifiedKey = key.substring(i);
      }

      return modifiedKey;
    }
  }

  @override
  void addPropertyDirect(String key, Object value) {
    parent.addProperty(getParentKey(key), value);
  }

  @override
  void clearPropertyDirect(String key) {
    parent.clearProperty(getParentKey(key));
  }

  @override
  bool containsKey(String key) {
    return parent.containsKey(getParentKey(key));
  }

  @override
  Iterator<String> getKeys() {
    return SubsetIterator(
        parentIterator: parent.getKeysPrefixed(prefix),
        subsetConfiguration: this);
  }

  /// This implementation returns keys that either match the
  /// prefix or start with the prefix followed by a dot ('.').
  @override
  Iterator<String> getKeysPrefixed(String pfix) {
    return SubsetIterator(
        parentIterator: parent.getKeysPrefixed(getParentKey(pfix)),
        subsetConfiguration: this);
  }

  @override
  Object? getProperty(String? key) {
    return parent.getProperty(getParentKey(key));
  }

  @override
  bool isEmpty() {
    return !getKeys().moveNext();
  }

  /// Returns the interpolated value. Non String values are returned without change.
  @override
  Object? interpolate(Object? source) {
    if (delimiter.isEmpty && prefix.isEmpty) {
      return super.interpolate(source);
    } else {
      SubsetConfiguration config =
          SubsetConfiguration.fromConfiguration(parent, '', '');
      ConfigurationInterpolator interpolator = config.getInterpolator;
      getInterpolator.registerLocalLookups(interpolator);
      interpolator.parentInterpolator = parent.getInterpolator;
      return config.interpolate(source);
    }
  }

  //---------------------------------------------------------------------------
  // Getters and setters
  //---------------------------------------------------------------------------
  // These are defined as getters and setters so that the functionality may be
  // overridden in subclasses that may want to change the default behaviour.

  /// Returns the delimiter used to convert single values to lists.
  @override
  String get listDelimiter {
    return parent.listDelimiter;
  }

  /// Returns true if the given configuration delimiter will not be used
  /// while parsing for this configuration, false otherwise.
  @override
  bool get delimiterParsingDisabled {
    return parent.delimiterParsingDisabled;
  }

  /// Returns true if the configuration should throw exceptions or simply
  /// return null when a property does not exist.
  @override
  bool get throwExceptionOnMissing {
    return parent.throwExceptionOnMissing;
  }

  /// Set the delimiter used to convert single values to lists.
  @override
  set listDelimiter(String listDelimiter) {
    parent.listDelimiter = listDelimiter;
  }

  /// Set whether the configuration delimiter will be used while parsing.
  @override
  set delimiterParsingDisabled(bool delimiterParsingDisabled) {
    parent.delimiterParsingDisabled = delimiterParsingDisabled;
  }

  /// Set whether the configuration should throw exceptions when a property
  /// does no exist.
  @override
  set throwExceptionOnMissing(bool throwExceptionOnMissing) {
    parent.throwExceptionOnMissing = throwExceptionOnMissing;
  }

  //---------------------------------------------------------------------------
}

/// A specialized iterator to be returned by the <code>getKeys()</code>
/// methods. This implementation wraps an iterator from the parent
/// configuration. The keys returned by this iterator are correspondingly
/// transformed.
class SubsetIterator implements Iterator<String> {
  /// Stores the wrapped iterator.
  Iterator<String> parentIterator;

  SubsetConfiguration subsetConfiguration;

  /// Create a new instance with the given parent iterator.
  SubsetIterator(
      {required this.parentIterator, required this.subsetConfiguration});

  /// Returns the current element in the iteration.
  @override
  String get current => subsetConfiguration.getChildKey(parentIterator.current);

  /// Move the iterator to the next element.
  @override
  bool moveNext() {
    return parentIterator.moveNext();
  }
}
