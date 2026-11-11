# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter application. Application code lives in `lib/`: shared foundations are in `core/` (constants, theme, utilities, reusable widgets), `data/` contains models, repositories, services, and mock data, and `routing/` and `services/` hold app-wide navigation and service code. Feature screens are grouped under `lib/features/<feature>/`, commonly split into `views/`, `viewmodels/`, and `widgets/`. Keep new feature-specific code with its feature; place reusable cross-feature code in `core/`. Static images are under `assets/images/`. Tests belong in `test/`, mirroring the relevant feature path where practical.

## Build, Test, and Development Commands

Run commands from the repository root:

- `flutter pub get` resolves dependencies from `pubspec.yaml`.
- `flutter run` launches the app on a connected device or selected emulator.
- `flutter analyze` runs Dart static analysis using `analysis_options.yaml` and `flutter_lints`.
- `flutter test` runs the test suite in `test/`.
- `flutter build apk` creates an Android APK when preparing an Android build.

## Coding Style & Naming Conventions

Follow standard Dart formatting: two-space indentation, trailing commas for readable multiline widget trees, and run `dart format lib test` before submitting. Use `snake_case.dart` filenames, `UpperCamelCase` for types, and `lowerCamelCase` for members and variables. Name tests with the `_test.dart` suffix. Preserve the existing feature-first boundaries and use Provider consistently for state management unless the architecture is deliberately changed.

## Testing Guidelines

Add or update tests for behavior you change. Use Flutter's `flutter_test` package; keep widget tests in `test/` and feature tests in matching subdirectories, for example `test/features/tracking/tracking_test.dart`. Run `flutter test` and `flutter analyze` before opening a pull request. No coverage threshold is configured.

## Commit & Pull Request Guidelines

Git metadata and commit history were not available during this guide's preparation, so no repository-specific commit convention could be confirmed. Prefer short, imperative commit subjects (for example, `Add retailer filter`). Pull requests should explain the user-visible change, link related work when applicable, list validation commands and results, and include screenshots for UI changes.

## Configuration & Assets

Declare dependencies in `pubspec.yaml` and register any new Flutter assets there before referencing them in code. Do not commit generated output such as `build/`, `.dart_tool/`, or local IDE settings.
