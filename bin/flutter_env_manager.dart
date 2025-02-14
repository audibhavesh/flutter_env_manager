import 'dart:io';
import 'package:flutter_env_manager/env_manager.dart';
import 'package:flutter_env_manager/flutter_env_manager.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';
import 'package:yaml/yaml.dart';

void main(List<String> arguments) async {
  await EnvManager.generateEnvClass();
  print('Environment class generated successfully!');
}