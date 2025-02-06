// build.dart
import 'package:build_runner/build_runner.dart';
import 'package:build_config/build_config.dart';

BuildConfig buildConfig() {
  return BuildConfig.fromMap("",[],{
    'builders': {
      'environment_config': {
        'target': 'environment_config',
        'import': 'package:your_package/environment_generator.dart',
        'builder_factories': ['environmentConfigBuilder'],
        'build_extensions': {'.yaml': ['.env.dart']},
        'auto_apply': 'root_package'
      }
    }
  });
}