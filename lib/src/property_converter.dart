// Licensed to the Limeslice Software Foundation (LSF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.
// The LSF licenses this file to You under the Apache License, Version 2.0
// (the "License"); you may not use this file except in compliance with
// the License.  You may obtain a copy of the License at
//
// https://limeslice.org/license.txt
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:commons_config/commons_config.dart';
import 'package:commons_lang/commons_lang.dart';

/// A utility class to convert the configuration properties into any type.
class PropertyConverter {
  /// Singleton instance
  static final PropertyConverter instance = PropertyConverter._internal();

  /// Returns the Singleton instance.
  factory PropertyConverter() {
    return instance;
  }

  /// Create a new instance.
  PropertyConverter._internal();

  /// Convert the specified object into a bool.
  /// Throws ConversionException if the value cannot be converted.
  bool toBool(Object? value) {
    if (value is bool) {
      return value;
    } else if (value is String) {
      bool? b = BoolUtils.fromString(value);
      return b;
    } else {
      throw ConversionException(
          "The value $value can't be converted to a bool");
    }
  }

  /// Convert the specified object into a DateTime.
  /// Throws ConversionException if the value cannot be converted.
  DateTime toDateTime(Object value) {
    if (value is DateTime) {
      return value;
    } else if (value is String) {
      DateTime? d = DateTime.tryParse(value);
      if (d == null) {
        throw ConversionException(
            "The value $value can't be converted to a DateTime");
      }
      return d;
    } else {
      throw ConversionException(
          "The value $value can't be converted to a DateTime");
    }
  }

  /// Convert the specified object into a int.
  /// Throws ConversionException if the value cannot be converted.
  int toInt(Object value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      int? i = int.tryParse(value);
      if (i == null) {
        throw ConversionException(
            "The value $value can't be converted to a int");
      }
      return i;
    } else {
      throw ConversionException("The value $value can't be converted to a int");
    }
  }

  /// Convert the specified object into a int.
  /// Throws ConversionException if the value cannot be converted.
  double toDouble(Object value) {
    if (value is double) {
      return value;
    } else if (value is String) {
      double? d = double.tryParse(value);
      if (d == null) {
        throw ConversionException(
            "The value $value can't be converted to a double");
      }
      return d;
    } else {
      throw ConversionException(
          "The value $value can't be converted to a double");
    }
  }

  /// Convert the specified object into a Uri.
  /// Throws ConversionException if the value cannot be converted.
  Uri toUri(Object value) {
    if (value is Uri) {
      return value;
    } else if (value is String) {
      Uri? uri = Uri.tryParse(value);
      if (uri == null) {
        throw ConversionException(
            "The value $value can't be converted to a Uri");
      }
      return uri;
    } else {
      throw ConversionException("The value $value can't be converted to a Uri");
    }
  }

  /// Returns an iterator over the simple values of a composite value.
  Iterator toIterator(Object value, String delimiter) {
    return _flatten(value, delimiter).iterator;
  }

  /// Returns a List with all values contained in the specified object.
  /// This method is used for instance by the addProperty implementation
  /// of the default configurations to gather all values of the
  /// property to add. Depending on the type of the passed in object the
  /// following things happen:
  /// 1. Strings are checked for delimiter characters and split if necessary.
  /// 2. For objects implementing the {@code Iterable} interface, the
  /// corresponding {@code Iterator} is obtained, and contained elements
  /// are added to the resulting collection.
  /// 3. All other types are directly inserted.
  List _flatten(Object value, String delimiter) {
    if (value is String) {
      String s = value;
      if (s.contains(delimiter)) {
        return s.split(delimiter);
      }
    }

    List<Object> result = [];
    if (value is Iterable) {
      _flattenIterator(result, value.iterator, delimiter);
    } else if (value is Iterator) {
      _flattenIterator(result, value, delimiter);
    } else {
      result.add(value);
    }

    return result;
  }

  /// Flattens the given iterator. For each element in the iteration
  /// _flatten will be called recursively.
  void _flattenIterator(List target, Iterator it, String delimiter) {
    while (it.moveNext()) {
      target.addAll(_flatten(it.current, delimiter));
    }
  }
}
