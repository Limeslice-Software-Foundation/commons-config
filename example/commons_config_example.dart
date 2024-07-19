import 'dart:io';

import 'package:commons_config/commons_config.dart';

void main() {
  Properties properties = Properties();
  properties.loadSync(File('logging.props'));
  print(properties.getProperty('log4delphi.rootLogger'));
  print(properties.getBool('log4delphi.debug'));
}
