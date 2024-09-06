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
import 'package:test/test.dart';

void main() {
  final File file = File('test.props');
  late Properties properties;

  setUp(() {
    properties = Properties();
    properties.setProperty('key1', 'value1');
    properties.setProperty('key2', 'value2');
  });

  tearDownAll(() {
    if (file.existsSync()) {
      try {
        file.deleteSync();
      } catch (ex) {
        print('Failed to delete test file: $file - $ex');
      }
    }
  });

  test('Convert properties to a String', () {
    String actual = properties.toString();
    String expected = 'key1=value1\nkey2=value2\n';
    expect(actual, equals(expected));
  });

  test('Length returns number of elements', () {
    expect(properties.length(), equals(2));
    properties.setProperty('new', 'value');
    expect(properties.length(), equals(3));
    properties.clear();
    expect(properties.length(), equals(0));
  });

  test('Create a subset of properties', () {
    properties.setProperty('set1.key1', 'set1_value1');
    properties.setProperty('set1.key2', 'set1_value2');
    properties.setProperty('set2.key1', 'set2_value1');
    properties.setProperty('set2.key2', 'set2_value2');

    Properties set1 = properties.subset('set1');
    expect(set1.getProperty('set1.key1'), equals('set1_value1'));
    expect(set1.getProperty('set1.key2'), equals('set1_value2'));

    Properties set2 = properties.subset('set2');
    expect(set2.getProperty('set2.key1'), equals('set2_value1'));
    expect(set2.getProperty('set2.key2'), equals('set2_value2'));
  });

  group('Test adding and removing properties', () {
    test('Add a property.', () {
      String key = 'key';
      String expected = 'value';

      // add new property
      properties.setProperty(key, expected);
      // overwrite existing property
      properties.setProperty('key2', expected);
      expect(properties.getProperty(key), equals(expected));
      expect(properties.getProperty('key2'), equals(expected));
      expect(properties.getProperty('key1'), isNot(equals(expected)));
      expect(properties.getProperty('key1'), equals('value1'));
    });

    test('Remove a property.', () {
      properties.removeProperty('key1');
      expect(properties.getProperty('key1'), isNull);
      expect(properties.getProperty('key2'), isNotNull);
      expect(properties.getProperty('key2'), equals('value2'));
      expect(properties.isEmpty(), equals(false));
    });

    test('Clear removes all properties.', () {
      properties.clear();
      expect(properties.getProperty('key1'), isNull);
      expect(properties.getProperty('key2'), isNull);
      expect(properties.isEmpty(), equals(true));
    });
  });

  group('Test convenience methods', () {
    test('Test getInt.', () {
      properties.setProperty('key1', '3');
      expect(properties.getInt('key1'), equals(3));
      expect(properties.getInt('key2'), equals(0));
      expect(properties.getInt('noexists'), equals(0));
    });
    test('Test getBool.', () {});
    test('Test getDouble.', () {
      properties.setProperty('key1', '3.21');
      expect(properties.getDouble('key1'), equals(3.21));
      expect(properties.getDouble('key2'), equals(0.0));
      expect(properties.getDouble('noexists'), equals(0.0));
    });
  });

  group('Test load and save properties', () {
    test('Load properties from file.', () {
      properties.clear();
      properties.loadSync(File('test/data/test.properties'));

      expect(properties.getProperty('packages'),equals('packageb, packagec'));
      expect(properties.getBool('configuration.loaded'), equals(true));
    });

    test('Append properties loaded from second file.', () {
      properties.clear();
      properties.loadSync(File('test/data/test.properties'));
      properties.loadSync(File('test/data/threes.properties'));

      expect(properties.getBool('configuration.loaded'), equals(true));
      expect(properties.getProperty('test.threes.two'), equals('aaa, bbb, ccc'));
    });

    test('Save properties to file.', () {
      properties.save(file);
    });
  });

  group('Test variable substitution', () {
    test('Test findAndSubst on a non existing key', () {
      String expected = '';
      String actual = properties.findAndSubstitute('noexist');
      expect(actual, equals(expected));
    });

    test('Test findAndSubst on a value with no variables', () {
      String expected = 'value1';
      String actual = properties.findAndSubstitute('key1');
      expect(actual, equals(expected));
    });

    test('Test findAndSubst on a value with one variables', () {
      properties.setProperty('key1', 'the value is \${key2}');
      String expected = 'the value is value2';
      String actual = properties.findAndSubstitute('key1');
      expect(actual, equals(expected));
    });

    test('Test findAndSubst on a value with two variables', () {
      properties.setProperty('key3', 'value3');
      properties.setProperty('key1', 'the value is \${key2} and \${key3}');
      String expected = 'the value is value2 and value3';
      String actual = properties.findAndSubstitute('key1');
      expect(actual, equals(expected));
    });

    test('Test findAndSubst on a value with two variables, one does not exist',
        () {
      properties.setProperty('key1', 'the value is \${key2} and \${noexist}');
      String expected = 'the value is value2 and ';
      String actual = properties.findAndSubstitute('key1');
      expect(actual, equals(expected));
    });
  });

  test('Test empty', () {
    properties.clear();
      properties.loadSync(File('test/data/test.properties'));

      String? value = properties.getProperty('test.empty');
      expect(value,isNotNull);
      expect(value,equals(''));
  });

  test('Test reference', () {
    properties.clear();
      properties.loadSync(File('test/data/test.properties'));

      String? value = properties.findAndSubstitute('base.reference');
      expect(value,equals('baseextra'));
  });
}
