class WordMeaning {
  final String word;
  final String meaning;

  WordMeaning({required this.word, required this.meaning});

  factory WordMeaning.fromJson(Map<String, dynamic> json) {
    return WordMeaning(word: json['word'], meaning: json['meaning']);
  }
}
