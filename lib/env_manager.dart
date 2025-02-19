import 'package:universal_io/io.dart';
import 'package:yaml/yaml.dart';

/// A utility class for managing environment configurations in Flutter apps.
///
/// The `EnvManager` reads from `environment.yaml`, generates a Dart class (`AppEnvironment`),
/// and updates the app version in `pubspec.yaml` based on the selected environment.
class EnvManager {
  /// The name of the environment YAML file.
  static const String envFileName = 'environment.yaml';

  /// The name of the generated Dart environment class file.
  static const String envClassFileName = 'lib/app_environment.dart';

  /// The name of the `pubspec.yaml` file.
  static const String pubspecFileName = 'pubspec.yaml';

  /// Generates the `AppEnvironment` class and updates `pubspec.yaml` with the selected environment's version.
  ///
  /// - If [envArgument] is provided, it uses that environment.
  /// - Otherwise, it defaults to the `current_environment` value in `environment.yaml`.
  ///
  /// The function does the following:
  /// 1. Reads the `environment.yaml` file.
  /// 2. Determines the selected environment.
  /// 3. Retrieves the environment-specific version.
  /// 4. Updates `pubspec.yaml` with the correct version.
  /// 5. Generates a `lib/app_environment.dart` class with environment variables.
  ///
  /// Example usage:
  /// ```dart
  /// void main() async {
  ///   await EnvManager.generateEnvClass();
  /// }
  /// ```
  ///
  /// If the selected environment is marked as `isProdEnv: true`, the version format is:
  /// ```
  /// version: 1.0.0
  /// ```
  /// Otherwise, the version format is:
  /// ```
  /// version: 1.0.0-staging  // Example for staging
  /// ```
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

    final envConfig = environments[currentEnv] as YamlMap;
    final baseVersion = envConfig['version'] ?? '1.0.0';

    // Determine if the environment is production
    var isProdEnv = false;
    if (envConfig.containsKey("isProdEnv")) {
      isProdEnv = envConfig['isProdEnv'] == true;
    }

    // Format version based on `isProdEnv`
    final formattedVersion =
    isProdEnv ? baseVersion : '$baseVersion-$currentEnv';

    // Update `pubspec.yaml` with the selected environment version
    await _updatePubspecVersion(formattedVersion);

    // Generate the AppEnvironment class dynamically
    final classContent = '''
// THIS FILE IS GENERATED AUTOMATICALLY. DO NOT EDIT.

/// Contains environment variables and app configuration.
class AppEnvironment {
  /// The current selected environment.
  static const String currentEnvironment = '$currentEnv';

  /// The application version from `environment.yaml`.
  static const String version = '$formattedVersion';

${_generateStaticVariables(envConfig)}
}
''';

    final classFile = File(envClassFileName);
    await classFile.writeAsString(classContent);

    print('Environment class generated successfully.');
  }

  /// Generates static constants for environment variables in the `AppEnvironment` class.
  ///
  /// This function converts key-value pairs from `environment.yaml` into static constants.
  ///
  /// - **Strings** are assigned as `static const String`
  /// - **Numbers** are assigned as `static const num`
  /// - **Booleans** are assigned as `static const bool`
  /// - **Other types** are assigned as `static const dynamic`
  ///
  /// Example:
  /// ```yaml
  /// baseUrl: "https://api.example.com"
  /// apiKey: "123456"
  /// isFeatureEnabled: true
  /// ```
  ///
  /// Will be converted to:
  /// ```dart
  /// static const String baseUrl = "https://api.example.com";
  /// static const String apiKey = "123456";
  /// static const bool isFeatureEnabled = true;
  /// ```
  static String _generateStaticVariables(YamlMap envConfig) {
    final buffer = StringBuffer();
    envConfig.forEach((key, value) {
      if (key == 'version' || key == 'isProdEnv') return; // Skip handled keys

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

  /// Updates the `version` field in `pubspec.yaml` with the selected environment version.
  ///
  /// - If `isProdEnv: true`, the version is set as `1.0.0`
  /// - Otherwise, it follows `{version}-{environment}` format, e.g., `1.0.0-staging`
  ///
  /// If the `pubspec.yaml` file does not exist, an error message is printed.
  static Future<void> _updatePubspecVersion(String newVersion) async {
    final pubspecFile = File(pubspecFileName);
    if (!await pubspecFile.exists()) {
      print('Error: $pubspecFileName not found.');
      return;
    }

    final yamlString = await pubspecFile.readAsString();
    final yamlMap = loadYaml(yamlString);

    if (!yamlMap.containsKey('version')) {
      print('Error: No version key found in $pubspecFileName.');
      return;
    }

    // Modify the version key in pubspec.yaml
    final updatedYaml = yamlString.replaceFirst(
      RegExp(r'version:\s*[\d.]+(-\w+)?'), // Match version field
      'version: $newVersion',
    );

    await pubspecFile.writeAsString(updatedYaml);
    print('Updated pubspec.yaml version to: $newVersion');
  }

  /// Creates a default `environment.yaml` file if it doesn't exist.
  ///
  /// The default content includes `development`, `staging`, and `production` environments.
  /// - The production environment is marked with `isProdEnv: true`
  static Future<void> _createDefaultEnvFile(File file) async {
    const defaultYamlContent = '''
environments:
  development:
    baseUrl: https://api.dev.example.com
    apiKey: dev_api_key
    version: 1.0.0
  staging:
    baseUrl: https://api.staging.example.com
    apiKey: staging_api_key
    version: 1.0.0
  production:
    baseUrl: https://api.example.com
    apiKey: prod_api_key
    version: 1.0.0
    isProdEnv: true

current_environment: development
''';

    await file.writeAsString(defaultYamlContent);
  }
}
