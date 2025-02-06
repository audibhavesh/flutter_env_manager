import 'dart:io';
import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

class EnvironmentGenerator implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    '.yaml': ['.env.dart']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final configPath = inputId.path;

    // If environment.yaml doesn't exist, create in project root
    final File configFile = File(configPath);
    if (!configFile.existsSync()) {
      final projectRoot = Directory.current.path;
      final newConfigPath = '$projectRoot/environment.yaml';

      final defaultConfig = '''
environments:
  development:
    base_url: https://api.dev.example.com
    api_key: dev_api_key
  production:
    base_url: https://api.example.com
    api_key: prod_api_key

current_environment: development
''';

      File(newConfigPath).writeAsStringSync(defaultConfig);
      print('Created environment.yaml at $newConfigPath');
    }

    // Read the YAML file
    final yamlContent = await buildStep.readAsString(inputId);
    final yamlMap = loadYaml(yamlContent);

    // Generate environment dart file
    final output = generateEnvironmentFile(yamlMap);

    // Write the generated file
    final outputId = AssetId(
        inputId.package,
        'lib/app_environment.dart'
    );
    await buildStep.writeAsString(outputId, output);
  }

  String generateEnvironmentFile(YamlMap yamlMap) {
    final currentEnv = yamlMap['current_environment'] ?? 'development';
    final envConfig = yamlMap['environments'][currentEnv] ?? {};

    return '''
// GENERATED FILE - DO NOT MODIFY
class AppEnvironment {
  static const String currentEnvironment = '$currentEnv';
  static const String baseUrl = '${envConfig['base_url'] ?? ''}';
  static const String apiKey = '${envConfig['api_key'] ?? ''}';
}
''';
  }
}

Builder environmentConfigBuilder(BuilderOptions options) => EnvironmentGenerator();