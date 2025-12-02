/// Represents a language to which a transcript can be translated.
class TranslationLanguage {
  /// The language code (e.g., 'en', 'de', 'fr').
  final String languageCode;

  /// The human-readable language name (e.g., 'English', 'German').
  final String languageName;

  const TranslationLanguage({
    required this.languageCode,
    required this.languageName,
  });

  @override
  String toString() {
    return 'TranslationLanguage($languageCode: $languageName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TranslationLanguage &&
        other.languageCode == languageCode &&
        other.languageName == languageName;
  }

  @override
  int get hashCode => Object.hash(languageCode, languageName);
}
