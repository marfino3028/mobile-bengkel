double _toD(dynamic v) => v == null ? 0 : (v as num).toDouble();
int _toI(dynamic v) => v == null ? 0 : (v as num).toInt();

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? avatar;

  User({required this.id, required this.name, required this.email, this.phone, required this.role, this.avatar});

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: _toI(j['id']),
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        phone: j['phone'],
        role: j['role'] ?? 'customer',
        avatar: j['avatar'],
      );
}

class Category {
  final int id;
  final String name;
  final String slug;
  final int productsCount;

  Category({required this.id, required this.name, required this.slug, this.productsCount = 0});

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: _toI(j['id']),
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
        productsCount: _toI(j['products_count']),
      );
}

class Product {
  final int id;
  final String name;
  final String slug;
  final String? brand;
  final String? description;
  final double price;
  final int stock;
  final bool inStock;
  final String? image;
  final Category? category;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.brand,
    this.description,
    required this.price,
    required this.stock,
    required this.inStock,
    this.image,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: _toI(j['id']),
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
        brand: j['brand'],
        description: j['description'],
        price: _toD(j['price']),
        stock: _toI(j['stock']),
        inStock: j['in_stock'] ?? (_toI(j['stock']) > 0),
        image: j['image'],
        category: j['category'] is Map ? Category.fromJson(Map<String, dynamic>.from(j['category'])) : null,
      );
}

class Service {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final int? durationMinutes;
  final String? image;

  Service({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.durationMinutes,
    this.image,
  });

  factory Service.fromJson(Map<String, dynamic> j) => Service(
        id: _toI(j['id']),
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
        description: j['description'],
        price: _toD(j['price']),
        durationMinutes: j['duration_minutes'] == null ? null : _toI(j['duration_minutes']),
        image: j['image'],
      );
}

class PromoBanner {
  final int id;
  final String title;
  final String? subtitle;
  final String image;

  PromoBanner({required this.id, required this.title, this.subtitle, required this.image});

  factory PromoBanner.fromJson(Map<String, dynamic> j) => PromoBanner(
        id: _toI(j['id']),
        title: j['title'] ?? '',
        subtitle: j['subtitle'],
        image: j['image'] ?? '',
      );
}

class BookingItem {
  final int id;
  final String itemType;
  final String name;
  final double price;
  final int qty;
  final double subtotal;

  BookingItem({required this.id, required this.itemType, required this.name, required this.price, required this.qty, required this.subtotal});

  factory BookingItem.fromJson(Map<String, dynamic> j) => BookingItem(
        id: _toI(j['id']),
        itemType: j['item_type'] ?? 'service',
        name: j['name'] ?? '',
        price: _toD(j['price']),
        qty: _toI(j['qty']),
        subtotal: _toD(j['subtotal']),
      );
}

class Booking {
  final int id;
  final String bookingCode;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehiclePlate;
  final String? vehicleYear;
  final String scheduledAt;
  final String complaint;
  final String? adminNotes;
  final String status;
  final double serviceTotal;
  final double partsTotal;
  final double grandTotal;
  final String paymentStatus;
  final String createdAt;
  final List<BookingItem> items;

  Booking({
    required this.id,
    required this.bookingCode,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehiclePlate,
    this.vehicleYear,
    required this.scheduledAt,
    required this.complaint,
    this.adminNotes,
    required this.status,
    required this.serviceTotal,
    required this.partsTotal,
    required this.grandTotal,
    required this.paymentStatus,
    required this.createdAt,
    required this.items,
  });

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: _toI(j['id']),
        bookingCode: j['booking_code'] ?? '',
        vehicleBrand: j['vehicle_brand'] ?? '',
        vehicleModel: j['vehicle_model'] ?? '',
        vehiclePlate: j['vehicle_plate'] ?? '',
        vehicleYear: j['vehicle_year'],
        scheduledAt: j['scheduled_at'] ?? '',
        complaint: j['complaint'] ?? '',
        adminNotes: j['admin_notes'],
        status: j['status'] ?? 'pending',
        serviceTotal: _toD(j['service_total']),
        partsTotal: _toD(j['parts_total']),
        grandTotal: _toD(j['grand_total']),
        paymentStatus: j['payment_status'] ?? 'unpaid',
        createdAt: j['created_at'] ?? '',
        items: (j['items'] as List? ?? []).map((e) => BookingItem.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
}

class OrderItem {
  final int id;
  final String productName;
  final double price;
  final int qty;
  final double subtotal;
  final String? image;

  OrderItem({required this.id, required this.productName, required this.price, required this.qty, required this.subtotal, this.image});

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        id: _toI(j['id']),
        productName: j['product_name'] ?? '',
        price: _toD(j['price']),
        qty: _toI(j['qty']),
        subtotal: _toD(j['subtotal']),
        image: j['image'],
      );
}

class Order {
  final int id;
  final String orderCode;
  final String fulfillment;
  final String? shippingAddress;
  final double subtotal;
  final double shippingCost;
  final double total;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? notes;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderCode,
    required this.fulfillment,
    this.shippingAddress,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: _toI(j['id']),
        orderCode: j['order_code'] ?? '',
        fulfillment: j['fulfillment'] ?? 'pickup',
        shippingAddress: j['shipping_address'],
        subtotal: _toD(j['subtotal']),
        shippingCost: _toD(j['shipping_cost']),
        total: _toD(j['total']),
        status: j['status'] ?? 'pending',
        paymentStatus: j['payment_status'] ?? 'unpaid',
        paymentMethod: j['payment_method'],
        notes: j['notes'],
        createdAt: j['created_at'] ?? '',
        items: (j['items'] as List? ?? []).map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
}
