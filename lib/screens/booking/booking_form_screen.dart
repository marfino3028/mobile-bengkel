import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../utils/formatter.dart';
import '../activity/booking_detail_screen.dart';
import '../auth/login_screen.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _api = ApiClient.instance;
  List<Service> _services = [];
  final Set<int> _selected = {};
  bool _loadingServices = true;

  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _plate = TextEditingController();
  final _year = TextEditingController();
  final _complaint = TextEditingController();
  DateTime? _schedule;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _brand.dispose();
    _model.dispose();
    _plate.dispose();
    _year.dispose();
    _complaint.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      final res = await _api.dio.get('/services');
      setState(() {
        _services = (res.data['data'] as List).map((e) => Service.fromJson(Map<String, dynamic>.from(e))).toList();
        _loadingServices = false;
      });
    } catch (_) {
      setState(() => _loadingServices = false);
    }
  }

  double get _total => _services.where((s) => _selected.contains(s.id)).fold(0.0, (sum, s) => sum + s.price);

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (time == null) return;
    setState(() => _schedule = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_selected.isEmpty) {
      setState(() => _error = 'Pilih minimal satu layanan.');
      return;
    }
    if (_brand.text.isEmpty || _model.text.isEmpty || _plate.text.isEmpty || _schedule == null || _complaint.text.isEmpty) {
      setState(() => _error = 'Lengkapi semua data yang wajib diisi.');
      return;
    }

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      if (ok != true || !mounted) return;
    }

    setState(() => _submitting = true);
    try {
      final res = await _api.dio.post('/bookings', data: {
        'service_ids': _selected.toList(),
        'vehicle_brand': _brand.text.trim(),
        'vehicle_model': _model.text.trim(),
        'vehicle_plate': _plate.text.trim(),
        'vehicle_year': _year.text.trim().isEmpty ? null : _year.text.trim(),
        'scheduled_at': _schedule!.toIso8601String(),
        'complaint': _complaint.text.trim(),
      });
      final code = res.data['data']['booking_code'] as String;
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(code: code)));
    } catch (e) {
      setState(() => _error = ApiClient.errorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Servis')),
      body: _loadingServices
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('1. Pilih Layanan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                ..._services.map((s) => CheckboxListTile(
                      value: _selected.contains(s.id),
                      onChanged: (v) => setState(() => v == true ? _selected.add(s.id) : _selected.remove(s.id)),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(rupiah(s.price), style: const TextStyle(color: AppColors.primaryDark)),
                    )),
                const Divider(height: 28),
                const Text('2. Data Motor', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 10),
                TextField(controller: _brand, decoration: const InputDecoration(labelText: 'Merek *', hintText: 'Honda')),
                const SizedBox(height: 12),
                TextField(controller: _model, decoration: const InputDecoration(labelText: 'Tipe / Model *', hintText: 'Vario 125')),
                const SizedBox(height: 12),
                TextField(controller: _plate, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Plat Nomor *', hintText: 'B 1234 ABC')),
                const SizedBox(height: 12),
                TextField(controller: _year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tahun (opsional)')),
                const Divider(height: 28),
                const Text('3. Jadwal & Keluhan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickSchedule,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Tanggal & Jam *', suffixIcon: Icon(Icons.calendar_month)),
                    child: Text(_schedule == null ? 'Pilih jadwal' : fmtDateTime(_schedule!.toIso8601String()),
                        style: TextStyle(color: _schedule == null ? AppColors.muted : AppColors.ink)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: _complaint, maxLines: 3, decoration: const InputDecoration(labelText: 'Keluhan *', hintText: 'Ceritakan keluhan motormu...')),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Text('Estimasi Total', style: TextStyle(color: AppColors.muted)),
                      const Spacer(),
                      Text(rupiah(_total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('Kirim Booking'),
                  ),
                ),
              ],
            ),
    );
  }
}
