import 'base_formatter.dart';
import '../models/fetched_transcript.dart';

/// Formats transcript as SRT (SubRip Subtitle).
///
/// SRT is a popular subtitle format supported by most video players.
///
/// Example output:
/// ```
/// 1
/// 00:00:00,000 --> 00:00:02,500
/// Hello, world!
///
/// 2
/// 00:00:02,500 --> 00:00:05,500
/// This is a transcript.
/// ```
class SrtFormatter extends TranscriptFormatter {
  @override
  String format(FetchedTranscript transcript) {
    final buffer = StringBuffer();
    var index = 1;

    for (final snippet in transcript.snippets) {
      final startTime = _formatTimestamp(snippet.start);
      final endTime = _formatTimestamp(snippet.start + snippet.duration);

      buffer.writeln(index);
      buffer.writeln('$startTime --> $endTime');
      buffer.writeln(snippet.text);
      buffer.writeln();

      index++;
    }

    return buffer.toString();
  }

  /// Formats a time in seconds to SRT timestamp format (HH:MM:SS,mmm).
  String _formatTimestamp(double seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    final secs = (seconds % 60).floor();
    final millis = ((seconds % 1) * 1000).floor();

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')},'
        '${millis.toString().padLeft(3, '0')}';
  }

  @override
  String get fileExtension => 'srt';

  @override
  String get mimeType => 'application/x-subrip';
}
