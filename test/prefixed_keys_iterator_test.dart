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
  late PrefixedKeysIterator iterator;

  test('Test empty iterator', () {
    List<String> list = [];
    iterator = PrefixedKeysIterator(iterator: list.iterator, prefix: 'test');

    expect(iterator.moveNext(), equals(false));
    expect(() => iterator.current,
          throwsA(TypeMatcher<NoSuchElementException>()));
  });

  test('Test all prefix', () {
    List<String> list = ['test.1','test.2'];
    iterator = PrefixedKeysIterator(iterator: list.iterator, prefix: 'test');

    expect(iterator.moveNext(), equals(true));
    expect(iterator.current, equals(list[0]));
    expect(iterator.moveNext(), equals(true));
    expect(iterator.current, equals(list[1]));
    expect(iterator.moveNext(), equals(false));
  });

  test('Test some prefix', () {
    List<String> list = ['test.1','abc.2','test.3'];
    iterator = PrefixedKeysIterator(iterator: list.iterator, prefix: 'test');

    expect(iterator.moveNext(), equals(true));
    expect(iterator.current, equals(list[0]));
    expect(iterator.moveNext(), equals(true));
    expect(iterator.current, equals(list[2]));
    expect(iterator.moveNext(), equals(false));
  });

}