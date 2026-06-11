import 'dart:async';

import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../widgets/cart_button.dart';
import '../../widgets/product_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _api = ApiClient.instance;

  List<Category> _categories = [];
  final List<Product> _products = [];
  String? _activeCategory;
  String _search = '';
  int _page = 1;
  int _lastPage = 1;
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final res = await _api.dio.get('/categories');
      setState(() {
        _categories = (res.data['data'] as List).map((e) => Category.fromJson(Map<String, dynamic>.from(e))).toList();
      });
    } catch (_) {}
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    if (reset) _page = 1;
    try {
      final res = await _api.dio.get('/products', queryParameters: {
        'page': _page,
        'per_page': 10,
        if (_search.isNotEmpty) 'search': _search,
        if (_activeCategory != null) 'category': _activeCategory,
      });
      final list = (res.data['data'] as List).map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
      _lastPage = res.data['meta']?['last_page'] ?? 1;
      setState(() {
        if (reset) _products.clear();
        _products.addAll(list);
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _search = v;
      _loadProducts(reset: true);
    });
  }

  void _selectCategory(String? slug) {
    setState(() => _activeCategory = slug);
    _loadProducts(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Sparepart'),
        actions: const [CartButton(), SizedBox(width: 4)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: _onSearch,
              decoration: const InputDecoration(
                hintText: 'Cari sparepart...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('Semua', _activeCategory == null, () => _selectCategory(null)),
                ..._categories.map((c) => _chip(c.name, _activeCategory == c.slug, () => _selectCategory(c.slug))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _products.isEmpty && _loading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(child: Text('Produk tidak ditemukan', style: TextStyle(color: AppColors.muted)))
                    : RefreshIndicator(
                        onRefresh: () => _loadProducts(reset: true),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.62,
                          ),
                          itemCount: _products.length + (_page < _lastPage ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i >= _products.length) {
                              return Center(
                                child: TextButton(
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          _page++;
                                          _loadProducts();
                                        },
                                  child: _loading ? const CircularProgressIndicator() : const Text('Muat lebih banyak'),
                                ),
                              );
                            }
                            return ProductCard(product: _products[i]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: active ? Colors.white : AppColors.ink, fontSize: 13),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
