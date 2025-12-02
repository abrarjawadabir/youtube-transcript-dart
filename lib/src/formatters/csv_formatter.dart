import 'base_formatter.dart';
import '../models/fetched_transcript.dart';

/// Formats transcript as CSV (Comma-Separated Values).
///
/// Example output:
/// ```csv
/// start,duration,text
/// 0.0,2.5,"Hello, world!"
/// 2.5,3.0,"This is a transcript."
/// ```
class CsvFormatter extends TranscriptFormatter {
  final bool includeHeader;

  /// Creates a CSV formatter.
  ///
  /// [includeHeader] - If true, includes a header row with column names.
  CsvFormatter({this.includeHeader = true});

  @override
  String format(FetchedTranscript transcript) {
    final buffer = StringBuffer();

    if (includeHeader) {
      buffer.writeln('start,duration,text');
    }

    for (final snippet in transcript.snippets) {
      final escapedText = _escapeCsvField(snippet.text);
      buffer.writeln('${snippet.start},${snippet.duration},$escapedText');
    }

    return buffer.toString();
  }

  /// Escapes a CSV field by wrapping it in quotes if needed.
  String _escapeCsvField(String field) {
    // If the field contains comma, newline, or quote, wrap it in quotes
    if (field.contains(',') ||
        field.contains('\n') ||
        field.contains('"') ||
        field.contains('\r')) {
      // Escape quotes by doubling them
      final escaped = field.replaceAll('"', '""');
      return '"$escaped"';
    }
    return field;
  }

  @override
  String get fileExtension => 'csv';

  @override
  String get mimeType => 'text/csv';
}
