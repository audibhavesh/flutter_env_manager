import 'package:build/build.dart';
import 'dart:io';

import 'flutter_env_manager.dart';

class EnvironmentGenerator implements Builder {
  @override
  final Map<String, List<String>> buildExtensions = {
    '.yaml': ['.env.dart']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    const configPath = 'environment.yaml';
    final config = EnvironmentConfig.fromYaml(configPath);
    final currentEnvConfig = config.getCurrentEnvironmentConfig();

    final output = '''
// GENERATED FILE - DO NOT MODIFY
class AppEnvironment {
  static const String currentEnvironment = '${config.currentEnvironment}';
  static const String baseUrl = '${currentEnvConfig['base_url']}';
  static const String apiKey = '${currentEnvConfig['api_key']}';
}
''';

    await buildStep.writeAsString(
        AssetId(buildStep.inputId.package, 'lib/app_environment.dart'),
        output
    );
  }
}

Builder environmentConfigBuilder(BuilderOptions options) => EnvironmentGenerator();
