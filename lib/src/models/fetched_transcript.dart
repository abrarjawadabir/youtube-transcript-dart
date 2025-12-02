import 'dart:collection';
import 'transcript_snippet.dart';

/// Represents a fetched transcript with all its snippets.
///
/// This class implements [Iterable] to allow easy iteration over snippets.
/// Example:
/// ```dart
/// for (var snippet in transcript) {
///   print('${snippet.start}: ${snippet.text}');
/// }
/// ```
class FetchedTranscript extends IterableBase<TranscriptSnippet> {
  /// The YouTube video ID.
  final String videoId;

  /// The language of this transcript.
  final String language;

  /// The language code (e.g., 'en', 'de').
  final String languageCode;

  /// Whether this is an auto-generated transcript.
  final bool isGenerated;

  /// Whether this is a translated transcript.
  final bool isTranslated;

  /// The list of transcript snippets.
  final List<TranscriptSnippet> snippets;

  FetchedTranscript({
    required this.videoId,
    required this.language,
    required this.languageCode,
    required this.isGenerated,
    required this.isTranslated,
    required this.snippets,
  });

  @override
  Iterator<TranscriptSnippet> get iterator => snippets.iterator;

  /// Returns the raw data as a list of maps.
  ///
  /// Each map contains 'text', 'start', and 'duration' keys.
  List<Map<String, dynamic>> toRawData() {
    return snippets.map((s) => s.toJson()).toList();
  }

  @override
  String toString() {
    return 'FetchedTranscript(videoId: $videoId, language: $language, '
        'languageCode: $languageCode, isGenerated: $isGenerated, '
        'isTranslated: $isTranslated, snippets: ${snippets.length})';
  }
}
