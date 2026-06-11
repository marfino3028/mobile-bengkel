import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/status_chip.dart';

class BookingDetailScreen extends StatefulWidget {
  final String code;
  const BookingDetailScreen({super.key, required this.code});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final _api = ApiClient.instance;
  Booking? _booking;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.dio.get('/bookings/${widget.code}');
      setState(() {
        _booking = Booking.fromJson(Map<String, dynamic>.from(res.data['data']));
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Batalkan')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.dio.post('/bookings/${widget.code}/cancel');
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiClient.errorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = _booking;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Booking')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : b == null
              ? const Center(child: Text('Booking tidak ditemukan'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(b.bookingCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                        StatusChip(status: b.status),
                        const SizedBox(width: 6),
                        StatusChip(status: b.paymentStatus),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _section('Motor', [
                      _row('Kendaraan', '${b.vehicleBrand} ${b.vehicleModel}'),
                      _row('Plat', b.vehiclePlate),
                      if (b.vehicleYear != null) _row('Tahun', b.vehicleYear!),
                      _row('Jadwal', fmtDateTime(b.scheduledAt)),
                    ]),
                    const SizedBox(height: 12),
                    _section('Keluhan', [Text(b.complaint, style: const TextStyle(fontSize: 13))]),
                    if (b.adminNotes != null && b.adminNotes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _section('Catatan Bengkel', [Text(b.adminNotes!, style: const TextStyle(fontSize: 13))]),
                    ],
                    const SizedBox(height: 12),
                    _section('Rincian', [
                      ...b.items.map((it) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Expanded(child: Text('${it.name}${it.qty > 1 ? ' ×${it.qty}' : ''}', style: const TextStyle(fontSize: 13))),
                                Text(rupiah(it.subtotal), style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.w800)),
                          Text(rupiah(b.grandTotal), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                        ],
                      ),
                    ]),
                    if (b.status == 'pending') ...[
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: _cancel,
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Batalkan Booking'),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(k, style: const TextStyle(color: AppColors.muted, fontSize: 13))),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
