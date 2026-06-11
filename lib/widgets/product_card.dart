import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers/cart_provider.dart';
import '../screens/catalog/product_detail_screen.dart';
import '../theme.dart';
import '../utils/formatter.dart';
import 'network_img.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(slug: product.slug)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: NetworkImg(url: product.image, radius: 0, fit: BoxFit.cover),
                ),
                if (!product.inStock)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(999)),
                      child: const Text('Habis', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brand != null)
                    Text(product.brand!, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rupiah(product.price),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: product.inStock
                          ? () {
                              context.read<CartProvider>().add(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${product.name} ditambahkan'), duration: const Duration(milliseconds: 900)),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('+ Keranjang', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
