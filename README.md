# Flutter Env Manager

A Flutter package to manage environment configurations using YAML files. This package automatically generates a Dart class (`AppEnvironment`) based on the environment configuration defined in a `environment.yaml` file. It supports dynamic key-value pairs, making it easy to add custom variables for different environments.

---

## Features

- **Automatic YAML File Creation**: If `environment.yaml` doesn't exist, the package creates it with default values.
- **Dynamic Class Generation**: Generates a Dart class (`AppEnvironment`) with static variables for all key-value pairs in the selected environment.
- **Support for Multiple Environments**: Define multiple environments (e.g., `development`, `staging`, `production`) in the YAML file.
- **Custom Variables**: Add any number of custom variables to your environment configuration.
- **Pubspec Version Support**: Writes the app version in `pubspec.yaml` and includes it in the generated `AppEnvironment` class.

---

## Installation

Add `flutter_env_manager` to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_env_manager: ^1.0.5
```

---

## Usage

Run the package using the following command:

```sh
dart run flutter_env_manager
```
This will pick the environment from `environment.yaml`.

To specify an environment manually, run:

```sh
dart run flutter_env_manager development
```
This will use the `development` environment.

If using `fvm`, you can run:

```sh
fvm dart run flutter_env_manager
```
or

```sh
fvm dart run flutter_env_manager development
```

---

## Developed by:

Bhavesh Auodichya  

Personal email  - [theoctacoder@gmail.com](mailto:theoctacoder@gmail.com)

Work email  - [bhavesa@fermion.in](mailto:bhavesa@fermion.in)

Publisher's LinkedIn - [Fermion Infotech](https://www.linkedin.com/company/fermioninfotech?trk=profile-position)
