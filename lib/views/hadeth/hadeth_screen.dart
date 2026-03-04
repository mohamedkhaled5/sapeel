import 'dart:async';
import 'package:flutter/material.dart';
import 'data/models/common_models.dart';
import 'data/models/hadith_models.dart';
import 'data/repositories/hadith_repository.dart';

class HadeethScreen extends StatefulWidget {
  const HadeethScreen({super.key});

  @override
  State<HadeethScreen> createState() => _HadeethScreenState();
}

class _HadeethScreenState extends State<HadeethScreen> {
  final TextEditingController _searchController = TextEditingController();
  final HadithRepository _repository = HadithRepository();
  final ScrollController _scrollController = ScrollController();

  List<APIHadithItem> _results = [];
  Metadata? _metadata;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  Timer? _debounce;
  String _lastSearchQuery = '';
  String _selectedCategory = 'الصلاة';

  final List<String> _categories = [
    'الصلاة',
    'الزكاة',
    'الصوم',
    'الحج',
    'الأدب',
    'الجهاد',
    'الفتن',
    'القيامة',
    'الجنة',
    'النار',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // جلب أحاديث افتراضية عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNewSearch(_selectedCategory);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _metadata?.hasNextPage == true) {
      _loadMore();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      final trimmed = query.trim();
      if (trimmed.length >= 2 && trimmed != _lastSearchQuery) {
        _startNewSearch(trimmed);
      } else if (trimmed.isEmpty) {
        setState(() {
          _results = [];
          _metadata = null;
          _lastSearchQuery = '';
        });
      }
    });
  }

  Future<void> _startNewSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _results = [];
      _currentPage = 1;
      _errorMessage = null;
      _lastSearchQuery = query;
    });

    try {
      final response = await _repository.searchApiHadith(
        value: query,
        page: _currentPage,
      );
      if (mounted) {
        setState(() {
          _results = response.data;
          _metadata = response.metadata;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e
              .toString()
              .replaceFirst('Exception: ', '')
              .replaceFirst('DorarApiException: ', '');
        });
      }
    }
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _searchController.text = ''; // مسح نص البحث عند اختيار تصنيف
    });
    _startNewSearch(category);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _metadata?.hasNextPage != true) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await _repository.searchApiHadith(
        value: _lastSearchQuery,
        page: nextPage,
      );

      if (mounted) {
        setState(() {
          _currentPage = nextPage;
          _results.addAll(response.data);
          _metadata = response.metadata;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الموسوعة الحديثية (Clean Arch)'),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: (v) => _startNewSearch(v.trim()),
                decoration: InputDecoration(
                  hintText: 'ابحث عن حديث (مثال: الصلاة)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // عرض التصنيفات بشكل أفقي
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) => _onCategorySelected(category),
                        selectedColor: Colors.green[100],
                        checkmarkColor: Colors.green[800],
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.green[800]
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const LinearProgressIndicator(color: Colors.green)
              else if (_errorMessage != null)
                _buildErrorState()
              else
                Expanded(child: _buildHadethList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _startNewSearch(_lastSearchQuery),
          child: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }

  Widget _buildHadethList() {
    if (_results.isEmpty && _lastSearchQuery.isNotEmpty && !_isLoading) {
      return const Center(child: Text('لا توجد نتائج مطابقة لبحثك'));
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: _results.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _results.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildHadethCard(_results[index]);
      },
    );
  }

  Widget _buildHadethCard(APIHadithItem item) {
    final isSahih = item.grade.contains('صحيح') || item.grade.contains('حسن');
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isSahih ? Colors.green[200]! : Colors.red[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.hadith,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.6,
                color: Colors.green[900],
                fontFamily: 'Amiri',
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.person, 'الراوي', item.rawi),
            _buildInfoRow(Icons.history_edu, 'المحدث', item.mohdith),
            _buildInfoRow(Icons.book, 'المصدر', item.book),
            _buildInfoRow(Icons.tag, 'رقم الصفحة', item.numberOrPage),
            const SizedBox(height: 12),
            _buildGradeBadge(item.grade, isSahih),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeBadge(String grade, bool isSahih) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSahih ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isSahih ? Icons.check_circle : Icons.error,
            size: 18,
            color: isSahih ? Colors.green[700] : Colors.red[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'الدرجة: $grade',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSahih ? Colors.green[800] : Colors.red[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
