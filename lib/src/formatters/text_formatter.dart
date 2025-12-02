import 'base_formatter.dart';
import '../models/fetched_transcript.dart';

/// Formats transcript as plain text.
///
/// Example output:
/// ```
/// Hello, world!
/// This is a transcript.
/// ```
class TextFormatter extends TranscriptFormatter {
  @override
  String format(FetchedTranscript transcript) {
    return transcript.snippets.map((s) => s.text).join('\n');
  }

  @override
  String get fileExtension => 'txt';

  @override
  String get mimeType => 'text/plain';
}

/// Formats transcript as plain text with timestamps.
///
/// Example output:
/// ```
/// [0.0] Hello, world!
/// [2.5] This is a transcript.
/// ```
class TextFormatterWithTimestamps extends TranscriptFormatter {
  @override
  String format(FetchedTranscript transcript) {
    return transcript.snippets.map((s) => '[${s.start}] ${s.text}').join('\n');
  }

  @override
  String get fileExtension => 'txt';

  @override
  String get mimeType => 'text/plain';
}
