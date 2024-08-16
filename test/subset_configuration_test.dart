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
import 'package:commons_lang/commons_lang.dart';
import 'package:test/test.dart';

void main() {
  StrLookup setUpTestLookup() {
    Map map = {'testVar': 'Value of variable testVar', 'x': '(x)'};
    return StrLookup.mapLookup(map);
  }

  test('Test get property', () {
    Configuration conf = BaseConfiguration();
    conf.setProperty("test.key1", "value1");
    conf.setProperty("testing.key2", "value1");
    Configuration subset = conf.subset("test");

    expect(subset.isEmpty(), equals(false));
    expect(subset.containsKey("key1"), equals(true));
    expect(subset.containsKey("ing.key2"), equals(false));
  });

  test('Test set property', () {
    Configuration conf = BaseConfiguration();
    Configuration subset = conf.subset("test");

    subset.setProperty("key1", "value1");
    expect(subset.getProperty("key1"), equals("value1"));
    expect(conf.getProperty("test.key1"), equals("value1"));

    conf.setProperty("test.key2", "value2");
    expect(subset.getProperty("key2"), equals("value2"));
    expect(conf.getProperty("test.key2"), equals("value2"));
  });

  test('Test get parent key', () {
    Configuration conf = BaseConfiguration();
    SubsetConfiguration subset =
        SubsetConfiguration.fromConfiguration(conf, 'prefix');

    expect(subset.getParentKey("key"), equals('prefix.key'));
    expect(subset.getParentKey(""), equals('prefix'));

    subset.delimiter = '';
    expect(subset.getParentKey("key"), equals('prefixkey'));
    expect(subset.getParentKey(""), equals('prefix'));
  });

  test('Test get child key', () {
    Configuration conf = BaseConfiguration();
    SubsetConfiguration subset =
        SubsetConfiguration.fromConfiguration(conf, 'prefix');

    expect(subset.getChildKey("prefix.key"), equals('key'));
    expect(subset.getChildKey("prefix"), equals(''));

    subset.delimiter = '';
    expect(subset.getChildKey("prefixkey"), equals('key'));
    expect(subset.getChildKey("prefix"), equals(''));
  });

  test('Test get keys', () {
    Configuration conf = BaseConfiguration();
    conf.setProperty("test", "value0");
    conf.setProperty("test.key1", "value1");
    conf.setProperty("testing.key2", "value1");
    Configuration subset = conf.subset("test");

    Iterator<String> it = subset.getKeys();
    expect(it.moveNext(), equals(true));
    expect(it.current, equals(''));
    expect(it.moveNext(), equals(true));
    expect(it.current, equals('key1'));
    expect(it.moveNext(), equals(false));
  });

  test('Test get keys with prefix', () {
    Configuration conf = BaseConfiguration();
    conf.setProperty("test.abc", "value0");
    conf.setProperty("test.abc.key1", "value1");
    conf.setProperty("test.abcdef.key2", "value1");
    Configuration subset = conf.subset("test");

    Iterator<String> it = subset.getKeysPrefixed('abc');
    expect(it.moveNext(), equals(true));
    expect(it.current, equals('abc'));
    expect(it.moveNext(), equals(true));
    expect(it.current, equals('abc.key1'));
    expect(it.moveNext(), equals(false));
  });

  test('Test get list', () {
    Configuration conf = BaseConfiguration();
    conf.setProperty("test.abc", "value0,value1");
    conf.addProperty("test.abc", "value3");
    Configuration subset = conf.subset("test");
    List list = subset.getList('abc', []);
    expect(list.isEmpty, equals(false));
    expect(list.length, equals(3));
    expect(list.contains('value0'), equals(true));
    expect(list.contains('value1'), equals(true));
    expect(list.contains('value2'), equals(false));
    expect(list.contains('value3'), equals(true));
  });

  test('Test get parent', () {
    Configuration conf = BaseConfiguration();
    SubsetConfiguration subset =
        SubsetConfiguration.fromConfiguration(conf, '');
    expect(subset.parent, equals(conf));
  });

  test('Test clear', () {
    Configuration conf = BaseConfiguration();
    conf.setProperty("test.key1", "value1");
    conf.setProperty("testing.key2", "value1");
    Configuration subset = conf.subset("test");
    subset.clear();
    expect(subset.isEmpty(), equals(true));
    expect(conf.isEmpty(), equals(false));
  });

  test('Test list delimiter', () {
    Configuration conf = BaseConfiguration();
    Configuration subset = conf.subset("prefix");
    conf.listDelimiter = '/';

    subset.addProperty("list", "a/b/c");
    expect(conf.getList('prefix.list').length, equals(3));

    subset.listDelimiter = ';';
    subset.addProperty("list2", "a;b;c");
    expect(conf.getList('prefix.list').length, equals(3));
  });

  test('Test delimiter parsing', () {
    Configuration conf = BaseConfiguration();
    Configuration subset = conf.subset("prefix");

    conf.delimiterParsingDisabled = true;
    subset.addProperty("list", "a,b,c");
    expect(conf.getString('prefix.list'), equals("a,b,c"));

    subset.delimiterParsingDisabled = false;
    subset.addProperty("list2", "a,b,c");
    expect(conf.getList('prefix.list2').length, equals(3));
  });

  test('Test delimiter parsing disabled', () {
    BaseConfiguration config = BaseConfiguration();
    SubsetConfiguration subset =
        SubsetConfiguration.fromConfiguration(config, 'prefix');
    config.delimiterParsingDisabled = true;
    expect(subset.delimiterParsingDisabled, equals(true));
    subset.delimiterParsingDisabled = false;
    expect(config.delimiterParsingDisabled, equals(false));
  });

  test('Test get interpolator', () {
    BaseConfiguration config = BaseConfiguration();
    SubsetConfiguration subset =
        SubsetConfiguration.fromConfiguration(config, 'prefix');
    subset.addProperty('var', "\${echo:testVar}");
    ConfigurationInterpolator interpol = subset.getInterpolator;
    interpol.registerLookup('echo', setUpTestLookup());
    expect(subset.getString('var'), equals('Value of variable testVar'));
  });

  test('Test local lookups in Interpolator are inherited', () {
    BaseConfiguration config = BaseConfiguration();
    ConfigurationInterpolator interpolator = config.getInterpolator;
    interpolator.registerLookup('brackets', setUpTestLookup());
    config.setProperty("prefix.var", "\${brackets:x}");
    SubsetConfiguration subset =
        SubsetConfiguration.fromConfiguration(config, 'prefix');
    expect(subset.getString('var'), equals('(x)'));
  });

  test('Test interpolation for keys of the parent', () {
    BaseConfiguration config = BaseConfiguration();
    config.setProperty("test", "unit");
    config.setProperty("prefix.key", "\${test}");
    SubsetConfiguration subset =
        SubsetConfiguration.fromConfiguration(config, 'prefix');
    expect(subset.getString("key", ""), equals('unit'));
  });
}
