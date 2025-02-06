import 'dart:io';
import 'package:yaml/yaml.dart';

class EnvironmentConfig {
  static const String defaultConfigPath = 'environment.yaml';

  static void ensureConfigExists({String path = defaultConfigPath}) {
    final File configFile = File(path);

    if (!configFile.existsSync()) {
      final defaultConfig = '''
environments:
  development:
    base_url: https://api.dev.example.com
    api_key: dev_api_key
  staging:
    base_url: https://api.staging.example.com
    api_key: staging_api_key
  production:
    base_url: https://api.example.com
    api_key: prod_api_key

current_environment: development
''';

      configFile.writeAsStringSync(defaultConfig);
      print('Created default environment configuration at $path');
    }
  }

  static EnvironmentConfig fromYaml(String path) {
    ensureConfigExists(path: path);

    final File file = File(path);
    final String yamlString = file.readAsStringSync();
    final YamlMap yamlMap = loadYaml(yamlString);

    return EnvironmentConfig(
      currentEnvironment: yamlMap['current_environment'] ?? 'development',
      environments: Map<String, dynamic>.from(yamlMap['environments'] ?? {}),
    );
  }

  final String currentEnvironment;
  final Map<String, dynamic> environments;

  EnvironmentConfig({
    required this.currentEnvironment,
    required this.environments
  });

  dynamic getCurrentEnvironmentConfig() {
    return environments[currentEnvironment] ?? {};
  }
}