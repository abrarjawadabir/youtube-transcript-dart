import '../models/fetched_transcript.dart';

/// Base class for transcript formatters.
///
/// Formatters convert a [FetchedTranscript] into various output formats
/// such as plain text, JSON, WebVTT, SRT, or CSV.
abstract class TranscriptFormatter {
  /// Formats the transcript into a string representation.
  String format(FetchedTranscript transcript);

  /// Returns the file extension for this format (e.g., 'txt', 'json').
  String get fileExtension;

  /// Returns the MIME type for this format.
  String get mimeType;
}
