class MemorizationEngine {
  final int startPage;
  final int dayNumber;
  final int farBlockSize;
  final bool weeklyBreakEnabled;
  MemorizationEngine({
    required this.startPage,
    required this.dayNumber,
    required this.farBlockSize,
    required this.weeklyBreakEnabled,
  });

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

  // review from 1 page to 280 page two juz per day
  Map<String, int>? get farReview {
    if (nearReview == null) return null;

    final nearStart = nearReview!["start"]!;
    final farEnd = nearStart - 1;

    if (farEnd < startPage) return null;

    final totalFarPages = farEnd - startPage + 1;
    if (totalFarPages <= 0) return null;

    final blockSize = farBlockSize;
    final requiredDays = (totalFarPages / blockSize).ceil();

    final dayOfWeek = (dayNumber - 1) % 7;

    if (weeklyBreakEnabled) {
      // لو بدأنا أسبوع جديد
      if (dayOfWeek == 0) {
        // نبدأ دورة جديدة
      }

      // لو لسه جوه عدد أيام الدورة
      if (dayOfWeek < requiredDays) {
        final startOffset = dayOfWeek * blockSize;
        final dailyStart = startPage + startOffset;

        if (dailyStart > farEnd) return null;

        final dailyEnd = (dailyStart + blockSize - 1 > farEnd)
            ? farEnd
            : dailyStart + blockSize - 1;

        return {"start": dailyStart, "end": dailyEnd};
      }

      // باقي الأسبوع إجازة
      return null;
    }

    // النظام المستمر
    final cycleIndex = (dayNumber - 1) % requiredDays;

    final startOffset = cycleIndex * blockSize;
    final dailyStart = startPage + startOffset;

    final dailyEnd = (dailyStart + blockSize - 1 > farEnd)
        ? farEnd
        : dailyStart + blockSize - 1;

    return {"start": dailyStart, "end": dailyEnd};
  }

  // review from 281 page to 420 juz per day
  Map<String, int>? get farOverflowReview {
    if (nearReview == null) return null;

    final nearStart = nearReview!["start"]!;
    final overflowStart = 281; // يبدأ من بعد 280
    final overflowEnd = nearStart - 1;

    // لو لسه موصلناش 281
    if (overflowEnd < overflowStart) return null;

    final totalOverflowPages = overflowEnd - overflowStart + 1;
    if (totalOverflowPages <= 0) return null;

    const blockSize = 20; // ثابت 20

    final requiredDays = (totalOverflowPages / blockSize).ceil();
    final dayOfWeek = (dayNumber - 1) % 7;

    if (weeklyBreakEnabled) {
      if (dayOfWeek < requiredDays) {
        final startOffset = dayOfWeek * blockSize;
        final dailyStart = overflowStart + startOffset;

        if (dailyStart > overflowEnd) return null;

        final dailyEnd = (dailyStart + blockSize - 1 > overflowEnd)
            ? overflowEnd
            : dailyStart + blockSize - 1;

        return {"start": dailyStart, "end": dailyEnd};
      }

      return null;
    }

    // النظام المستمر
    final cycleIndex = (dayNumber - 1) % requiredDays;

    final startOffset = cycleIndex * blockSize;
    final dailyStart = overflowStart + startOffset;

    final dailyEnd = (dailyStart + blockSize - 1 > overflowEnd)
        ? overflowEnd
        : dailyStart + blockSize - 1;

    return {"start": dailyStart, "end": dailyEnd};
  }

  // review from 421 page to 560 juz per day
  Map<String, int>? get farSecondOverflowReview {
    if (nearReview == null) return null;

    final nearStart = nearReview!["start"]!;
    const secondOverflowStart = 421;
    const secondOverflowMax = 560;

    final calculatedEnd = nearStart - 1;

    // لو لسه موصلناش 421
    if (calculatedEnd < secondOverflowStart) return null;

    // أقصى حد 560
    final secondOverflowEnd = calculatedEnd > secondOverflowMax
        ? secondOverflowMax
        : calculatedEnd;

    final totalPages = secondOverflowEnd - secondOverflowStart + 1;

    if (totalPages <= 0) return null;

    const blockSize = 20; // ثابت

    final requiredDays = (totalPages / blockSize).ceil();
    final dayOfWeek = (dayNumber - 1) % 7;

    if (weeklyBreakEnabled) {
      if (dayOfWeek < requiredDays) {
        final startOffset = dayOfWeek * blockSize;
        final dailyStart = secondOverflowStart + startOffset;

        if (dailyStart > secondOverflowEnd) return null;

        final dailyEnd = (dailyStart + blockSize - 1 > secondOverflowEnd)
            ? secondOverflowEnd
            : dailyStart + blockSize - 1;

        return {"start": dailyStart, "end": dailyEnd};
      }

      return null;
    }

    // النظام المستمر
    final cycleIndex = (dayNumber - 1) % requiredDays;

    final startOffset = cycleIndex * blockSize;
    final dailyStart = secondOverflowStart + startOffset;

    final dailyEnd = (dailyStart + blockSize - 1 > secondOverflowEnd)
        ? secondOverflowEnd
        : dailyStart + blockSize - 1;

    return {"start": dailyStart, "end": dailyEnd};
  }
}
