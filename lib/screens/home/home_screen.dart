import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../widgets/cart_button.dart';
import '../../widgets/product_card.dart';
import '../../widgets/service_card.dart';
import '../booking/booking_form_screen.dart';
import '../catalog/catalog_screen.dart';
import '../services/services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiClient.instance;
  bool _loading = true;
  String? _error;

  List<PromoBanner> _banners = [];
  List<Service> _services = [];
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.dio.get('/banners'),
        _api.dio.get('/services', queryParameters: {'featured': 1}),
        _api.dio.get('/products', queryParameters: {'featured': 1, 'per_page': 6}),
      ]);
      _banners = (results[0].data['data'] as List).map((e) => PromoBanner.fromJson(Map<String, dynamic>.from(e))).toList();
      _services = (results[1].data['data'] as List).map((e) => Service.fromJson(Map<String, dynamic>.from(e))).toList();
      _products = (results[2].data['data'] as List).map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      _error = ApiClient.errorMessage(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.two_wheeler, color: AppColors.primary),
            SizedBox(width: 8),
            Text('BengkelKu', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: const [CartButton(), SizedBox(width: 4)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _hero(),
                      const SizedBox(height: 20),
                      _quickActions(),
                      const SizedBox(height: 24),
                      if (_services.isNotEmpty) ...[
                        _sectionHeader('Layanan Servis', () => _go(const ServicesScreen())),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 210,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _services.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (_, i) => SizedBox(
                              width: 260,
                              child: ServiceCard(
                                service: _services[i],
                                onTap: () => _go(const BookingFormScreen()),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      _sectionHeader('Produk Unggulan', () => _go(const CatalogScreen())),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (_, i) => ProductCard(product: _products[i]),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  void _go(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  Widget _hero() {
    final b = _banners.isNotEmpty ? _banners.first : null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            b?.title ?? 'Servis Motor Lebih Mudah',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            b?.subtitle ?? 'Booking online, datang, langsung dikerjakan.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _go(const BookingFormScreen()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
            icon: const Icon(Icons.calendar_month, size: 18),
            label: const Text('Booking Servis'),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _action(Icons.build_outlined, 'Booking\nServis', () => _go(const BookingFormScreen()))),
          const SizedBox(width: 12),
          Expanded(child: _action(Icons.shopping_bag_outlined, 'Beli\nSparepart', () => _go(const CatalogScreen()))),
          const SizedBox(width: 12),
          Expanded(child: _action(Icons.design_services_outlined, 'Lihat\nLayanan', () => _go(const ServicesScreen()))),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onMore) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          TextButton(onPressed: onMore, child: const Text('Lihat semua')),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
