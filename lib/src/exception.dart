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

/// Exception thrown when a property is incompatible with the type requested.
class ConversionException implements Exception {
  /// The cause of the exception.
  String cause;

  /// Create a new instance with the given cause.
  ConversionException(this.cause);
}

/// Exception thrown when a property is not found.
class NoSuchElementException implements Exception {
  /// The cause of the exception.
  String cause;

  /// Create a new instance with the given cause.
  NoSuchElementException(this.cause);
}

/// General configuration exception.
class ConfigurationException implements Exception {
  /// The cause of the exception.
  String cause;

  /// Create a new instance with the given cause.
  ConfigurationException(this.cause);
}
