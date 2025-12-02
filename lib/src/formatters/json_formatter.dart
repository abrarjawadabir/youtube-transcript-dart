import 'dart:convert';
import 'base_formatter.dart';
import '../models/fetched_transcript.dart';

/// Formats transcript as JSON.
///
/// Example output:
/// ```json
/// [
///   {"text": "Hello, world!", "start": 0.0, "duration": 2.5},
///   {"text": "This is a transcript.", "start": 2.5, "duration": 3.0}
/// ]
/// ```
class JsonFormatter extends TranscriptFormatter {
  final bool pretty;

  /// Creates a JSON formatter.
  ///
  /// [pretty] - If true, outputs formatted JSON with indentation.
  JsonFormatter({this.pretty = false});

  @override
  String format(FetchedTranscript transcript) {
    final data = transcript.toRawData();
    if (pretty) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    }
    return json.encode(data);
  }

  @override
  String get fileExtension => 'json';

  @override
  String get mimeType => 'application/json';
}

/// Formats transcript as detailed JSON with metadata.
///
/// Includes video ID, language, and whether it's auto-generated.
class JsonFormatterWithMetadata extends TranscriptFormatter {
  final bool pretty;

  JsonFormatterWithMetadata({this.pretty = true});

  @override
  String format(FetchedTranscript transcript) {
    final data = {
      'videoId': transcript.videoId,
      'language': transcript.language,
      'languageCode': transcript.languageCode,
      'isGenerated': transcript.isGenerated,
      'isTranslated': transcript.isTranslated,
      'transcripts': transcript.toRawData(),
    };

    if (pretty) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    }
    return json.encode(data);
  }

  @override
  String get fileExtension => 'json';

  @override
  String get mimeType => 'application/json';
}
