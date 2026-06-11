import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/network_img.dart';
import '../../widgets/status_chip.dart';

class OrderDetailScreen extends StatefulWidget {
  final String code;
  const OrderDetailScreen({super.key, required this.code});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _api = ApiClient.instance;
  Order? _order;
  bool _loading = true;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.dio.get('/orders/${widget.code}');
      setState(() {
        _order = Order.fromJson(Map<String, dynamic>.from(res.data['data']));
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _payOnline() async {
    setState(() => _paying = true);
    try {
      final res = await _api.dio.post('/orders/${widget.code}/pay');
      final url = res.data['redirect_url'] as String;
      final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak bisa membuka halaman pembayaran.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiClient.errorMessage(e))));
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text('Pesanan yang dibatalkan tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Batalkan')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.dio.post('/orders/${widget.code}/cancel');
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiClient.errorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = _order;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : o == null
              ? const Center(child: Text('Pesanan tidak ditemukan'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(o.orderCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                        StatusChip(status: o.status),
                        const SizedBox(width: 6),
                        StatusChip(status: o.paymentStatus),
                      ],
                    ),
                    Text(fmtDateTime(o.createdAt), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    if (o.paymentStatus == 'unpaid' && o.paymentMethod == 'transfer' && o.status != 'cancelled') ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text('Menunggu pembayaran. Transfer ${rupiah(o.total)} lalu konfirmasi ke admin via WhatsApp.',
                            style: const TextStyle(color: AppColors.accent, fontSize: 13)),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text('Item', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...o.items.map((it) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              NetworkImg(url: it.image, width: 48, height: 48, radius: 8),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(it.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text('${rupiah(it.price)} × ${it.qty}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text(rupiah(it.subtotal), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        )),
                    const Divider(height: 24),
                    _row('Pengambilan', o.fulfillment == 'pickup' ? 'Ambil di Bengkel' : 'Diantar'),
                    if (o.shippingAddress != null) _row('Alamat', o.shippingAddress!),
                    _row('Pembayaran', o.paymentMethod == 'cash' ? 'Bayar di Tempat' : 'Transfer Bank'),
                    const Divider(height: 24),
                    _row('Subtotal', rupiah(o.subtotal)),
                    _row('Ongkir', rupiah(o.shippingCost)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(rupiah(o.total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryDark)),
                      ],
                    ),
                    if (o.paymentStatus == 'unpaid' && o.status != 'cancelled') ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _paying ? null : _payOnline,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                          icon: _paying
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Icon(Icons.credit_card),
                          label: Text(_paying ? 'Memproses...' : 'Bayar Online'),
                        ),
                      ),
                    ],
                    if (o.status == 'pending') ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _cancel,
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Batalkan Pesanan'),
                      ),
                    ],
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
          SizedBox(width: 110, child: Text(k, style: const TextStyle(color: AppColors.muted, fontSize: 13))),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 13), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
