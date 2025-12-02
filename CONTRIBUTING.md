# Contributing to YouTube Transcript API (Dart)

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/youtube-transcript-dart.git
   cd youtube-transcript-dart
   ```
3. **Install dependencies**:
   ```bash
   dart pub get
   ```

## Development Workflow

### Running Tests

Run all tests:
```bash
dart test
```

Run specific test file:
```bash
dart test test/models_test.dart
```

Run tests with coverage:
```bash
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

### Code Style

This project follows the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style).

- Use `dart format` to format your code:
  ```bash
  dart format .
  ```

- Use `dart analyze` to check for issues:
  ```bash
  dart analyze
  ```

### Linting

The project uses the recommended linter rules. Make sure there are no lint errors before submitting:

```bash
dart analyze --fatal-infos
```

## Making Changes

1. **Create a new branch** for your feature or bugfix:
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make your changes** following the code style guidelines

3. **Write or update tests** for your changes

4. **Run tests** to ensure everything works:
   ```bash
   dart test
   ```

5. **Commit your changes** with a clear commit message:
   ```bash
   git commit -am "Add new feature: description"
   ```

6. **Push to your fork**:
   ```bash
   git push origin feature/my-new-feature
   ```

7. **Submit a Pull Request** on GitHub

## Pull Request Guidelines

- **Title**: Use a clear, descriptive title
- **Description**: Explain what changes you made and why
- **Tests**: Include tests for new functionality
- **Documentation**: Update README.md if you add new features
- **Changelog**: Add an entry to CHANGELOG.md under "Unreleased"
- **Breaking Changes**: Clearly mark any breaking changes

## Types of Contributions

### Bug Reports

When filing a bug report, please include:
- Dart/Flutter version
- Operating system
- Clear steps to reproduce the issue
- Expected vs actual behavior
- Any relevant error messages or stack traces

### Feature Requests

For feature requests, please:
- Describe the use case
- Explain why the feature would be valuable
- Provide examples if possible

### Code Contributions

Areas where contributions are especially welcome:
- Bug fixes
- Performance improvements
- Additional formatters
- Enhanced error handling
- Documentation improvements
- Test coverage improvements

## Code Review Process

1. All pull requests require review before merging
2. Reviewers will check for:
   - Code quality and style
   - Test coverage
   - Documentation
   - Breaking changes
3. Address any feedback from reviewers
4. Once approved, a maintainer will merge your PR

## Development Setup

### Prerequisites

- Dart SDK 3.0 or higher
- Git

### Dependencies

The project uses these main dependencies:
- `http` - HTTP client
- `html` - HTML parsing
- `args` - CLI argument parsing
- `test` - Testing framework

## Testing Guidelines

- Write tests for all new functionality
- Maintain or improve test coverage
- Use descriptive test names
- Group related tests together
- Mock external dependencies when appropriate

Example test structure:
```dart
import 'package:test/test.dart';

void main() {
  group('MyClass', () {
    test('does something correctly', () {
      // Arrange
      final instance = MyClass();
      
      // Act
      final result = instance.doSomething();
      
      // Assert
      expect(result, equals(expectedValue));
    });
  });
}
```

## Documentation

- Add dartdoc comments for all public APIs
- Use `///` for documentation comments
- Include examples in doc comments when helpful
- Update README.md for user-facing changes

Example:
```dart
/// Fetches a transcript for the given video ID.
/// 
/// The [videoId] should be a valid YouTube video ID.
/// 
/// Example:
/// ```dart
/// final transcript = await api.fetch('dQw4w9WgXcQ');
/// ```
Future<FetchedTranscript> fetch(String videoId) async {
  // Implementation
}
```

## Release Process

Maintainers will handle releases following these steps:
1. Update version in `pubspec.yaml`
2. Update CHANGELOG.md
3. Create a git tag
4. Publish to pub.dev
5. Create GitHub release

## Questions?

Feel free to open an issue with the `question` label if you need help or clarification.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

