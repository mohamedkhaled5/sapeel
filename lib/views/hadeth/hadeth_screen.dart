import 'package:flutter/material.dart';
import 'package:sapeel/views/hadeth/data/models/category_model.dart';
import 'package:sapeel/views/hadeth/data/services/hadeeth_api_service.dart';
import 'package:sapeel/views/hadeth/data/models/hadeeth_list_item.dart';

class HadeethScreen extends StatefulWidget {
  const HadeethScreen({super.key});

  @override
  State<HadeethScreen> createState() => _HadeethScreenState();
}

class _HadeethScreenState extends State<HadeethScreen> {
  final HadeethApiService _apiService = HadeethApiService();
  late Future<List<CategoryModel>> futureCategories;
  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _filteredCategories = [];

  // 🔍 Global Search Variables
  List<HadeethListItem> _allHadeeths = [];
  List<HadeethListItem> _filteredHadeeths = [];
  bool _isLoadingHadeeths = false;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    futureCategories = _apiService.fetchCategories("ar").then((categories) {
      setState(() {
        _allCategories = categories;
        _filteredCategories = categories;
      });
      _preloadAllHadeeths(categories);
      return categories;
    });
  }

  /// 🚀 Preload all hadeeths from all categories for global search
  Future<void> _preloadAllHadeeths(List<CategoryModel> categories) async {
    setState(() => _isLoadingHadeeths = true);
    try {
      // Fetch only from root categories to avoid too many requests
      final rootCategories = categories
          .where((c) => c.parentId == null)
          .toList();

      final List<Future<List<HadeethListItem>>> futures = rootCategories.map((
        category,
      ) {
        return _apiService.fetchHadeethList(
          language: "ar",
          categoryId: category.id,
        );
      }).toList();

      final List<List<HadeethListItem>> results = await Future.wait(futures);

      if (mounted) {
        setState(() {
          _allHadeeths = results.expand((x) => x).toList();
          _isLoadingHadeeths = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHadeeths = false);
      debugPrint("Error preloading hadeeths: $e");
    }
  }

  void _filterResults(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _allCategories;
        _filteredHadeeths = [];
      } else {
        // Filter Categories
        _filteredCategories = _allCategories
            .where(
              (category) =>
                  category.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

        // Filter Hadeeths (Global Search)
        _filteredHadeeths = _allHadeeths
            .where(
              (hadeeth) =>
                  hadeeth.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "بحث في الأقسام والأحاديث...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                onChanged: _filterResults,
              )
            : const Text("الأحاديث النبوية"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _filteredCategories = _allCategories;
                  _filteredHadeeths = [];
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CategoryModel>>(
        future: futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _allCategories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && _allCategories.isEmpty) {
            return Center(child: Text("حدث خطأ: ${snapshot.error}"));
          }

          if (_allCategories.isEmpty && !snapshot.hasData) {
            return const Center(child: Text("لا توجد بيانات"));
          }

          if (_isSearching &&
              _filteredCategories.isEmpty &&
              _filteredHadeeths.isEmpty) {
            return const Center(child: Text("لا توجد نتائج للبحث"));
          }

          return ListView(
            children: [
              // 📁 Sections (Categories)
              if (_filteredCategories.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "الأقسام",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._filteredCategories.map(
                  (category) => Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        category.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("عدد الأحاديث: ${category.hadeethCount}"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/hadeth_list',
                          arguments: {
                            'id': category.id,
                            'title': category.title,
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],

              // 📜 Hadeeths (Global Search Results)
              if (_isSearching && _filteredHadeeths.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "الأحاديث",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._filteredHadeeths.map(
                  (hadeeth) => Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        hadeeth.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/hadeth_detail',
                          arguments: hadeeth.id,
                        );
                      },
                    ),
                  ),
                ),
              ],

              if (_isSearching && _isLoadingHadeeths)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
