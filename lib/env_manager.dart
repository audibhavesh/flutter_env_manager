import 'package:universal_io/io.dart';
import 'package:yaml/yaml.dart';

/// A utility class for managing environment configurations in Flutter apps.
///
/// `EnvManager` reads from `environment.yaml`, generates a Dart class (`AppEnvironment`),
/// and includes app versioning from `pubspec.yaml`.
class EnvManager {
  /// The name of the environment YAML file.
  static const String envFileName = 'environment.yaml';

  /// The name of the generated Dart environment class file.
  static const String envClassFileName = 'lib/app_environment.dart';

  /// The name of the `pubspec.yaml` file.
  static const String pubspecFileName = 'pubspec.yaml';

  /// Generates the `AppEnvironment` class based on the current environment.
  ///
  /// If [envArgument] is provided, it uses that environment;
  /// otherwise, it defaults to the `current_environment` value in `environment.yaml`.
  ///
  /// The generated class contains static constants for environment variables.
  static Future<void> generateEnvClass([String? envArgument]) async {
    final envFile = File(envFileName);
    if (!await envFile.exists()) {
      await _createDefaultEnvFile(envFile);
    }

    final yamlString = await envFile.readAsString();
    final yamlMap = loadYaml(yamlString);

    final currentEnv = envArgument ?? yamlMap['current_environment'];
    final environments = yamlMap['environments'] as Map;

    if (!environments.containsKey(currentEnv)) {
      print('Error: Environment "$currentEnv" does not exist in $envFileName.');
      exit(1);
    }

    final envConfig = environments[currentEnv];
    final appVersion = await _readAppVersion();

    // Generate the AppEnvironment class dynamically
    final classContent = '''
// THIS FILE IS GENERATED AUTOMATICALLY. DO NOT EDIT.

/// Contains environment variables and app configuration.
class AppEnvironment {
  /// The current selected environment.
  static const String currentEnvironment = '$currentEnv';

  /// The application version from `pubspec.yaml`.
  static const String version = '$appVersion';

${_generateStaticVariables(envConfig)}
}
''';

    final classFile = File(envClassFileName);
    await classFile.writeAsString(classContent);
  }

  /// Generates static variables for the `AppEnvironment` class from the YAML config.
  ///
  /// Converts key-value pairs into static constants.
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

  /// Reads the app version from `pubspec.yaml`.
  ///
  /// If the version is not found, returns `'unknown'`.
  static Future<String> _readAppVersion() async {
    final pubspecFile = File(pubspecFileName);
    if (!await pubspecFile.exists()) {
      return 'unknown';
    }

    final yamlString = await pubspecFile.readAsString();
    final yamlMap = loadYaml(yamlString);
    return yamlMap['version']?.toString() ?? 'unknown';
  }

  /// Creates a default `environment.yaml` file if it doesn't exist.
  ///
  /// This ensures the package has a valid environment configuration.
  static Future<void> _createDefaultEnvFile(File file) async {
    const defaultYamlContent = '''
environments:
  development:
    baseUrl: https://api.dev.example.com
    apiKey: dev_api_key
  staging:
    baseUrl: https://api.staging.example.com
    apiKey: staging_api_key
  production:
    baseUrl: https://api.example.com
    apiKey: prod_api_key

current_environment: development
''';

    await file.writeAsString(defaultYamlContent);
  }
}
