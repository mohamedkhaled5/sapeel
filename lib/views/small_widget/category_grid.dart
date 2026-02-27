import 'package:flutter/material.dart';

Widget buildCategoryGrid(BuildContext context) {
  final categories = [
    {
      'title': 'القرآن الكريم',
      'icon': Icons.menu_book,
      'color': Colors.green,
      'route': '/al_quran',
    },
    {
      'title': 'الحديث',
      'icon': Icons.history_edu,
      'color': Colors.amber,
      'route': '/hadeth',
    },
    {
      'title': 'مواقيت الصلاة',
      'icon': Icons.access_time,
      'color': Colors.blue,
      'route': '/prayer_times',
    },
    {
      'title': 'الحصون الخمسه',
      'icon': Icons.five_g,
      'color': Colors.orange,
      'route': '/dua',
    },
    {
      'title': 'القبلة',
      'icon': Icons.explore,
      'color': Colors.red,
      'route': '/qibla',
    },
    {
      'title': 'المكتبه الإسلامية',
      'icon': Icons.library_books,
      'color': Colors.teal,
      'route': '/islamic_library',
    },
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, cat['route'] as String);
          },
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat['icon'] as IconData,
                  color: cat['color'] as Color,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  cat['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
