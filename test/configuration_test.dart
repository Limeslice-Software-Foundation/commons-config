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

const int propCount = 12;
const String keyPrefix = 'key';

void main() {
  late Configuration configuration;

  setUp(() {
    Map<String, Object?> map = {};
    configuration = MapConfiguration(map: map);
  });

  group('Test interpolation', () {
    test('Test basic interpolation functionality', () {
      configuration.setProperty("applicationRoot", "/home/applicationRoot");
      configuration.setProperty("db", "\${applicationRoot}/db/hypersonic");
      String unInterpolatedValue = "\${applicationRoot2}/db/hypersonic";
      configuration.setProperty("dbFailedInterpolate", unInterpolatedValue);
      String dbProp = "/home/applicationRoot/db/hypersonic";

      expect(configuration.getString("db"), equals(dbProp));
      expect(configuration.getString("dbFailedInterpolate"),
          equals(unInterpolatedValue));

      configuration.addProperty("path", "/temp,C:\\Temp,/usr/local/tmp");
      configuration.setProperty("path.current", "\${path}");
      expect(configuration.getString("path.current"), equals("/temp"));
    });

    test('Test multiple interpolation', () {
      configuration.setProperty("test.base-level", "/base-level");
      configuration.setProperty(
          "test.first-level", "\${test.base-level}/first-level");
      configuration.setProperty(
          "test.second-level", "\${test.first-level}/second-level");
      configuration.setProperty(
          "test.third-level", "\${test.second-level}/third-level");

      String expectedValue = "/base-level/first-level/second-level/third-level";
      expect(
          configuration.getString("test.third-level"), equals(expectedValue));
    });

    test('Test interpolation loop', () {
      configuration.setProperty("test.a", "\${test.b}");
      configuration.setProperty("test.b", "\${test.a}");
      expect(() => configuration.getBigInt("test.a"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test('Test unknown lookup', () {
      configuration.addProperty("test.interpol", "\${unknown.property}");
      expect(configuration.getString("test.interpol"),
          equals("\${unknown.property}"));
    });

    test('Test interpolation escaped', () {
      configuration.addProperty("var", "x");
      configuration.addProperty("escVar", "Use the variable \$\${\${var}}.");
      expect(
          configuration.getString("escVar"), equals("Use the variable \${x}."));
    });
  });

  group('Test MapConfiguration', () {
    test('Test throw exception on missing', () {
      expect(configuration.throwExceptionOnMissing, equals(false));
    });

    test('Test get property', () {
      expect(configuration.getProperty('foo'), equals(isNull));

      String expected = "1";
      String key = "number";
      configuration.setProperty(key, expected);
      expect(configuration.getProperty(key), equals(expected));
      expect(configuration.getString('number'), equals('1'));
    });

    test('Test get BigInt', () {
      BigInt bInt = BigInt.from(1234567890);
      BigInt bInt2 = BigInt.from(1234567899);
      configuration.setProperty("key", bInt);
      expect(configuration.getBigInt("key"), equals(bInt));
      expect(configuration.getBigInt("key", bInt2), equals(bInt));
      expect(configuration.getBigInt("noexist", bInt2), equals(bInt2));
    });
    test('Test get BigInt unknown', () {
      configuration.throwExceptionOnMissing = true;
      expect(() => configuration.getBigInt("noexist"),
          throwsA(TypeMatcher<NoSuchElementException>()));
    });
    test('Test get BigInt incompatible type', () {
      configuration.setProperty("key", 1);
      expect(() => configuration.getBigInt("key"),
          throwsA(TypeMatcher<ConversionException>()));
    });

    test('Test get bool', () {
      configuration.setProperty("key", true);
      expect(configuration.getBool("key"), equals(true));
      expect(configuration.getBool("key", false), equals(true));
      expect(configuration.getBool("noexist", false), equals(false));
    });

    test('Test get bool unknown', () {
      configuration.throwExceptionOnMissing = true;
      expect(() => configuration.getBool("noexist"),
          throwsA(TypeMatcher<NoSuchElementException>()));
    });

    test('Test get bool incompatible type', () {
      configuration.setProperty("key", 1);
      expect(() => configuration.getBool("key"),
          throwsA(TypeMatcher<ConversionException>()));
    });

    test('Test get DateTime', () {
      DateTime dateTime = DateTime.now();
      DateTime another = DateTime.parse('1969-07-20 20:18:04Z');
      configuration.setProperty("key", dateTime);
      expect(configuration.getDateTime("key"), equals(dateTime));
      expect(configuration.getDateTime("key", another), equals(dateTime));
      expect(configuration.getDateTime("noexist", another), equals(another));
    });

    test('Test get DateTime unknown', () {
      configuration.throwExceptionOnMissing = true;
      expect(() => configuration.getDateTime("noexist"),
          throwsA(TypeMatcher<NoSuchElementException>()));
    });

    test('Test get DateTime incompatible type', () {
      configuration.setProperty("key", 1);
      expect(() => configuration.getDateTime("key"),
          throwsA(TypeMatcher<ConversionException>()));
    });

    test('Test get double', () {
      double value = 12.345;
      configuration.setProperty("key", value);
      expect(configuration.getDouble("key"), equals(value));
      expect(configuration.getDouble("key", 45.67), equals(value));
      expect(configuration.getDouble("noexist", 45.67), equals(45.67));
    });

    test('Test get double unknown', () {
      configuration.throwExceptionOnMissing = true;
      expect(() => configuration.getDouble("noexist"),
          throwsA(TypeMatcher<NoSuchElementException>()));
    });

    test('Test get double incompatible type', () {
      configuration.setProperty("key", false);
      expect(() => configuration.getDouble("key"),
          throwsA(TypeMatcher<ConversionException>()));
    });

    test('Test get int', () {
      int value = 1234;
      configuration.setProperty("key", value);
      expect(configuration.getInt("key"), equals(value));
      expect(configuration.getInt("key", 4567), equals(value));
      expect(configuration.getInt("noexist", 4567), equals(4567));
    });

    test('Test get int unknown', () {
      configuration.throwExceptionOnMissing = true;
      expect(() => configuration.getInt("noexist"),
          throwsA(TypeMatcher<NoSuchElementException>()));
    });

    test('Test get int incompatible type', () {
      configuration.setProperty("key", false);
      expect(() => configuration.getInt("key"),
          throwsA(TypeMatcher<ConversionException>()));
    });

    test('Test get string', () {
      configuration.setProperty("key", "The quick brown fox");
      String string = "The quick brown fox";
      String defaultValue = "jumps over the lazy dog";
      expect(configuration.getString("key"), equals(string));
      expect(configuration.getString("key", defaultValue), equals(string));
      expect(configuration.getString("noexist", defaultValue),
          equals(defaultValue));
    });

    test('Test get Uri unknown', () {
      configuration.throwExceptionOnMissing = true;
      expect(() => configuration.getString("noexist"),
          throwsA(TypeMatcher<NoSuchElementException>()));
    });

    test('Test get Uri', () {
      Uri uri1 = Uri.parse(
          'https://api.dart.dev/stable/2.10.5/dart-core/Uri-class.html');
      Uri uri2 = Uri.parse('https://pub.dev/packages/commons_config');
      configuration.setProperty("key", uri1);
      expect(configuration.getUri("key"), equals(uri1));
      expect(configuration.getUri("key", uri2), equals(uri1));
      expect(configuration.getUri("noexist", uri2), equals(uri2));
    });

    test('Test get Uri unknown', () {
      configuration.throwExceptionOnMissing = true;
      expect(() => configuration.getUri("noexist"),
          throwsA(TypeMatcher<NoSuchElementException>()));
    });

    test('Test get Uri incompatible type', () {
      configuration.setProperty("key", false);
      expect(() => configuration.getUri("key"),
          throwsA(TypeMatcher<ConversionException>()));
    });

    test('Test get list', () {
      configuration.addProperty("number", "1");
      configuration.addProperty("number", "2");
      List<Object?> list = configuration.getList("number");
      expect(list, equals(isNotNull));
      expect(list.length, equals(2));
      expect(list.contains("1"), equals(true));
      expect(list.contains("2"), equals(true));
    });

    test('Test get string for list value', () {
      configuration.addProperty("number", "1");
      configuration.addProperty("number", "2");
      expect(configuration.getString("number"), equals("1"));
    });

    test('Test get interpolated list', () {
      configuration.addProperty("number", "1");
      configuration.addProperty("array", "\${number}");
      configuration.addProperty("array", "\${number}");

      List<Object?> list = configuration.getList("array");
      expect(list, equals(isNotNull));
      expect(list.length, equals(2));
      expect(list.contains("1"), equals(true));
    });

    test('Test get interpolation', () {
      configuration.addProperty("number", "1");
      configuration.addProperty("value", "\${number}");

      configuration.addProperty("boolean", "true");
      configuration.addProperty("booleanValue", "\${boolean}");

      expect(configuration.getBool("booleanValue"), equals(true));
      expect(configuration.getDouble("value"), equals(1.0));
      expect(configuration.getInt("value"), equals(1));
    });

    test('Test comma separated string', () {
      String prop = "hey, that's a test";
      configuration.setProperty("prop.string", prop);
      List<Object?> list = configuration.getList("prop.string");
      expect(list, equals(isNotNull));
      expect(list.length, equals(2));
      expect(list[0], equals("hey"));
    });

    test('Test comma separated string escaped', () {
      String prop2 = "hey\\, that's a test";
      configuration.setProperty("prop.string", prop2);
      expect(
          configuration.getString("prop.string"), equals("hey, that's a test"));
    });

    test('Test add property', () {
      List<Object> props = ["one", "two,three,four"];
      props.add(["5.1", "5.2", "5.3,5.4", "5.5"]);
      props.add("six");
      configuration.addProperty("complex.property", props);
      Object? val = configuration.getProperty("complex.property");
      expect(val, equals(isNotNull));
      expect(val is List, equals(true));
      if (val is List) {
        expect(val.length, equals(10));
      }
    });

    Configuration setUpSourceConfig() {
      BaseConfiguration config = BaseConfiguration();
      for (int i = 1; i < propCount; i += 2) {
        config.addProperty('$keyPrefix$i', "src$i");
      }
      config.addProperty("list1", "1,2,3");
      config.addProperty("list2", "3\\,1415,9\\,81");
      return config;
    }

    Configuration setUpDestConfig() {
      BaseConfiguration config = BaseConfiguration();
      for (int i = 0; i < propCount; i++) {
        config.addProperty('$keyPrefix$i', "value$i");
      }
      return config;
    }

    test('Test configuration copy', () {
      Configuration srcConfig = setUpSourceConfig();
      Configuration config = setUpDestConfig();
      config.copy(srcConfig);
      for (int i = 0; i < propCount; i++) {
        String key = '$keyPrefix$i';
        if (srcConfig.containsKey(key)) {
          expect(srcConfig.getProperty(key), equals(config.getProperty(key)));
        } else {
          expect(config.getString(key), equals('value$i'));
        }
      }
    });

    test('Test copy with lists', () {
      Configuration srcConfig = setUpSourceConfig();
      Configuration config = setUpDestConfig();
      config.copy(srcConfig);
      List<Object?> values = config.getList("list1");
      expect(values.length, equals(3));
      values = config.getList("list2");
      expect(values.length, equals(2));
      expect(values[0], equals('3,1415'));
    });

    test('Test interpolated configuration', () {
      configuration.setProperty("applicationRoot", "/home/applicationRoot");
      configuration.setProperty("db", "\${applicationRoot}/db/hypersonic");
      configuration.setProperty("inttest.interpol", "\${unknown.property}");
      configuration.setProperty("inttest.numvalue", "3\\,1415");
      configuration.setProperty("inttest.value", "\${inttest.numvalue}");
      configuration.setProperty("inttest.list", "\${db}");
      configuration.addProperty("inttest.list", "\${inttest.value}");

      Configuration c = configuration.interpolatedConfiguration();
      expect(
          c.getProperty("db"), equals("/home/applicationRoot/db/hypersonic"));
      expect(c.getProperty("inttest.value"), equals("3,1415"));
      List<Object?> list = c.getList('inttest.list');
      expect(list.length, equals(2));
      expect(list[0], equals("/home/applicationRoot/db/hypersonic"));
      expect(list[1], equals("3,1415"));
      expect(c.getProperty("inttest.interpol"), equals("\${unknown.property}"));
    });
  });
}
