import 'package:flutter_env_manager/env_manager.dart';

void main(List<String> arguments) async {
  final envArgument = arguments.isNotEmpty ? arguments.first : null;
  await EnvManager.generateEnvClass(envArgument);
}
