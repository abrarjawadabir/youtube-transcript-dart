import 'package:test/test.dart';
import 'package:youtube_transcript_api/src/parsing/transcript_parser.dart';

void main() {
  group('TranscriptParser', () {
    test('parses simple XML transcript', () {
      const xmlContent = '''
        <?xml version="1.0" encoding="utf-8"?>
        <transcript>
          <text start="0.0" dur="2.5">Hello, world!</text>
          <text start="2.5" dur="3.0">This is a test.</text>
        </transcript>
      ''';

      final snippets = TranscriptParser.parseXml(xmlContent);

      expect(snippets.length, equals(2));
      expect(snippets[0].text, equals('Hello, world!'));
      expect(snippets[0].start, equals(0.0));
      expect(snippets[0].duration, equals(2.5));
      expect(snippets[1].text, equals('This is a test.'));
      expect(snippets[1].start, equals(2.5));
      expect(snippets[1].duration, equals(3.0));
    });

    test('decodes HTML entities', () {
      const xmlContent = '''
        <transcript>
          <text start="0.0" dur="1.0">Hello &amp; goodbye</text>
          <text start="1.0" dur="1.0">Test &#39;quote&#39;</text>
          <text start="2.0" dur="1.0">&quot;double&quot;</text>
        </transcript>
      ''';

      final snippets = TranscriptParser.parseXml(xmlContent);

      expect(snippets[0].text, equals('Hello & goodbye'));
      expect(snippets[1].text, equals("Test 'quote'"));
      expect(snippets[2].text, equals('"double"'));
    });

    test('strips formatting when not preserving', () {
      const xmlContent = '''
        <transcript>
          <text start="0.0" dur="1.0"><b>Bold</b> text</text>
        </transcript>
      ''';

      final snippets = TranscriptParser.parseXml(
        xmlContent,
        preserveFormatting: false,
      );

      expect(snippets[0].text, equals('Bold text'));
    });

    test('preserves formatting when requested', () {
      const xmlContent = '''
        <transcript>
          <text start="0.0" dur="1.0">Bold text here</text>
        </transcript>
      ''';

      final snippets = TranscriptParser.parseXml(
        xmlContent,
        preserveFormatting: true,
      );

      expect(snippets[0].text, equals('Bold text here'));
      expect(snippets.length, equals(1));
    });

    test('handles missing duration attribute', () {
      const xmlContent = '''
        <transcript>
          <text start="0.0">No duration</text>
        </transcript>
      ''';

      final snippets = TranscriptParser.parseXml(xmlContent);

      expect(snippets.length, equals(1));
      expect(snippets[0].duration, equals(0.0));
    });

    test('skips elements without start attribute', () {
      const xmlContent = '''
        <transcript>
          <text dur="1.0">No start time</text>
          <text start="1.0" dur="1.0">Has start time</text>
        </transcript>
      ''';

      final snippets = TranscriptParser.parseXml(xmlContent);

      expect(snippets.length, equals(1));
      expect(snippets[0].text, equals('Has start time'));
    });
  });
}
