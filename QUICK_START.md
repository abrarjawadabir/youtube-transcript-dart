# Quick Start Guide

## Installation

1. Add to your `pubspec.yaml`:
```yaml
dependencies:
  youtube_transcript_api: ^1.0.0
```

2. Install dependencies:
```bash
dart pub get
```

## Basic Usage

### 1. Simple Transcript Fetch

```dart
import 'package:youtube_transcript_api/youtube_transcript_api.dart';

void main() async {
  final api = YouTubeTranscriptApi();
  
  try {
    // Fetch English transcript
    final transcript = await api.fetch('dQw4w9WgXcQ');
    
    // Print each line
    for (var snippet in transcript) {
      print('[${snippet.start}] ${snippet.text}');
    }
  } finally {
    api.dispose();
  }
}
```

### 2. List Available Transcripts

```dart
void main() async {
  final api = YouTubeTranscriptApi();
  
  try {
    final list = await api.list('dQw4w9WgXcQ');
    
    for (var transcript in list) {
      print('${transcript.language} (${transcript.languageCode})');
      print('  Generated: ${transcript.isGenerated}');
    }
  } finally {
    api.dispose();
  }
}
```

### 3. Language Fallback

```dart
void main() async {
  final api = YouTubeTranscriptApi();
  
  try {
    // Try German, then English, then French
    final transcript = await api.fetch(
      'dQw4w9WgXcQ',
      languages: ['de', 'en', 'fr'],
    );
    
    print('Got transcript in: ${transcript.language}');
  } finally {
    api.dispose();
  }
}
```

### 4. Export as Different Formats

```dart
void main() async {
  final api = YouTubeTranscriptApi();
  
  try {
    final transcript = await api.fetch('dQw4w9WgXcQ');
    
    // As JSON
    final jsonFormatter = JsonFormatter(pretty: true);
    final json = jsonFormatter.format(transcript);
    await File('transcript.json').writeAsString(json);
    
    // As SRT
    final srtFormatter = SrtFormatter();
    final srt = srtFormatter.format(transcript);
    await File('transcript.srt').writeAsString(srt);
    
    // As VTT
    final vttFormatter = VttFormatter();
    final vtt = vttFormatter.format(transcript);
    await File('transcript.vtt').writeAsString(vtt);
    
  } finally {
    api.dispose();
  }
}
```

### 5. Using Proxy

```dart
void main() async {
  final api = YouTubeTranscriptApi(
    proxyConfig: GenericProxyConfig(
      httpUrl: 'http://proxy.example.com:8080',
      httpsUrl: 'https://proxy.example.com:8443',
    ),
  );
  
  try {
    final transcript = await api.fetch('dQw4w9WgXcQ');
    // ... use transcript
  } finally {
    api.dispose();
  }
}
```

### 6. Webshare Rotating Proxy

```dart
void main() async {
  final api = YouTubeTranscriptApi(
    proxyConfig: WebshareProxyConfig(
      username: 'your-username',
      password: 'your-password',
      location: 'US', // Optional
    ),
  );
  
  try {
    final transcript = await api.fetch('dQw4w9WgXcQ');
    // ... use transcript
  } finally {
    api.dispose();
  }
}
```

## CLI Usage

### Install globally

```bash
dart pub global activate youtube_transcript_api
```

### Fetch transcript

```bash
# Default (English, plain text to stdout)
youtube_transcript_api dQw4w9WgXcQ

# Specific language
youtube_transcript_api dQw4w9WgXcQ -l de

# As JSON file
youtube_transcript_api dQw4w9WgXcQ -f json -o output.json

# As SRT file
youtube_transcript_api dQw4w9WgXcQ -f srt -o subtitle.srt

# List available transcripts
youtube_transcript_api dQw4w9WgXcQ --list
```

## Error Handling

```dart
void main() async {
  final api = YouTubeTranscriptApi();
  
  try {
    final transcript = await api.fetch('video-id');
  } on VideoUnavailableException catch (e) {
    print('Video not available: ${e.videoId}');
  } on TranscriptsDisabledException catch (e) {
    print('Transcripts disabled for: ${e.videoId}');
  } on NoTranscriptFoundException catch (e) {
    print('No transcript for languages: ${e.requestedLanguages}');
    print('Available: ${e.availableLanguages}');
  } on TooManyRequestsException catch (e) {
    print('Rate limited! Consider using a proxy.');
  } on TranscriptException catch (e) {
    print('Error: $e');
  } finally {
    api.dispose();
  }
}
```

## Translation

```dart
void main() async {
  final api = YouTubeTranscriptApi();
  
  try {
    final list = await api.list('dQw4w9WgXcQ');
    final transcript = list.findTranscript(['en']);
    
    if (transcript.isTranslatable) {
      // Translate to German
      final germanTranscript = transcript.translate('de');
      final fetched = await germanTranscript.fetch();
      
      for (var snippet in fetched) {
        print(snippet.text);
      }
    }
  } finally {
    api.dispose();
  }
}
```

## Common Patterns

### Get only manually created transcripts

```dart
final manual = await api.findManuallyCreatedTranscript(
  'video-id',
  ['en'],
);
```

### Get only auto-generated transcripts

```dart
final generated = await api.findGeneratedTranscript(
  'video-id',
  ['en'],
);
```

### Convert to raw data (List of Maps)

```dart
final transcript = await api.fetch('video-id');
final rawData = transcript.toRawData();
// rawData is List<Map<String, dynamic>>
```

### Custom timeout

```dart
final api = YouTubeTranscriptApi(
  timeout: Duration(seconds: 60),
);
```

### Custom headers

```dart
final api = YouTubeTranscriptApi(
  headers: {
    'User-Agent': 'MyApp/1.0',
    'Accept-Language': 'en-US,en;q=0.9',
  },
);
```

## Tips

1. **Always dispose** - Call `api.dispose()` when done to clean up resources
2. **Handle exceptions** - YouTube may block requests or videos may not have transcripts
3. **Use proxies** - If making many requests, use proxies to avoid rate limiting
4. **Check availability** - Use `list()` to check what's available before fetching
5. **Language codes** - Use standard ISO language codes (en, de, fr, es, etc.)

## Next Steps

- Read the full [README.md](README.md) for comprehensive documentation
- Check [example/main.dart](example/main.dart) for more examples
- Review [API documentation](https://pub.dev/documentation/youtube_transcript_api)
- Report issues on [GitHub](https://github.com/terry/youtube-transcript-dart/issues)

## Need Help?

- Check the [README](README.md)
- Look at [examples](example/)
- Open an [issue](https://github.com/terry/youtube-transcript-dart/issues)

