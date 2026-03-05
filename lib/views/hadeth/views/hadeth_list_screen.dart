import 'package:flutter/material.dart';
import 'package:sapeel/views/hadeth/data/models/hadeeth_list_item.dart';
import 'package:sapeel/views/hadeth/data/services/hadeeth_api_service.dart';

class HadethListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const HadethListScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<HadethListScreen> createState() => _HadethListScreenState();
}

class _HadethListScreenState extends State<HadethListScreen> {
  final HadeethApiService _apiService = HadeethApiService();
  late Future<List<HadeethListItem>> futureHadeeths;
  List<HadeethListItem> _allHadeeths = [];
  List<HadeethListItem> _filteredHadeeths = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadHadeeths();
  }

  void _loadHadeeths() {
    futureHadeeths = _apiService
        .fetchHadeethList(language: "ar", categoryId: widget.categoryId)
        .then((hadeeths) {
          setState(() {
            _allHadeeths = hadeeths;
            _filteredHadeeths = hadeeths;
          });
          return hadeeths;
        });
  }

  void _filterHadeeths(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHadeeths = _allHadeeths;
      } else {
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
                  hintText: "بحث في الأحاديث...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                onChanged: _filterHadeeths,
              )
            : Text(widget.categoryTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _filteredHadeeths = _allHadeeths;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HadeethListItem>>(
        future: futureHadeeths,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _allHadeeths.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && _allHadeeths.isEmpty) {
            return Center(child: Text("حدث خطأ: ${snapshot.error}"));
          }

          if (_allHadeeths.isEmpty && !snapshot.hasData) {
            return const Center(child: Text("لا توجد أحاديث"));
          }

          if (_filteredHadeeths.isEmpty && _isSearching) {
            return const Center(child: Text("لا توجد نتائج للبحث"));
          }

          return ListView.builder(
            itemCount: _filteredHadeeths.length,
            itemBuilder: (context, index) {
              final hadeeth = _filteredHadeeths[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              );
            },
          );
        },
      ),
    );
  }
}
