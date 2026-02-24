class MemorizationEngine {
  final int startPage;
  final int dayNumber;

  MemorizationEngine({required this.startPage, required this.dayNumber});

  int get weekIndex => ((dayNumber - 1) ~/ 7);

  int? get newPage {
    if (dayNumber < 8) return null;
    return startPage + (dayNumber - 8);
  }

  int? get qabliy => newPage;

  int? get nightPrep {
    if (dayNumber < 7) return null;
    return startPage + (dayNumber - 7);
  }

  Map<String, int> get weeklyPrep {
    final start = startPage + (weekIndex * 7);
    return {"start": start, "end": start + 6};
  }

  Map<String, int>? get nearReview {
    if (newPage == null) return null;

    final start = (newPage! - 20 < startPage) ? startPage : newPage! - 20;

    return {"start": start, "end": newPage! - 1};
  }

  int get readingJuz => (((dayNumber - 1) * 2) % 30) + 1;

  int get listeningHizb => ((dayNumber - 1) % 60) + 1;
}
