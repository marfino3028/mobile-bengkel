import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/status_chip.dart';
import '../auth/login_screen.dart';
import 'booking_detail_screen.dart';
import 'order_detail_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aktivitas')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56, color: AppColors.muted),
                const SizedBox(height: 12),
                const Text('Masuk untuk melihat riwayat', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Booking & pesanan kamu akan tampil di sini.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Masuk / Daftar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aktivitas'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [Tab(text: 'Booking Servis'), Tab(text: 'Pesanan')],
          ),
        ),
        body: const TabBarView(children: [_BookingsTab(), _OrdersTab()]),
      ),
    );
  }
}

class _BookingsTab extends StatefulWidget {
  const _BookingsTab();
  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab> {
  final _api = ApiClient.instance;
  List<Booking> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.dio.get('/bookings');
      setState(() {
        _items = (res.data['data'] as List).map((e) => Booking.fromJson(Map<String, dynamic>.from(e))).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const _Empty(icon: Icons.event_busy, text: 'Belum ada booking');
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final b = _items[i];
          return _tile(
            code: b.bookingCode,
            subtitle: '${b.vehicleBrand} ${b.vehicleModel} · ${fmtDateTime(b.scheduledAt)}',
            total: b.grandTotal,
            status: b.status,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(code: b.bookingCode))),
          );
        },
      ),
    );
  }
}

class _OrdersTab extends StatefulWidget {
  const _OrdersTab();
  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  final _api = ApiClient.instance;
  List<Order> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.dio.get('/orders');
      setState(() {
        _items = (res.data['data'] as List).map((e) => Order.fromJson(Map<String, dynamic>.from(e))).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const _Empty(icon: Icons.shopping_bag_outlined, text: 'Belum ada pesanan');
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final o = _items[i];
          return _tile(
            code: o.orderCode,
            subtitle: '${o.items.length} item · ${fmtDateTime(o.createdAt)}',
            total: o.total,
            status: o.status,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(code: o.orderCode))),
          );
        },
      ),
    );
  }
}

Widget _tile({
  required String code,
  required String subtitle,
  required double total,
  required String status,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(code, style: const TextStyle(fontWeight: FontWeight.w700))),
                    StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(rupiah(total), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    ),
  );
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Empty({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 56, color: AppColors.muted),
        const SizedBox(height: 12),
        Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
      ],
    );
  }
}
