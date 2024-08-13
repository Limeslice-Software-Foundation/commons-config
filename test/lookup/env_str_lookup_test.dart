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

import 'package:commons_config/commons_config.dart';
import 'package:test/test.dart';

void main() {
  test('Test read environment variable', () {
    EnvStrLookup lookup = EnvStrLookup();
    String? actual = lookup.lookup('PATH');
    expect(actual, equals(isNotNull));
  });

  test('Test null value', () {
    EnvStrLookup lookup = EnvStrLookup();
    String? actual = lookup.lookup(null);
    expect(actual, equals(isNull));
  });
}
