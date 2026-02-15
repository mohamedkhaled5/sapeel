import 'package:flutter/material.dart';
import 'package:sapeel/views/screens/quran_screen.dart';
import 'package:sapeel/views/screens/surah_detail.dart';
import 'package:sapeel/views/small_widget/Verse_of_the_day.dart';
import 'package:sapeel/views/small_widget/build_header.dart';
import 'package:sapeel/views/small_widget/category_grid.dart';

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {'/al_quran': (context) => const QuranScreen()},

      // initialRoute: '/al_quran',
      onGenerateRoute: (settings) {
        if (settings.name == '/surah_detail') {
          final surahNumber = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => SurahDetailScreen(surahNumber: surahNumber),
          );
        }
        return null;
      },
      title: 'Sapeel - Quran & Islamic Sciences',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20), // Deep Green
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFFC69C6D), // Gold/Bronze accent
          surface: const Color(0xFFF5F5F5),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sapeel',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      drawer: const Drawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(context),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            buildCategoryGrid(context),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Verse of the Day',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            buildVerseOfTheDay(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Quran'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: const Color(0xFF1B5E20),
      ),
    );
  }
}
