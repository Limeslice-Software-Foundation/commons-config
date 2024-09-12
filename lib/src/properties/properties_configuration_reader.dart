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

import 'package:commons_lang/commons_lang.dart';

import 'properties_configuration.dart';

/// This class handles reading configuration properties from a file.
/// Typically this class handles multiline values and escaping them,
/// comment lines and multi value (list) properties and their escaping.
class PropertiesConfigurationReader {

  /// A regex to find back slashes
  final RegExp exp = RegExp(r'^\\+');

  /// The configuration to load properties for.
  final PropertiesConfiguration configuration;

  /// The current file being loaded.
  late File currentFile;

  /// Create a new instance for the given configuration.
  PropertiesConfigurationReader({required this.configuration});

  /// Reverse the given string and count how many back slashes appear at the front.
  int _checkLineEscape(String line) {
    String reversed = String.fromCharCodes(line.codeUnits.reversed);
    RegExpMatch? match = exp.firstMatch(reversed);
    return match == null ? 0 : match.end;
  }

  /// Trim and remove any trailing back slashes
  String _cleanLine(String line) {
    String tmp = line.trim();
    int x = _checkLineEscape(tmp);
    if (x % 2 != 0) {
      tmp = tmp.substring(0, tmp.length - 1);
    }
    return tmp;
  }

  /// Check if the given file exists and load it.
  void _loadIncludeFile(String fileName) {
    File includeFile =
        File('${currentFile.parent.path}${Platform.pathSeparator}$fileName');
    if (includeFile.existsSync()) {
      configuration.loadFromFileSync(includeFile);
    }
  }

  /// Process the given line as a property. 
  /// This will split the property at the separator using any escape chars as 
  /// appropriate. If file includes ar enabled, files will also be included.
  void _processProperty(String line) {
    List<String> tokens = StringUtils.split(line.trim(),
        configuration.separatorChars, true, configuration.escapeChar);
    String propertyName = tokens[0];
    String propertyValue = '';
    if(tokens.length>1) {
      propertyValue = tokens[1];
    }
    

    if (propertyName.isNotEmpty) {
      if (configuration.include.isNotEmpty &&
          configuration.include == propertyName) {
        if (configuration.includesAllowed) {
          List<String> files = [];

          if (!configuration.delimiterParsingDisabled) {
            files =
                StringUtils.split(propertyValue, configuration.listDelimiter);
          } else {
            files.add(propertyValue);
          }

          for (String f in files) {
            _loadIncludeFile(configuration.interpolate(f.trim()).toString());
          }
        }
      } else {
        configuration.addProperty(propertyName, propertyValue);
      }
    }
  }

  /// Process the given set of lines.
  void _processLines(List<String> lines) {
    StringBuffer buffer = StringBuffer();
    bool isMultiLine = false;

    for (String line in lines) {
      if (!line.trim().startsWith('#') &&
          !line.startsWith('!') &&
          line.isNotEmpty) {
        if (line.endsWith('\\')) {
          int count = _checkLineEscape(line);
          // check if we have a multline
          if (count % 2 == 0) {
            if (isMultiLine) {
              // current line is NOT multiline but last line was, so lets handle that.
              buffer.write(_cleanLine(line));
              _processProperty(buffer.toString());
              buffer.clear();
              isMultiLine = false;
            } else {
              _processProperty(line);
            }
          } else {
            isMultiLine = true;
            buffer.write(_cleanLine(line));
          }
        } else {
          if (isMultiLine) {
            buffer.write(_cleanLine(line));
            _processProperty(buffer.toString());
            buffer.clear();
            isMultiLine = false;
          } else {
            _processProperty(line);
          }
        }
      }
    }
  }

  /// Load a file asynchronously.
  Future<void> loadFromFile(File file) async {
    currentFile = file;
    if(await file.exists()) {
      List<String> lines = await file.readAsLines();
      _processLines(lines);
    }
  }

  /// Load a file synchronously.
  void loadFromFileSync(File file) {
    if(file.existsSync()) {
      currentFile = file;
      _processLines(file.readAsLinesSync());
    }
  }
}
