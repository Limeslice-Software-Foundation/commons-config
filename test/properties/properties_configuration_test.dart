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

const String testPropsFilename = 'test/data/test.properties';

void main() {
  File outFile = File('test-out.properties');

  late PropertiesConfiguration conf;

  tearDownAll(() {
    // if (outFile.existsSync()) {
    //   outFile.deleteSync();
    // }
  });

  setUp(() {
    conf = PropertiesConfiguration();
    conf.loadFromFileSync(File(testPropsFilename));
  });

  void assertEquals(Configuration expected, Configuration actual) {
    Iterator<String> it = expected.getKeys();
    while (it.moveNext()) {
      String key = it.current;
      expect(actual.containsKey(key), equals(true), reason: key);
      expect(actual.getProperty(key), equals(expected.getProperty(key)));
    }

    it = actual.getKeys();
    while (it.moveNext()) {
      String key = it.current;
      expect(expected.containsKey(key), equals(true));
    }
  }

  // test('Test load', () {
  //   bool expected = true;
  //   bool actual = conf.getBool('configuration.loaded');
  //   expect(actual, equals(expected));
  // });

  // test('Test append', () {
  //   conf.loadFromFileSync(File('test/data/threes.properties'));
  //   expect('aaa', conf.getString('test.threes.one'));
  //   expect('true', conf.getString('configuration.loaded'));
  // });

  // test('Test empty property', () {
  //   String expected = '';
  //   String actual = conf.getString('test.empty');
  //   expect(actual, equals(expected));
  // });

  // test('Test reference', () {
  //   String expected = 'baseextra';
  //   String actual = conf.getString('base.reference');
  //   expect(actual, equals(expected));
  // });

  // test('Test load included file', () {
  //   bool expected = true;
  //   bool actual = conf.getBool('include.loaded');
  //   expect(actual, equals(expected));
  // });

  // test('Test load included interpolation', () {
  //   bool expected = true;
  //   bool actual = conf.getBool('include.interpol.loaded');
  //   expect(actual, equals(expected));
  // });

  // test('Test set include keyworld', () {
  //   PropertiesConfiguration config = PropertiesConfiguration();
  //   config.include = 'import';
  //   config.loadFromFileSync(File('test/data/import.properties'));
  //   bool actual = conf.getBool('include.loaded');
  //   bool expected = true;
  //   expect(actual, equals(expected));
  //   expect(config.getList('packages').length, equals(3));
  // });

  // test('Test disable includes', () {
  //   PropertiesConfiguration config = PropertiesConfiguration();
  //   config.includesAllowed = false;
  //   config.loadFromFileSync(File(testPropsFilename));
  //   expect(true, equals(config.getBool('configuration.loaded')));
  //   expect(false, equals(config.getBool('include.loaded')));
  // });

  // test('Test List', () {
  //   List actual = conf.getList('packages');
  //   expect(actual.length, equals(3));
  // });

  // test('Test load file', () {
  //   PropertiesConfiguration config =
  //       PropertiesConfiguration(file: File(testPropsFilename));
  //   config.load();
  //   bool expected = true;
  //   bool actual = config.getBool('configuration.loaded');
  //   expect(actual, equals(expected));
  // });

  // test('Test string with escape', () {
  //   String expected =
  //       'This \\n string \\t contains \\" escaped \\ character\\u0073';
  //   String actual = conf.getString('test.unescape');
  //   expect(actual, equals(expected));
  // });

  // test('Test string with escape comma', () {
  //   String expected = 'This string contains , an escaped list separator';
  //   String actual = conf.getString('test.unescape.list-separator');
  //   expect(actual, equals(expected));
  // });

  // test('Test multi line value', () {
  //   String expected =
  //       "This is a value spread out across several adjacent natural lines by escaping the line terminator with a backslash character.";
  //   String actual = conf.getString('test.multilines');
  //   expect(actual, equals(expected));
  // });

  // test('Test list delimiter', () {
  //   expect(conf.getList('test.mixed.array').length, equals(4));

  //   PropertiesConfiguration config = PropertiesConfiguration();
  //   config.listDelimiter = '^';
  //   config.loadFromFileSync(File(testPropsFilename));
  //   expect(config.getList('test.mixed.array').length, equals(2));
  // });

  // test('Test disable list parsing', () {
  //   PropertiesConfiguration config = PropertiesConfiguration();
  //   config.delimiterParsingDisabled = true;
  //   config.loadFromFileSync(File(testPropsFilename));
  //   expect(config.getList('test.mixed.array').length, equals(2));
  // });

  // test('Test new line escaping', () {
  //   List list = conf.getList('test.path');
  //   expect(list.length, equals(3));
  //   expect(list[0], equals('C:\\path1\\'));
  //   expect(list[1], equals('C:\\path2\\'));
  //   expect(list[2], equals('C:\\path3\\complex\\test\\'));
  // });

  // test('Test comment', () {
  //   expect(conf.containsKey('#comment'), equals(false));
  //   expect(conf.containsKey('!comment'), equals(false));
  // });

  // test('Test escaped key value separator', () {
  //   expect(conf.getString('test.separator=in.key'), equals('foo'));
  //   expect(conf.getString('test.separator\\:in.key'), equals('bar'));
  //   expect(conf.getString('test.separator in.key'), equals('foo'));
  //   expect(conf.getString('test.separator in.key'), equals('foo'));
  // });

  // test('Test save to file', () {
  //   conf.addProperty("string", "value1");
  //   conf.saveToFileSync(outFile);

  //   expect(outFile.existsSync(), equals(true));

  //   PropertiesConfiguration check = PropertiesConfiguration(file: outFile);
  //   check.load();
  //   assertEquals(conf, check);
  // });

  // test('Test in memory created save', () {
  //   PropertiesConfiguration pc = PropertiesConfiguration();
  //   pc.addProperty("string", "value1");
  //   List list = [];
  //   for (int i = 1; i < 5; i++) {
  //     list.add('value$i');
  //   }

  //   pc.addProperty("array", list);
  //   pc.saveToFileSync(outFile);

  //   expect(outFile.existsSync(), equals(true));

  //   PropertiesConfiguration check = PropertiesConfiguration(file: outFile);
  //   check.load();
  //   assertEquals(pc, check);
  // });

  test('Test save to file delimiter parsing', () {
    conf.clear();
    conf.delimiterParsingDisabled = true;
    conf.addProperty("test.list", "a,b,c");
    conf.addProperty("test.dirs", "C:\\Temp\\,D:\\Data\\");
    conf.saveToFileSync(outFile);

    expect(outFile.existsSync(), equals(true));

    PropertiesConfiguration check = PropertiesConfiguration(file: outFile);
    check.delimiterParsingDisabled = true;
    check.load();
    assertEquals(conf, check);
  });

  // test('Test save to file escaped characters', () {
  //   conf.addProperty("test.dirs", "C:\\Temp\\\\,D:\\Data\\\\,E:\\Test\\");

  //   List dirs = conf.getList('test.dirs');
  //   expect(dirs.length, equals(3));

  //   conf.saveToFileSync(outFile);
  //   expect(outFile.existsSync(), equals(true));

  //   PropertiesConfiguration check = PropertiesConfiguration(file: outFile);
  //   check.load();
  //   assertEquals(conf, check);
  // });
}
