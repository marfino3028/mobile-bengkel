import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/cart_button.dart';
import '../../widgets/network_img.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _api = ApiClient.instance;
  Product? _product;
  bool _loading = true;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.dio.get('/products/${widget.slug}');
      setState(() {
        _product = Product.fromJson(Map<String, dynamic>.from(res.data['data']));
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _product;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: const [CartButton(), SizedBox(width: 4)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : p == null
              ? const Center(child: Text('Produk tidak ditemukan'))
              : ListView(
                  children: [
                    AspectRatio(aspectRatio: 1, child: NetworkImg(url: p.image, fit: BoxFit.cover)),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.brand != null)
                            Text(p.brand!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.25)),
                          const SizedBox(height: 8),
                          Text(rupiah(p.price), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(p.inStock ? Icons.check_circle : Icons.cancel, size: 16, color: p.inStock ? AppColors.success : AppColors.danger),
                              const SizedBox(width: 4),
                              Text(p.inStock ? 'Stok tersedia (${p.stock})' : 'Stok habis',
                                  style: TextStyle(color: p.inStock ? AppColors.success : AppColors.danger, fontSize: 13)),
                            ],
                          ),
                          const Divider(height: 32),
                          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(p.description ?? '-', style: const TextStyle(color: AppColors.muted, height: 1.5)),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: p == null || !p.inStock
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    _qtyStepper(p),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<CartProvider>().add(p, qty: _qty);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                        },
                        icon: const Icon(Icons.shopping_cart, size: 18),
                        label: const Text('Tambah ke Keranjang'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _qtyStepper(Product p) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(onPressed: () => setState(() => _qty = (_qty - 1).clamp(1, p.stock)), icon: const Icon(Icons.remove, size: 18)),
          Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w700)),
          IconButton(onPressed: () => setState(() => _qty = (_qty + 1).clamp(1, p.stock)), icon: const Icon(Icons.add, size: 18)),
        ],
      ),
    );
  }
}
