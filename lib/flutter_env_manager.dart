import 'dart:io';
import 'package:yaml/yaml.dart';
import 'dart:io';
import 'package:yaml/yaml.dart';

import 'env_manager.dart';


void main(List<String> arguments) async {
  await EnvManager.generateEnvClass();
  print('Environment class generated successfully!');
}