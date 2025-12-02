# Developer Notes

This folder contains internal documentation for developers working on this project.

## Contents

- **`implementation-summary.md`** - Comprehensive summary of the implementation, architecture decisions, and project structure

## Quick Reference

### Project Overview

This is a Dart port of the Python [youtube-transcript-api](https://github.com/jdepoix/youtube-transcript-api) library. It provides a clean, idiomatic Dart API for fetching YouTube transcripts without requiring an API key.

### Key Files

**Core Library:**
- `lib/src/youtube_transcript_api_base.dart` - Main API class
- `lib/youtube_transcript_api.dart` - Public exports

**Models:**
- `lib/src/models/` - All data models (Transcript, FetchedTranscript, etc.)

**HTTP:**
- `lib/src/http/` - HTTP client and proxy configuration

**Parsing:**
- `lib/src/parsing/` - YouTube response parsers

**Formatters:**
- `lib/src/formatters/` - Output format converters

**CLI:**
- `bin/youtube_transcript_api.dart` - Command-line tool

### Development Commands

```bash
# Install dependencies
dart pub get

# Run tests
dart test

# Run analyzer
dart analyze

# Format code
dart format .

# Run example
dart run example/main.dart

# Run CLI locally
dart run bin/youtube_transcript_api.dart VIDEO_ID
```

### Testing Strategy

- **Unit tests** - Test individual components in isolation
- **Parser tests** - Test XML and JSON parsing with sample data
- **Formatter tests** - Verify output formats match specifications
- **Exception tests** - Ensure proper error handling

### Architecture Principles

1. **Separation of Concerns** - Each module has a single responsibility
2. **Dependency Injection** - Allow custom HTTP clients for testing
3. **Null Safety** - Leverage Dart's null safety features
4. **Async/Await** - All I/O operations are properly async
5. **Clean API** - Public API mirrors Python library for familiarity

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` for consistent formatting
- Add doc comments for all public APIs
- Include examples in doc comments where helpful
- Prefer named parameters for optional arguments
- Use trailing commas for better diffs

### Common Tasks

#### Adding a New Formatter

1. Create class in `lib/src/formatters/`
2. Extend `TranscriptFormatter` base class
3. Implement `format()` method
4. Export in `lib/youtube_transcript_api.dart`
5. Add tests in `test/formatters_test.dart`
6. Update documentation

#### Adding a New Exception

1. Add class to `lib/src/exceptions.dart`
2. Extend `TranscriptException` base class
3. Add meaningful error message
4. Export in `lib/youtube_transcript_api.dart`
5. Add tests in `test/exceptions_test.dart`
6. Update documentation

#### Updating Parser Logic

1. Modify parser in `lib/src/parsing/`
2. Update tests with new sample data
3. Run tests to verify backward compatibility
4. Document any breaking changes

### YouTube API Notes

**Important:** This library relies on YouTube's internal web API, which:
- May change without notice
- Has rate limiting
- May block certain IP addresses
- Does not require an API key

If the library stops working:
1. Check if YouTube's HTML structure changed
2. Inspect network requests in browser dev tools
3. Update the parser logic in `transcript_list_parser.dart`
4. Update tests with new sample data

### Debugging Tips

1. **Enable verbose logging** - Add print statements to trace execution
2. **Inspect raw responses** - Print HTML/XML responses to understand structure
3. **Test with different videos** - Some videos have different formats
4. **Use browser dev tools** - Compare with actual YouTube behavior
5. **Check proxy settings** - Verify proxy configuration is correct

### Performance Considerations

- Parsing HTML is relatively expensive - consider caching
- Network requests are the main bottleneck
- Each video fetch requires 2 HTTP requests (page + transcript)
- Large transcripts can consume significant memory

### Security Considerations

- Never log or expose proxy credentials
- Sanitize video IDs to prevent injection attacks
- Be careful with user-provided proxy URLs
- Rate limit to avoid overwhelming YouTube's servers

### Publishing Checklist

Before publishing a new version:

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Run all tests: `dart test`
4. Run analyzer: `dart analyze`
5. Format code: `dart format .`
6. Test CLI: `dart run bin/youtube_transcript_api.dart`
7. Verify examples work
8. Update documentation if needed
9. Create git tag
10. Publish: `dart pub publish`

### Useful Resources

- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Package Layout Conventions](https://dart.dev/tools/pub/package-layout)
- [Original Python Library](https://github.com/jdepoix/youtube-transcript-api)

### Getting Help

- Check the implementation summary for detailed architecture info
- Look at test files for usage examples
- Refer to the original Python library for conceptual guidance
- Open an issue on GitHub for questions

### Contributing

See `CONTRIBUTING.md` in the project root for contribution guidelines.

---

**Last Updated:** December 2, 2024

