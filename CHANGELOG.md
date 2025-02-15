# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - Fixed Issues and Code Cleanup

### Fixed
- Resolved issues related to incorrect environment variable parsing.

### Changed
- Updated `environment.yaml` to use PascalCase instead of snake_case for keys.
- Improved code readability and maintainability.
- Refactored internal logic for better performance and stability.

### Removed
- Removed unused dependencies to optimize package size.

## [1.0.0] - Initial Release

### Added
- Initial release of `flutter_env_manager`.
- Automatic creation of `environment.yaml` file if it doesn't exist.
- Dynamic generation of `AppEnvironment` class based on the selected environment in the YAML file.
- Support for multiple environments (e.g., `development`, `staging`, `production`).
- Support for custom key-value pairs in the YAML file.
- Command-line tool to generate the `AppEnvironment` class.

### Changed
- N/A (Initial release, no changes yet.)

### Fixed
- N/A (Initial release, no fixes yet.)

### Removed
- N/A (Initial release, nothing removed yet.)
