import 'base_formatter.dart';
import '../models/fetched_transcript.dart';

/// Formats transcript as WebVTT (Web Video Text Tracks).
///
/// WebVTT is a standard format for displaying timed text tracks
/// (such as subtitles or captions) with HTML5 video.
///
/// Example output:
/// ```
/// WEBVTT
///
/// 00:00:00.000 --> 00:00:02.500
/// Hello, world!
///
/// 00:00:02.500 --> 00:00:05.500
/// This is a transcript.
/// ```
class VttFormatter extends TranscriptFormatter {
  @override
  String format(FetchedTranscript transcript) {
    final buffer = StringBuffer();
    buffer.writeln('WEBVTT');
    buffer.writeln();

    for (final snippet in transcript.snippets) {
      final startTime = _formatTimestamp(snippet.start);
      final endTime = _formatTimestamp(snippet.start + snippet.duration);

      buffer.writeln('$startTime --> $endTime');
      buffer.writeln(snippet.text);
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Formats a time in seconds to WebVTT timestamp format (HH:MM:SS.mmm).
  String _formatTimestamp(double seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    final secs = (seconds % 60).floor();
    final millis = ((seconds % 1) * 1000).floor();

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}.'
        '${millis.toString().padLeft(3, '0')}';
  }

  @override
  String get fileExtension => 'vtt';

  @override
  String get mimeType => 'text/vtt';
}
