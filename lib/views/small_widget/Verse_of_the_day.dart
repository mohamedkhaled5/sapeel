import 'package:flutter/material.dart';

Widget buildVerseOfTheDay(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Card(
      color: const Color(0xFFF9F9F9),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Indeed, with hardship [will be] ease.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Surah Ash-Sharh 94:6',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share, size: 20),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border, size: 20),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
