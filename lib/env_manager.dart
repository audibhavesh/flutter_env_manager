import 'dart:io';

import 'package:yaml/yaml.dart';

class EnvManager {
  static const String envFileName = 'environment.yaml';
  static const String envClassFileName = 'lib/app_environment.dart';

  static Future<void> generateEnvClass() async {
    final file = File(envFileName);
    if (!await file.exists()) {
      await _createDefaultEnvFile(file);
    }

    final yamlString = await file.readAsString();
    final yamlMap = loadYaml(yamlString);

    final currentEnv = yamlMap['current_environment'];
    final envConfig = yamlMap['environments'][currentEnv];

    // Generate the AppEnvironment class dynamically
    final classContent = '''
class AppEnvironment {
  static const String currentEnvironment = '$currentEnv';
${_generateStaticVariables(envConfig)}
}
''';

    final classFile = File(envClassFileName);
    await classFile.writeAsString(classContent);
  }

  static String _generateStaticVariables(YamlMap envConfig) {
    final buffer = StringBuffer();
    envConfig.forEach((key, value) {
      if (value is String) {
        buffer.writeln(
            "  static const String $key = '${value.replaceAll("'", "\\'")}';");
      } else if (value is num) {
        buffer.writeln("  static const num $key = $value;");
      } else if (value is bool) {
        buffer.writeln("  static const bool $key = $value;");
      } else {
        buffer.writeln("  static const dynamic $key = ${value.toString()};");
      }
    });
    return buffer.toString();
  }

  static Future<void> _createDefaultEnvFile(File file) async {
    const defaultYamlContent = '''
environments:
  development:
    base_url: https://api.dev.example.com
    api_key: dev_api_key
    custom_var: some_value
  staging:
    base_url: https://api.staging.example.com
    api_key: staging_api_key
  production:
    base_url: https://api.example.com
    api_key: prod_api_key

current_environment: development
''';

    await file.writeAsString(defaultYamlContent);
  }
}
