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
import 'package:commons_lang/commons_lang.dart';

import 'exception.dart';
import 'interpol/config_interpolator.dart';
import 'property_converter.dart';

/// Abstract configuration class. Provides basic functionality but does not
/// store any data.
/// If you want to write your own Configuration class then you should
/// implement only abstract methods from this class.
/// Following is a list of features implemented here:
/// <li>Data conversion support. A concrete sub class only needs to provide a
/// generic <code>getProperty()</code> method.</li>
/// <li>Support for variable interpolation. Property values containing special
/// variable tokens (like <code>${var}</code>) will be replaced by their
/// corresponding values.</li>
/// <li>Support for string lists. The values of properties to be added to this
/// configuration are checked whether they contain a list delimiter character. If
/// this is the case and if list splitting is enabled, the string is split and
/// multiple values are added for this property. The <code>listDelimiter</code>
/// and <code>delimiterParsingDisabled</code> fields control this feature.</li>
/// <li>Allows to specify how missing properties are treated. Per default the
/// get methods returning an object will return <b>null</b> if the searched
/// property key is not found (and no default value is provided). With the
/// <code>throwExceptionOnMissing</code> field this behavior can be
/// changed to throw an exception when a requested property cannot be found.</li>
abstract class Configuration {
  /// The default value for listDelimiter.
  static final String defaultListDelimiter = ',';

  /// Delimiter used to convert single values to lists.
  String listDelimiter = defaultListDelimiter;

  /// When set to true the given configuration delimiter will not be used
  /// while parsing for this configuration.
  bool delimiterParsingDisabled = false;

  /// Whether the configuration should throw exceptions or simply
  /// return null when a property does not exist. Defaults to return null.
  bool throwExceptionOnMissing = false;

  /// Stores a reference to the object that handles variable interpolation.
  StrSubstitutor? _substitutor;

  //---------------------------------------------------------------------------
  // Abstract methods that need to be implemented by sub classes.
  //---------------------------------------------------------------------------

  /// Gets a property from the configuration. This is the most basic get
  /// method for retrieving values of properties. In a typical implementation
  /// of the {@code Configuration} interface the other get methods (that
  /// return specific data types) will internally make use of this method. On
  /// this level variable substitution is not yet performed. The returned
  /// object is an internal representation of the property value for the passed
  /// in key. It is owned by the {@code Configuration} object. So a caller
  /// should not modify this object.
  Object? getProperty(String? key);

  /// Adds a key/value pair to the Configuration. Override this method to
  /// provide write access to underlying Configuration store.
  void addPropertyDirect(String key, Object value);

  /// Removes the specified property from this configuration. This method is
  /// called by {@code clearProperty()} after it has done some
  /// preparations. It should be overridden in sub classes.
  void clearPropertyDirect(String key);

  /// Check if the configuration is empty.
  bool isEmpty();

  /// Check if the configuration contains the specified key.
  bool containsKey(String key);

  /// Get the list of the keys contained in the configuration. The returned
  /// iterator can be used to obtain all defined keys.
  Iterator<String> getKeys();

  //---------------------------------------------------------------------------

  /// Add a property to the configuration. If it already exists then the value
  // will be converted to a list containing the values.
  void addProperty(String key, Object value) {
    addPropertyValues(
        key, value, delimiterParsingDisabled ? '' : listDelimiter);
  }

  /// Adds the specified value for the given property. This method supports
  /// single values and containers (e.g. Iterable) as well. In the
  /// latter case, <code>addPropertyDirect()</code> will be called for each
  /// element.
  void addPropertyValues(String key, Object value, String delimiter) {
    Iterator it = PropertyConverter().toIterator(value, delimiter);
    while (it.moveNext()) {
      addPropertyDirect(key, it.current);
    }
  }

  /// Set a property, this will replace any previously set values.
  void setProperty(String key, Object value) {
    clearProperty(key);
    addProperty(key, value);
  }

  /// Removes the specified property from this configuration. This
  /// implementation performs some preparations and then delegates to
  /// <code>clearPropertyDirect()</code>, which will do the real work.
  void clearProperty(String key) {
    clearPropertyDirect(key);
  }

  /// Remove all properties from the configuration.
  void clear() {
    Iterator<String> it = getKeys();
    while (it.moveNext()) {
      String key = it.current;
      clearProperty(key);
    }
  }

  /// Returns the object that is responsible for variable interpolation.
  StrSubstitutor get getSubstitutor {
    _substitutor ??= StrSubstitutor.fromLookup(_createInterpolator());
    return _substitutor!;
  }

  /// Returns the interpolated value. Non String values are returned without change.
  Object? interpolate(Object? source) {
    if (source is String) {
      return getSubstitutor.replace(source);
    }
    return source;
  }

  //---------------------------------------------------------------------------
  // Data conversion methods.
  //---------------------------------------------------------------------------

  /// Get a BigInt associated with the given configuration key.
  /// If the key doesn't map to an existing object, the default value
  /// is returned.
  /// If no default value is provided and throwExceptionOnMissing is true
  /// then a <code>NoSuchElementException</code> is thrown.
  /// If throwExceptionOnMissing is false then <code>BigInt.zero</code> is
  /// returned.
  /// If the value exists then interpolation is performed before returning it.
  /// The returned BigInt is never null.
  /// Throws ConversionException if the value cannot be converted to BigInt.
  BigInt getBigInt(String key, [BigInt? defaultValue]) {
    Object? value = _resolveContainerStore(key);

    if (value == null) {
      if (defaultValue != null) {
        return defaultValue;
      } else {
        if (throwExceptionOnMissing) {
          throw NoSuchElementException(
              "$key doesn't map to an existing object");
        } else {
          return BigInt.zero;
        }
      }
    } else {
      return PropertyConverter().toBigInt(interpolate(value));
    }
  }

  /// Get a bool associated with the given configuration key.
  /// If the key doesn't map to an existing object, the default value
  /// is returned.
  /// If no default value is provided and throwExceptionOnMissing is true
  /// then a <code>NoSuchElementException</code> is thrown.
  /// If throwExceptionOnMissing is false then <code>false</code> is
  /// returned.
  /// If the value exists then interpolation is performed before returning it.
  /// The returned bool is never null.
  /// Throws ConversionException if the value cannot be converted to bool.
  bool getBool(String key, [bool? defaultValue]) {
    Object? value = _resolveContainerStore(key);

    if (value == null) {
      if (defaultValue != null) {
        return defaultValue;
      } else {
        if (throwExceptionOnMissing) {
          throw NoSuchElementException(
              "$key doesn't map to an existing object");
        } else {
          return false;
        }
      }
    } else {
      return PropertyConverter().toBool(interpolate(value));
    }
  }

  /// Get a DateTime associated with the given configuration key.
  /// If the key doesn't map to an existing object, the default value
  /// is returned.
  /// If no default value is provided and throwExceptionOnMissing is true
  /// then a <code>NoSuchElementException</code> is thrown.
  /// If throwExceptionOnMissing is false then the current DateTime
  /// <code>DateTime.now()</code> is returned.
  /// If the value exists then interpolation is performed before returning it.
  /// The returned DateTime is never null.
  /// Throws ConversionException if the value cannot be converted to DateTime.
  DateTime getDateTime(String key, [DateTime? defaultValue]) {
    Object? value = _resolveContainerStore(key);

    if (value == null) {
      if (defaultValue != null) {
        return defaultValue;
      } else {
        if (throwExceptionOnMissing) {
          throw NoSuchElementException(
              "$key doesn't map to an existing object");
        } else {
          return DateTime.now();
        }
      }
    } else {
      return PropertyConverter().toDateTime(interpolate(value));
    }
  }

  /// Get a double associated with the given configuration key.
  /// If the key doesn't map to an existing object, the default value
  /// is returned.
  /// If no default value is provided and throwExceptionOnMissing is true
  /// then a <code>NoSuchElementException</code> is thrown.
  /// If throwExceptionOnMissing is false then <code>0.0</code> is
  /// returned.
  /// If the value exists then interpolation is performed before returning it.
  /// The returned double is never null.
  /// Throws ConversionException if the value cannot be converted to double.
  double getDouble(String key, [double? defaultValue]) {
    Object? value = _resolveContainerStore(key);

    if (value == null) {
      if (defaultValue != null) {
        return defaultValue;
      } else {
        if (throwExceptionOnMissing) {
          throw NoSuchElementException(
              "$key doesn't map to an existing object");
        } else {
          return 0.0;
        }
      }
    } else {
      return PropertyConverter().toDouble(interpolate(value));
    }
  }

  /// Get a int associated with the given configuration key.
  /// If the key doesn't map to an existing object, the default value
  /// is returned.
  /// If no default value is provided and throwExceptionOnMissing is true
  /// then a <code>NoSuchElementException</code> is thrown.
  /// If throwExceptionOnMissing is false then <code>false</code> is
  /// returned.
  /// If the value exists then interpolation is performed before returning it.
  /// The returned int is never null.
  /// Throws ConversionException if the value cannot be converted to int.
  int getInt(String key, [int? defaultValue]) {
    Object? value = _resolveContainerStore(key);

    if (value == null) {
      if (defaultValue != null) {
        return defaultValue;
      } else {
        if (throwExceptionOnMissing) {
          throw NoSuchElementException(
              "$key doesn't map to an existing object");
        } else {
          return 0;
        }
      }
    } else {
      return PropertyConverter().toInt(interpolate(value));
    }
  }

  /// Get a String associated with the given configuration key.
  /// If the key doesn't map to an existing object, the default value
  /// is returned.
  /// If no default value is provided and throwExceptionOnMissing is true
  /// then a <code>NoSuchElementException</code> is thrown.
  /// If throwExceptionOnMissing is false then an empty String
  /// <code>''</code> is returned.
  /// If the value exists then interpolation is performed before returning it.
  /// The returned String is never null.
  String getString(String key, [String? defaultValue]) {
    Object? value = _resolveContainerStore(key);

    if (value == null) {
      if (defaultValue != null) {
        return defaultValue;
      } else {
        if (throwExceptionOnMissing) {
          throw NoSuchElementException(
              "$key doesn't map to an existing object");
        } else {
          return '';
        }
      }
    } else {
      Object? result = interpolate(value);
      return result == null ? '' : result.toString();
    }
  }

  /// Get a Uri associated with the given configuration key.
  /// If the key doesn't map to an existing object, the default value
  /// is returned.
  /// If no default value is provided and throwExceptionOnMissing is true
  /// then a <code>NoSuchElementException</code> is thrown.
  /// If throwExceptionOnMissing is false then an empty Uri
  /// (<code>Uri()</code>) is returned.
  /// If the value exists then interpolation is performed before returning it.
  /// The returned Uri is never null.
  /// Throws ConversionException if the value cannot be converted to Uri.
  Uri getUri(String key, [Uri? defaultValue]) {
    Object? value = _resolveContainerStore(key);

    if (value == null) {
      if (defaultValue != null) {
        return defaultValue;
      } else {
        if (throwExceptionOnMissing) {
          throw NoSuchElementException(
              "$key doesn't map to an existing object");
        } else {
          return Uri();
        }
      }
    } else {
      return PropertyConverter().toUri(value);
    }
  }

  /// Get a List of strings associated with the given configuration key.
  /// If the key doesn't map to an existing object an empty List is returned.
  List<Object?> getList(String key, [List<Object?>? defaultValue]) {
    Object? value = getProperty(key);
    List<Object?> list = [];
    if (value is String) {
      list.add(interpolate(value));
    } else if (value is List) {
      for (var item in value) {
        list.add(interpolate(item));
      }
    } else if (value is Iterator) {
      while (value.moveNext()) {
        list.add(interpolate(value.current));
      }
    } else if (value is Iterable) {
      while (value.iterator.moveNext()) {
        list.add(interpolate(value.iterator.current));
      }
    } else if (value == null) {
      // do nothing here
    } else {
      throw ArgumentError('$key doesn\'t map to a List object: $value');
    }
    return list;
  }

  //---------------------------------------------------------------------------
  // Provate methods.
  //---------------------------------------------------------------------------

  /// Creates the interpolator object that is responsible for variable
  /// interpolation. This method is invoked on first access of the
  /// interpolation features. It creates a new instance of
  /// <code>ConfigurationInterpolator</code> and sets the default lookup
  /// object to an implementation that queries this configuration.
  ConfigurationInterpolator _createInterpolator() {
    ConfigurationInterpolator interpol = ConfigurationInterpolator();
    interpol.defaultLookup = ConfigurationLookup(configuration: this);
    return interpol;
  }

  /// Returns an object from the store described by the key. If the value is a
  /// Iterable object, replace it with the first object in the Iterable.
  Object? _resolveContainerStore(String? key) {
    Object? value = getProperty(key);
    if (value != null) {
      if (value is Iterable) {
        value = value.isEmpty ? null : value.first;
      }
    }

    return value;
  }
}

/// Implements a <code>StrLookup</code> for the <code>Configuration</code>.
class ConfigurationLookup extends StrLookup {
  /// The configuration to use.
  Configuration configuration;

  /// Create a new instance using the given configuration.
  ConfigurationLookup({required this.configuration});

  /// Looks up a String key to a String value.
  @override
  String? lookup(String? key) {
    Object? prop = configuration._resolveContainerStore(key);
    return (prop != null) ? prop.toString() : null;
  }
}
