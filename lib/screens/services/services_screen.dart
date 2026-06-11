import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../widgets/service_card.dart';
import '../booking/booking_form_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _api = ApiClient.instance;
  List<Service> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.dio.get('/services');
      setState(() {
        _services = (res.data['data'] as List).map((e) => Service.fromJson(Map<String, dynamic>.from(e))).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layanan Servis')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingFormScreen())),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.calendar_month),
        label: const Text('Booking'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? const Center(child: Text('Belum ada layanan', style: TextStyle(color: AppColors.muted)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => ServiceCard(
                    service: _services[i],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingFormScreen())),
                  ),
                ),
    );
  }
}
