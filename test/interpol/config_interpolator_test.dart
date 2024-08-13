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

import 'package:commons_config/commons_config.dart';
import 'package:commons_lang/commons_lang.dart';
import 'package:test/test.dart';

void main() {
  final String testPrefix = 'test';
  final String testName = 'varName';
  final String testValue = 'TestVariableValue';
  late ConfigurationInterpolator interpolator;

  StrLookup setUpTestLookup() {
    Map map = {testName: testValue};
    return StrLookup.mapLookup(map);
  }

  setUp(() {
    interpolator = ConfigurationInterpolator();
  });

  test('Test create a new instance', () {
    expect(interpolator.defaultLookup, equals(isNull));
    expect(interpolator.prefixSet(), equals(isNotNull));
    expect(interpolator.prefixSet().isEmpty, equals(false));
    expect(
        interpolator
            .prefixSet()
            .contains(ConfigurationInterpolator.cfgEnvironmentPrefix),
        equals(true));
    expect(
        interpolator
            .prefixSet()
            .contains(ConfigurationInterpolator.environmentPrefix),
        equals(true));
  });

  test('Test register a lookup', () {
    interpolator.registerLookup(testPrefix, StrLookup.noneLookup);
    expect(interpolator.prefixSet().contains(testPrefix), equals(true));
    ConfigurationInterpolator int2 = ConfigurationInterpolator();
    expect(int2.prefixSet().contains(testPrefix), equals(false));
  });

  test('Test deregister lookup', () {
    interpolator.registerLookup(testPrefix, StrLookup.noneLookup);
    expect(interpolator.prefixSet().contains(testPrefix), equals(true));
    interpolator.deregisterLookup(testPrefix);
    expect(interpolator.prefixSet().contains(testPrefix), equals(false));
  });

  test('test lookup with prefix', () {
    interpolator.registerLookup(testPrefix, setUpTestLookup());
    expect(interpolator.lookup('$testPrefix:$testName'), equals(testValue));
  });

  test('Test lookup with unknown prefix', () {
    interpolator.registerLookup(testPrefix, setUpTestLookup());
    expect(interpolator.lookup('unknown:$testName'), equals(isNull));
    expect(interpolator.lookup(':$testName'), equals(isNull));
  });

  test('Test default lookup', () {
    interpolator.defaultLookup = setUpTestLookup();
    expect(interpolator.lookup(testName), equals(testValue));
  });

  test('Test lookup no default', () {
    expect(interpolator.lookup(testName), equals(isNull));
  });

  test('Test lookup empty prefix', () {
    interpolator.registerLookup('', setUpTestLookup());
    expect(interpolator.lookup(':$testName'), equals(testValue));
  });

  test('Test lookup empty var name', () {
    Map map = {'': testValue};
    interpolator.registerLookup(testPrefix, StrLookup.mapLookup(map));
    expect(interpolator.lookup('$testPrefix:'), equals(testValue));
  });

  test('Test default lookup empty var name', () {
    Map map = {'': testValue};
    interpolator.defaultLookup = StrLookup.mapLookup(map);
    expect(interpolator.lookup(''), equals(testValue));
  });

  test('Test lookup null', () {
    expect(interpolator.lookup(null), equals(isNull));
  });

  test('Test lookup environment properties', () {
    Map map = Platform.environment;
    for (String key in map.keys) {
      expect(
          interpolator
              .lookup('${ConfigurationInterpolator.environmentPrefix}:$key'),
          equals(map[key]));
    }
  });

  test('Test lookup default after prefix fails', () {
    String name = '$testPrefix:$testValue-2';
    interpolator.registerLookup(testPrefix, setUpTestLookup());

    Map map = {name: testValue};
    interpolator.defaultLookup = StrLookup.mapLookup(map);

    expect(interpolator.lookup(name), equals(testValue));
  });
}
