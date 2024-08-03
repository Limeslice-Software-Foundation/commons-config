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
import 'package:test/test.dart';

void main() {
  group('Test toBool', () {
    test('toBool from bool', () {
      bool expected = true;
      bool actual = PropertyConverter().toBool(expected);
      expect(actual, equals(expected));

      expected = false;
      actual = PropertyConverter().toBool(expected);
      expect(actual, equals(expected));
    });

    test('toBool from bool String', () {
      bool expected = true;
      expect(PropertyConverter().toBool('true'), equals(expected));
      expect(PropertyConverter().toBool('True'), equals(expected));
      expect(PropertyConverter().toBool('TRUE'), equals(expected));

      expected = false;
      expect(PropertyConverter().toBool('false'), equals(expected));
      expect(PropertyConverter().toBool('False'), equals(expected));
      expect(PropertyConverter().toBool('FALSE'), equals(expected));
    });

    test('toBool from non bool String', () {
      expect(() => PropertyConverter().toBool('this is not a bool'),
          throwsA(TypeMatcher<ConversionException>()));
    });

    test('toBool from List throws exception', () {
      List list = [1, 2, 3];
      expect(() => PropertyConverter().toBool(list),
          throwsA(TypeMatcher<ConversionException>()));
    });
  });

  group('Test toDateTime', () {
    test('toDateTime from DateTime', () {
      DateTime expected = DateTime.now();
      DateTime actual = PropertyConverter().toDateTime(expected);
      expect(actual, equals(expected));
    });

    test('toDateTime from DateTime String', () {
      DateTime expected = DateTime.now();
      String input = expected.toString();
      DateTime actual = PropertyConverter().toDateTime(input);
      expect(actual, equals(expected));
    });

    test('toDateTime from non DateTime String', () {
      expect(() => PropertyConverter().toDateTime('this is not a DateTime'),
          throwsA(TypeMatcher<ConversionException>()));
    });

    test('toDateTime from List throws exception', () {
      List list = [1, 2, 3];
      expect(() => PropertyConverter().toDateTime(list),
          throwsA(TypeMatcher<ConversionException>()));
    });
  });

  group('Test toInt', () {
    test('toInt from int', () {
      int expected = 23;
      int actual = PropertyConverter().toInt(expected);
      expect(actual, equals(expected));
    });

    test('toInt from int String', () {
      int expected = 23;
      String input = expected.toString();
      int actual = PropertyConverter().toInt(input);
      expect(actual, equals(expected));
    });

    test('toInt from non int String', () {
      expect(() => PropertyConverter().toInt('this is not a int'),
          throwsA(TypeMatcher<ConversionException>()));
    });

    test('toInt from List throws exception', () {
      List list = [1, 2, 3];
      expect(() => PropertyConverter().toInt(list),
          throwsA(TypeMatcher<ConversionException>()));
    });
  });

  group('Test toDouble', () {
    test('toDouble from double', () {
      double expected = 23.4567;
      double actual = PropertyConverter().toDouble(expected);
      expect(actual, equals(expected));
    });

    test('toDouble from double String', () {
      double expected = 23.4567;
      String input = expected.toString();
      double actual = PropertyConverter().toDouble(input);
      expect(actual, equals(expected));
    });

    test('toDouble from non double String', () {
      expect(() => PropertyConverter().toDouble('this is not a double'),
          throwsA(TypeMatcher<ConversionException>()));
    });

    test('toDouble from List throws exception', () {
      List list = [1, 2, 3];
      expect(() => PropertyConverter().toDouble(list),
          throwsA(TypeMatcher<ConversionException>()));
    });
  });

  group('Test toUri', () {
    test('toUri from Uri', () {
      Uri expected = Uri(
          scheme: 'https',
          host: 'dart.dev',
          path: '/guides/libraries/library-tour',
          fragment: 'numbers');
      Uri actual = PropertyConverter().toUri(expected);
      expect(actual, equals(expected));
    });

    test('toUri from Uri String', () {
      Uri expected = Uri(
          scheme: 'https',
          host: 'example.com',
          path: '/page/',
          queryParameters: {'search': 'blue', 'limit': '10'});
      String input = expected.toString();
      Uri actual = PropertyConverter().toUri(input);
      expect(actual, equals(expected));
    });

    test('toUri from non Uri String', () {
      expect(() => PropertyConverter().toDouble('this is not a Uri'),
          throwsA(TypeMatcher<ConversionException>()));
    });

    test('toUri from List throws exception', () {
      List list = [1, 2, 3];
      expect(() => PropertyConverter().toUri(list),
          throwsA(TypeMatcher<ConversionException>()));
    });
  });

  group('Test toIterator', () {
    test('toIterator from delimited String', () {
      String input = 'hello,world';
      String delimiter = ',';
      Iterator actual = PropertyConverter().toIterator(input, delimiter);
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('hello'));
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('world'));
      expect(actual.moveNext(), equals(false));
    });

    test('toIterator from non delimited String', () {
      String input = 'hello world';
      String delimiter = ',';
      Iterator actual = PropertyConverter().toIterator(input, delimiter);
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('hello world'));
      expect(actual.moveNext(), equals(false));
    });

    test('toIterator from Iterable', () {
      List<String> input = ['Hello,world', 'from,Dart', '!'];
      String delimiter = ',';
      Iterator actual = PropertyConverter().toIterator(input, delimiter);
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('Hello'));
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('world'));
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('from'));
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('Dart'));
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('!'));
      expect(actual.moveNext(), equals(false));
    });

    test('toIterator from Iterator', () {
      List<String> input = ['Hello,world', 'from,Dart', '!'];
      String delimiter = ',';
      Iterator actual =
          PropertyConverter().toIterator(input.iterator, delimiter);
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('Hello'));
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('world'));
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('from'));
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('Dart'));
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals('!'));
      expect(actual.moveNext(), equals(false));
    });

    test('toIterator from other Object', () {
      int input = 23;
      String delimiter = '';
      Iterator actual = PropertyConverter().toIterator(input, delimiter);
      expect(actual.moveNext(), equals(true));
      expect(actual.current, equals(input));
      expect(actual.moveNext(), equals(false));
    });
  });
}
