import 'package:test/test.dart';
import 'package:youtube_transcript_api/youtube_transcript_api.dart';

void main() {
  late FetchedTranscript sampleTranscript;

  setUp(() {
    sampleTranscript = FetchedTranscript(
      videoId: 'test123',
      language: 'English',
      languageCode: 'en',
      isGenerated: false,
      isTranslated: false,
      snippets: [
        TranscriptSnippet(text: 'Hello, world!', start: 0.0, duration: 2.5),
        TranscriptSnippet(text: 'This is a test.', start: 2.5, duration: 3.0),
      ],
    );
  });

  group('TextFormatter', () {
    test('formats as plain text', () {
      final formatter = TextFormatter();
      final result = formatter.format(sampleTranscript);

      expect(result, equals('Hello, world!\nThis is a test.'));
      expect(formatter.fileExtension, equals('txt'));
      expect(formatter.mimeType, equals('text/plain'));
    });

    test('formats with timestamps', () {
      final formatter = TextFormatterWithTimestamps();
      final result = formatter.format(sampleTranscript);

      expect(result, contains('[0.0] Hello, world!'));
      expect(result, contains('[2.5] This is a test.'));
    });
  });

  group('JsonFormatter', () {
    test('formats as JSON', () {
      final formatter = JsonFormatter(pretty: false);
      final result = formatter.format(sampleTranscript);

      expect(result, contains('"text":"Hello, world!"'));
      expect(result, contains('"start":0.0'));
      expect(result, contains('"duration":2.5'));
      expect(formatter.fileExtension, equals('json'));
      expect(formatter.mimeType, equals('application/json'));
    });

    test('formats as pretty JSON', () {
      final formatter = JsonFormatter(pretty: true);
      final result = formatter.format(sampleTranscript);

      expect(result, contains('  '));
      expect(result, contains('"text": "Hello, world!"'));
    });

    test('formats with metadata', () {
      final formatter = JsonFormatterWithMetadata(pretty: true);
      final result = formatter.format(sampleTranscript);

      expect(result, contains('"videoId": "test123"'));
      expect(result, contains('"language": "English"'));
      expect(result, contains('"languageCode": "en"'));
      expect(result, contains('"isGenerated": false'));
      expect(result, contains('"isTranslated": false'));
    });
  });

  group('VttFormatter', () {
    test('formats as WebVTT', () {
      final formatter = VttFormatter();
      final result = formatter.format(sampleTranscript);

      expect(result, startsWith('WEBVTT\n'));
      expect(result, contains('00:00:00.000 --> 00:00:02.500'));
      expect(result, contains('Hello, world!'));
      expect(result, contains('00:00:02.500 --> 00:00:05.500'));
      expect(result, contains('This is a test.'));
      expect(formatter.fileExtension, equals('vtt'));
      expect(formatter.mimeType, equals('text/vtt'));
    });
  });

  group('SrtFormatter', () {
    test('formats as SRT', () {
      final formatter = SrtFormatter();
      final result = formatter.format(sampleTranscript);

      expect(result, contains('1\n'));
      expect(result, contains('00:00:00,000 --> 00:00:02,500'));
      expect(result, contains('Hello, world!'));
      expect(result, contains('2\n'));
      expect(result, contains('00:00:02,500 --> 00:00:05,500'));
      expect(result, contains('This is a test.'));
      expect(formatter.fileExtension, equals('srt'));
      expect(formatter.mimeType, equals('application/x-subrip'));
    });
  });

  group('CsvFormatter', () {
    test('formats as CSV with header', () {
      final formatter = CsvFormatter(includeHeader: true);
      final result = formatter.format(sampleTranscript);

      expect(result, startsWith('start,duration,text\n'));
      expect(result, contains('0.0,2.5'));
      expect(result, contains('2.5,3.0'));
      expect(result, contains('Hello, world!'));
      expect(result, contains('This is a test.'));
      expect(formatter.fileExtension, equals('csv'));
      expect(formatter.mimeType, equals('text/csv'));
    });

    test('formats as CSV without header', () {
      final formatter = CsvFormatter(includeHeader: false);
      final result = formatter.format(sampleTranscript);

      expect(result, isNot(contains('start,duration,text')));
      expect(result, startsWith('0.0,2.5'));
    });

    test('escapes CSV fields correctly', () {
      final transcript = FetchedTranscript(
        videoId: 'test',
        language: 'English',
        languageCode: 'en',
        isGenerated: false,
        isTranslated: false,
        snippets: [
          TranscriptSnippet(
            text: 'Text with, comma',
            start: 0.0,
            duration: 1.0,
          ),
          TranscriptSnippet(
            text: 'Text with "quotes"',
            start: 1.0,
            duration: 1.0,
          ),
        ],
      );

      final formatter = CsvFormatter(includeHeader: false);
      final result = formatter.format(transcript);

      expect(result, contains('"Text with, comma"'));
      expect(result, contains('"Text with ""quotes"""'));
    });
  });
}
