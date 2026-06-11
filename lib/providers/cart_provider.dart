import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class CartLine {
  final int productId;
  final String name;
  final double price;
  final String? image;
  final int stock;
  int qty;

  CartLine({
    required this.productId,
    required this.name,
    required this.price,
    this.image,
    required this.stock,
    this.qty = 1,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'price': price,
        'image': image,
        'stock': stock,
        'qty': qty,
      };

  factory CartLine.fromJson(Map<String, dynamic> j) => CartLine(
        productId: j['product_id'],
        name: j['name'],
        price: (j['price'] as num).toDouble(),
        image: j['image'],
        stock: j['stock'],
        qty: j['qty'],
      );
}

class CartProvider extends ChangeNotifier {
  final List<CartLine> _items = [];
  List<CartLine> get items => _items;

  int get count => _items.fold(0, (s, i) => s + i.qty);
  double get subtotal => _items.fold(0.0, (s, i) => s + i.price * i.qty);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cart');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _items
          ..clear()
          ..addAll(list.map((e) => CartLine.fromJson(Map<String, dynamic>.from(e))));
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  void add(Product p, {int qty = 1}) {
    final existing = _items.where((i) => i.productId == p.id).firstOrNull;
    if (existing != null) {
      existing.qty = (existing.qty + qty).clamp(1, p.stock);
    } else {
      _items.add(CartLine(
        productId: p.id,
        name: p.name,
        price: p.price,
        image: p.image,
        stock: p.stock,
        qty: qty.clamp(1, p.stock),
      ));
    }
    _persist();
    notifyListeners();
  }

  void setQty(int productId, int qty) {
    final item = _items.where((i) => i.productId == productId).firstOrNull;
    if (item == null) return;
    item.qty = qty.clamp(1, item.stock);
    _persist();
    notifyListeners();
  }

  void remove(int productId) {
    _items.removeWhere((i) => i.productId == productId);
    _persist();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _persist();
    notifyListeners();
  }
}
