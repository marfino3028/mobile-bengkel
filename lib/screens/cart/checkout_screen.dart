import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../utils/formatter.dart';
import '../activity/order_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _api = ApiClient.instance;
  String _fulfillment = 'pickup';
  String _payment = 'transfer';
  final _address = TextEditingController();
  final _notes = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cart = context.read<CartProvider>();
    if (_fulfillment == 'delivery' && _address.text.trim().isEmpty) {
      setState(() => _error = 'Alamat pengiriman wajib diisi.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.dio.post('/orders', data: {
        'items': cart.items.map((i) => {'product_id': i.productId, 'qty': i.qty}).toList(),
        'fulfillment': _fulfillment,
        'shipping_address': _fulfillment == 'delivery' ? _address.text.trim() : null,
        'payment_method': _payment,
        'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      });
      final code = res.data['data']['order_code'] as String;
      cart.clear();
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(code: code)));
    } catch (e) {
      setState(() => _error = ApiClient.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = context.read<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card('Data Pemesan', [
            Text(user?.name ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(user?.phone ?? user?.email ?? '', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ]),
          const SizedBox(height: 12),
          _card('Metode Pengambilan', [
            RadioGroup<String>(
              groupValue: _fulfillment,
              onChanged: (v) => setState(() => _fulfillment = v ?? 'pickup'),
              child: Column(
                children: [
                  _radioRow('pickup', 'Ambil di Bengkel', () => setState(() => _fulfillment = 'pickup')),
                  _radioRow('delivery', 'Diantar ke Alamat', () => setState(() => _fulfillment = 'delivery')),
                ],
              ),
            ),
            if (_fulfillment == 'delivery') ...[
              const SizedBox(height: 8),
              TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(hintText: 'Alamat lengkap...')),
            ],
          ]),
          const SizedBox(height: 12),
          _card('Metode Pembayaran', [
            RadioGroup<String>(
              groupValue: _payment,
              onChanged: (v) => setState(() => _payment = v ?? 'transfer'),
              child: Column(
                children: [
                  _radioRow('transfer', 'Transfer Bank', () => setState(() => _payment = 'transfer')),
                  _radioRow('cash', 'Bayar di Tempat', () => setState(() => _payment = 'cash')),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),
          _card('Catatan', [
            TextField(controller: _notes, decoration: const InputDecoration(hintText: 'Catatan (opsional)')),
          ]),
          const SizedBox(height: 12),
          _card('Ringkasan', [
            ...cart.items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: Text('${i.qty}× ${i.name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                      Text(rupiah(i.price * i.qty), style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                Text(rupiah(cart.subtotal), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDark, fontSize: 16)),
              ],
            ),
          ]),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('Buat Pesanan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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

  Widget _radioRow(String value, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Radio<String>(value: value),
          Text(label),
        ],
      ),
    );
  }
}
