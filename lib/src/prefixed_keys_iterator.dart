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
import 'exception.dart';

/// A specialized iterator implementation used by
/// <code>AbstractConfiguration</code> to return an iteration over all keys
/// starting with a specified prefix.
class PrefixedKeysIterator implements Iterator {
  /// Stores the wrapped iterator.
  final Iterator<String> iterator;

  /// Stores the prefix.
  final String prefix;

  /// If the current element has a value.
  bool _elementSet = false;

  /// Stores the current element in the iteration.
  late String? _currentElement;

  /// Creates a new instance of and sets the wrapped iterator and the prefix
  /// for the accepted keys.
  PrefixedKeysIterator({required this.iterator, required this.prefix});

  /// Returns the current element in the iteration.
  @override
  String? get current {
    if (!_elementSet) {
      throw NoSuchElementException('Element not found in iterator');
    }
    return _currentElement;
  }

  /// Advances the iterator to the next element of the iteration.
  @override
  bool moveNext() {
    while (iterator.moveNext()) {
      String key = iterator.current;
      if (key.startsWith('$prefix.') || key == prefix) {
        _currentElement = key;
        _elementSet = true;
        return true;
      }
    }
    return false;
  }
}
