import 'package:test/test.dart';
import 'package:youtube_transcript_api/youtube_transcript_api.dart';

void main() {
  group('TranscriptSnippet', () {
    test('creates snippet correctly', () {
      final snippet = TranscriptSnippet(
        text: 'Hello, world!',
        start: 0.0,
        duration: 2.5,
      );

      expect(snippet.text, equals('Hello, world!'));
      expect(snippet.start, equals(0.0));
      expect(snippet.duration, equals(2.5));
    });

    test('converts to/from JSON', () {
      final snippet = TranscriptSnippet(
        text: 'Test',
        start: 1.0,
        duration: 3.0,
      );

      final json = snippet.toJson();
      expect(json['text'], equals('Test'));
      expect(json['start'], equals(1.0));
      expect(json['duration'], equals(3.0));

      final fromJson = TranscriptSnippet.fromJson(json);
      expect(fromJson, equals(snippet));
    });

    test('equality works correctly', () {
      final snippet1 = TranscriptSnippet(
        text: 'Test',
        start: 1.0,
        duration: 2.0,
      );

      final snippet2 = TranscriptSnippet(
        text: 'Test',
        start: 1.0,
        duration: 2.0,
      );

      final snippet3 = TranscriptSnippet(
        text: 'Different',
        start: 1.0,
        duration: 2.0,
      );

      expect(snippet1, equals(snippet2));
      expect(snippet1, isNot(equals(snippet3)));
    });
  });

  group('FetchedTranscript', () {
    test('iterates over snippets', () {
      final snippets = [
        TranscriptSnippet(text: 'First', start: 0.0, duration: 1.0),
        TranscriptSnippet(text: 'Second', start: 1.0, duration: 1.0),
      ];

      final transcript = FetchedTranscript(
        videoId: 'test123',
        language: 'English',
        languageCode: 'en',
        isGenerated: false,
        isTranslated: false,
        snippets: snippets,
      );

      final texts = <String>[];
      for (final snippet in transcript) {
        texts.add(snippet.text);
      }

      expect(texts, equals(['First', 'Second']));
    });

    test('converts to raw data', () {
      final snippets = [
        TranscriptSnippet(text: 'Test', start: 0.0, duration: 1.0),
      ];

      final transcript = FetchedTranscript(
        videoId: 'test123',
        language: 'English',
        languageCode: 'en',
        isGenerated: false,
        isTranslated: false,
        snippets: snippets,
      );

      final rawData = transcript.toRawData();
      expect(rawData.length, equals(1));
      expect(rawData[0]['text'], equals('Test'));
      expect(rawData[0]['start'], equals(0.0));
      expect(rawData[0]['duration'], equals(1.0));
    });
  });

  group('TranslationLanguage', () {
    test('creates translation language correctly', () {
      final lang = TranslationLanguage(
        languageCode: 'de',
        languageName: 'German',
      );

      expect(lang.languageCode, equals('de'));
      expect(lang.languageName, equals('German'));
    });

    test('equality works correctly', () {
      final lang1 = TranslationLanguage(
        languageCode: 'en',
        languageName: 'English',
      );

      final lang2 = TranslationLanguage(
        languageCode: 'en',
        languageName: 'English',
      );

      final lang3 = TranslationLanguage(
        languageCode: 'de',
        languageName: 'German',
      );

      expect(lang1, equals(lang2));
      expect(lang1, isNot(equals(lang3)));
    });
  });
}
