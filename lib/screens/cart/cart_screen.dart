import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/network_img.dart';
import '../auth/login_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      if (ok != true || !context.mounted) return;
    }
    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.muted),
                  SizedBox(height: 12),
                  Text('Keranjang masih kosong', style: TextStyle(color: AppColors.muted)),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          NetworkImg(url: item.image, width: 64, height: 64, radius: 10),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(rupiah(item.price), style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _stepBtn(Icons.remove, () => cart.setQty(item.productId, item.qty - 1)),
                                    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.w700))),
                                    _stepBtn(Icons.add, () => cart.setQty(item.productId, item.qty + 1)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                            onPressed: () => cart.remove(item.productId),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                          Text(rupiah(cart.subtotal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => _checkout(context),
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
