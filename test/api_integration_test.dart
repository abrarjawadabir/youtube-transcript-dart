import 'dart:io';
import 'package:test/test.dart';
import 'package:youtube_transcript_api/youtube_transcript_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Integration tests that verify the library works end-to-end.
///
/// These tests use the REAL library code with mocked HTTP responses,
/// ensuring all parsing and business logic is exercised.
void main() {
  group('API Integration Tests', () {
    const testVideoId = 'eF8Qqp7rjDg';
    late String htmlFixture;
    late String innertubeFixture;
    late String transcriptFixture;

    setUpAll(() async {
      // Load captured fixtures
      htmlFixture =
          await File('test/fixtures/youtube_page.html').readAsString();
      innertubeFixture =
          await File('test/fixtures/innertube_response.json').readAsString();
      transcriptFixture =
          await File('test/fixtures/transcript.xml').readAsString();
    });

    test('fetches transcript using fixtures (exercises real code)', () async {
      // Mock HTTP client returns fixtures
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
        // This exercises ALL the real code paths:
        // ✓ YouTubeTranscriptApi.fetch()
        // ✓ API key extraction (_extractInnertubeApiKey)
        // ✓ InnerTube POST request (_fetchInnertubeData)
        // ✓ Captions extraction (_extractCaptionsJson)
        // ✓ Playability check (_checkPlayabilityStatus)
        // ✓ TranscriptList parsing
        // ✓ Transcript fetching
        // ✓ XML parsing (TranscriptParser.parseXml)
        // ✓ HTML entity decoding
        final transcript = await api.fetch(testVideoId, languages: ['en']);

        // Verify results
        expect(transcript.videoId, equals(testVideoId));
        expect(transcript.languageCode, equals('en'));
        expect(transcript.isGenerated, isTrue);
        expect(transcript.snippets, isNotEmpty);

        // Verify specific content from the fixture
        final firstSnippet = transcript.snippets.first;
        expect(firstSnippet.text, contains('citizens'));
        expect(firstSnippet.start, greaterThanOrEqualTo(0));
        expect(firstSnippet.duration, greaterThanOrEqualTo(0));

        // Test iteration (exercises FetchedTranscript's Iterator)
        var iterationCount = 0;
        for (var snippet in transcript) {
          iterationCount++;
          expect(snippet.text, isNotEmpty);
        }
        expect(iterationCount, equals(transcript.snippets.length));

        // Test raw data export
        final rawData = transcript.toRawData();
        expect(rawData, hasLength(transcript.snippets.length));
        expect(rawData.first['text'], equals(firstSnippet.text));
      } finally {
        api.dispose();
      }
    });

    test('lists transcripts using fixtures', () async {
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
        // Exercises: API key extraction, InnerTube call, TranscriptList parsing
        final transcriptList = await api.list(testVideoId);

        expect(transcriptList.videoId, equals(testVideoId));
        expect(transcriptList, isNotEmpty);

        // Test finding transcripts
        final transcript = transcriptList.findTranscript(['en']);
        expect(transcript.languageCode, equals('en'));
        expect(transcript.isGenerated, isTrue);

        // Test iteration over TranscriptList
        var count = 0;
        for (var t in transcriptList) {
          count++;
          expect(t.languageCode, isNotEmpty);
        }
        expect(count, greaterThan(0));
      } finally {
        api.dispose();
      }
    });

    test('all formatters work with fixture transcript', () async {
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
        final transcript = await api.fetch(testVideoId);

        // Test all formatters (exercises formatter code paths)
        final textFormatter = TextFormatter();
        final textOutput = textFormatter.format(transcript);
        expect(textOutput, contains('citizens'));
        expect(textOutput, isNot(contains('<')));

        final jsonFormatter = JsonFormatter(pretty: true);
        final jsonOutput = jsonFormatter.format(transcript);
        expect(jsonOutput, contains('"text"'));
        expect(jsonOutput, contains('"start"'));
        expect(jsonOutput, contains('"duration"'));

        final vttFormatter = VttFormatter();
        final vttOutput = vttFormatter.format(transcript);
        expect(vttOutput, startsWith('WEBVTT'));
        expect(vttOutput, contains('00:00:00.'));
        expect(vttOutput, contains('-->'));

        final srtFormatter = SrtFormatter();
        final srtOutput = srtFormatter.format(transcript);
        expect(srtOutput, matches(RegExp(r'^\d+\n')));
        expect(srtOutput, contains('00:00:00,'));
        expect(srtOutput, contains('-->'));

        final csvFormatter = CsvFormatter(includeHeader: true);
        final csvOutput = csvFormatter.format(transcript);
        expect(csvOutput, startsWith('start,duration,text'));
        final lines = csvOutput.split('\n');
        expect(lines.length, greaterThan(transcript.snippets.length));
      } finally {
        api.dispose();
      }
    });

    // OPTIONAL: Test against real YouTube API (skip in CI)
    // Uncomment to verify fixtures are still valid
    /*
    test('compares fixture vs real API results', () async {
      // Get transcript using fixtures
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

      final httpClient1 = TranscriptHttpClient(customClient: mockClient);
      final api1 = YouTubeTranscriptApi(httpClient: httpClient1);
      final fixtureTranscript = await api1.fetch(testVideoId);
      api1.dispose();

      // Get transcript from real API
      final api2 = YouTubeTranscriptApi();
      final realTranscript = await api2.fetch(testVideoId);
      api2.dispose();

      // Compare results
      expect(fixtureTranscript.snippets.length, equals(realTranscript.snippets.length));
      expect(fixtureTranscript.languageCode, equals(realTranscript.languageCode));
      
      // Check first few snippets match
      for (var i = 0; i < 5; i++) {
        expect(fixtureTranscript.snippets[i].text, 
               equals(realTranscript.snippets[i].text));
        expect(fixtureTranscript.snippets[i].start, 
               equals(realTranscript.snippets[i].start));
      }
    }, skip: 'Skipped in CI - requires real YouTube API access');
    */
  });
}
