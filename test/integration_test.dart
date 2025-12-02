import 'dart:io';
import 'package:test/test.dart';
import 'package:youtube_transcript_api/youtube_transcript_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('Integration Tests (with fixture responses)', () {
    late String htmlFixture;
    late String innertubeFixture;
    late String transcriptFixture;

    setUpAll(() async {
      // Load fixtures
      htmlFixture =
          await File('test/fixtures/youtube_page.html').readAsString();
      innertubeFixture =
          await File('test/fixtures/innertube_response.json').readAsString();
      transcriptFixture =
          await File('test/fixtures/transcript.xml').readAsString();
    });

    test('fetches transcript end-to-end with fixtures', () async {
      // Mock HTTP client returns fixtures
      // This tests the REAL code paths: API key extraction, InnerTube parsing, XML parsing
      final mockClient = MockClient((request) async {
        final url = request.url.toString();

        // Return appropriate fixture based on URL
        if (url.contains('youtube.com/watch?v=')) {
          return http.Response(htmlFixture, 200);
        } else if (url.contains('youtubei/v1/player')) {
          return http.Response(innertubeFixture, 200);
        } else if (url.contains('api/timedtext')) {
          return http.Response(transcriptFixture, 200);
        }

        return http.Response('Not Found', 404);
      });

      // Use REAL library with mocked HTTP
      final httpClient = TranscriptHttpClient(customClient: mockClient);
      final api = YouTubeTranscriptApi(httpClient: httpClient);

      try {
        // This exercises the REAL code:
        // 1. YouTubeTranscriptApi.fetch() - the main API method
        // 2. _extractInnertubeApiKey() - API key extraction from HTML
        // 3. _fetchInnertubeData() - InnerTube POST request
        // 4. _extractCaptionsJson() - Captions extraction
        // 5. TranscriptListParser.parse() - Parsing transcript list
        // 6. Transcript.fetch() - Fetching transcript content
        // 7. TranscriptParser.parseXml() - XML parsing
        final transcript = await api.fetch('eF8Qqp7rjDg', languages: ['en']);

        // Verify the transcript was parsed correctly
        expect(transcript.videoId, equals('eF8Qqp7rjDg'));
        expect(transcript.languageCode, equals('en'));
        expect(transcript.snippets, isNotEmpty);
        expect(transcript.snippets.length, greaterThan(50));

        // Check first snippet
        final first = transcript.snippets.first;
        expect(first.text, isNotEmpty);
        expect(first.start, greaterThanOrEqualTo(0));
        expect(first.duration, greaterThanOrEqualTo(0));

        // Verify iterator works
        var count = 0;
        for (var snippet in transcript) {
          count++;
          expect(snippet.text, isNotEmpty);
        }
        expect(count, equals(transcript.snippets.length));

        // Test toRawData
        final rawData = transcript.toRawData();
        expect(rawData, isList);
        expect(rawData.first['text'], equals(first.text));
        expect(rawData.first['start'], equals(first.start));
      } finally {
        api.dispose();
      }
    });

    test('lists transcripts end-to-end with fixtures', () async {
      final mockClient = MockClient((request) async {
        final url = request.url.toString();

        if (url.contains('youtube.com/watch?v=')) {
          return http.Response(htmlFixture, 200);
        } else if (url.contains('youtubei/v1/player')) {
          return http.Response(innertubeFixture, 200);
        }

        return http.Response('Not Found', 404);
      });

      final httpClient = TranscriptHttpClient(customClient: mockClient);
      final api = YouTubeTranscriptApi(httpClient: httpClient);

      try {
        // This exercises REAL code:
        // - API key extraction from HTML
        // - InnerTube POST request
        // - Captions JSON extraction
        // - TranscriptList parsing
        final transcriptList = await api.list('eF8Qqp7rjDg');

        expect(transcriptList, isNotEmpty);
        expect(transcriptList.videoId, equals('eF8Qqp7rjDg'));
        expect(transcriptList.length, greaterThan(0));

        // Test iteration
        var count = 0;
        for (var transcript in transcriptList) {
          count++;
          expect(transcript.languageCode, isNotEmpty);
          expect(transcript.language, isNotEmpty);
          expect(transcript.videoId, equals('eF8Qqp7rjDg'));
        }
        expect(count, equals(transcriptList.length));

        // Test finding transcripts
        final transcript = transcriptList.findTranscript(['en']);
        expect(transcript.languageCode, equals('en'));
        expect(transcript.isGenerated, isTrue);
      } finally {
        api.dispose();
      }
    });

    test('tests formatters with real transcript', () async {
      final mockClient = MockClient((request) async {
        final url = request.url.toString();

        if (url.contains('youtube.com/watch?v=')) {
          return http.Response(htmlFixture, 200);
        } else if (url.contains('youtubei/v1/player')) {
          return http.Response(innertubeFixture, 200);
        } else if (url.contains('api/timedtext')) {
          return http.Response(transcriptFixture, 200);
        }

        return http.Response('Not Found', 404);
      });

      final httpClient = TranscriptHttpClient(customClient: mockClient);
      final api = YouTubeTranscriptApi(httpClient: httpClient);

      try {
        final transcript = await api.fetch('eF8Qqp7rjDg');

        // Test all formatters with real data
        final textFormatter = TextFormatter();
        final textOutput = textFormatter.format(transcript);
        expect(textOutput, contains('citizens of the world'));

        final jsonFormatter = JsonFormatter(pretty: true);
        final jsonOutput = jsonFormatter.format(transcript);
        expect(jsonOutput, contains('"text"'));
        expect(jsonOutput, contains('"start"'));

        final vttFormatter = VttFormatter();
        final vttOutput = vttFormatter.format(transcript);
        expect(vttOutput, startsWith('WEBVTT'));
        expect(vttOutput, contains('-->'));

        final srtFormatter = SrtFormatter();
        final srtOutput = srtFormatter.format(transcript);
        expect(srtOutput, contains('1\n'));
        expect(srtOutput, contains('-->'));

        final csvFormatter = CsvFormatter();
        final csvOutput = csvFormatter.format(transcript);
        expect(csvOutput, contains('start,duration,text'));
      } finally {
        api.dispose();
      }
    });
  });
}

