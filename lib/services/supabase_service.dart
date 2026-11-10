import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? get _client {
    try {
      if (SupabaseConfig.isInitialized) {
        return Supabase.instance.client;
      }
    } catch (_) {}
    return null;
  }

  // Initial mock products with stock quantities
  final List<Product> _mockProducts = [
    Product(
      id: 'prod_1',
      title: 'Oversized Beige Trench Coat',
      description:
          'A timeless double-breasted trench coat tailored in water-resistant cotton blend with storm flap and belt.',
      price: 149.99,
      originalPrice: 189.99,
      category: 'Outerwear',
      imageUrl:
          'https://images.unsplash.com/photo-1544441893-675973e31985?auto=format&fit=crop&q=80&w=600',
      rating: 4.8,
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Beige', 'Camel', 'Black'],
      isPopular: true,
      stock: 12,
    ),
    Product(
      id: 'prod_2',
      title: 'Silk Floral Midi Dress',
      description:
          'Elegant 100% Mulberry silk midi dress with delicate floral prints, long sleeves, and a flattering cinch waist.',
      price: 89.99,
      originalPrice: 119.99,
      category: 'Dresses',
      imageUrl:
          'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=format&fit=crop&q=80&w=600',
      rating: 4.7,
      sizes: ['XS', 'S', 'M', 'L'],
      colors: ['Navy Floral', 'Cream Floral', 'Emerald'],
      isPopular: true,
      stock: 4, // Low Stock example
    ),
    Product(
      id: 'prod_3',
      title: 'Vintage High-Waist Denim Jeans',
      description:
          'Classic 90s fit straight-leg jeans with high rise waist, durable cotton denim, and subtle distressing.',
      price: 69.99,
      originalPrice: 89.99,
      category: 'Pants & Skirts',
      imageUrl:
          'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&q=80&w=600',
      rating: 4.6,
      sizes: ['26', '28', '30', '32'],
      colors: ['Light Wash', 'Medium Blue', 'Black'],
      isPopular: true,
      stock: 25,
    ),
    Product(
      id: 'prod_4',
      title: 'Classic Leather Crossbody Bag',
      description:
          'Handcrafted genuine leather crossbody shoulder bag with brushed gold hardware and multiple storage compartments.',
      price: 119.50,
      originalPrice: 149.00,
      category: 'Accessories',
      imageUrl:
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&q=80&w=600',
      rating: 4.9,
      sizes: ['One Size'],
      colors: ['Tan', 'Black', 'Burgundy'],
      isPopular: true,
      stock: 0, // Out of Stock example
    ),
    Product(
      id: 'prod_5',
      title: 'Minimalist Leather White Sneakers',
      description:
          'Ultra-comfortable low-top minimalist sneakers made with soft nappa leather and cushioned memory foam soles.',
      price: 79.00,
      originalPrice: 99.00,
      category: 'Shoes',
      imageUrl:
          'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?auto=format&fit=crop&q=80&w=600',
      rating: 4.7,
      sizes: ['37', '38', '39', '40', '41'],
      colors: ['White', 'Off-White', 'White/Gold'],
      isPopular: false,
      stock: 18,
    ),
    Product(
      id: 'prod_6',
      title: 'Cashmere Ribbed Knit Sweater',
      description:
          'Luxurious pure Mongolian cashmere crewneck sweater featuring soft ribbed cuffs and hem.',
      price: 110.00,
      originalPrice: 135.00,
      category: 'Tops',
      imageUrl:
          'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?auto=format&fit=crop&q=80&w=600',
      rating: 4.8,
      sizes: ['S', 'M', 'L'],
      colors: ['Oatmeal', 'Heather Grey', 'Charcoal'],
      isPopular: false,
      stock: 8,
    ),
  ];

  // Pre-populated sample orders for Admin Order Management demo
  final List<OrderModel> _mockOrders = [
    OrderModel(
      id: 'ORD_1740001001',
      items: [],
      subtotal: 149.99,
      tax: 12.00,
      shipping: 0.0,
      totalAmount: 161.99,
      shippingAddress: 'Sophia Martinez, 742 Fashion Ave, NY 10001',
      phoneNumber: '+1 (555) 234-5678',
      customerEmail: 'sophia@example.com',
      paymentMethod: 'Credit / Debit Card',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'Processing',
    ),
    OrderModel(
      id: 'ORD_1740000850',
      items: [],
      subtotal: 69.99,
      tax: 5.60,
      shipping: 10.00,
      totalAmount: 85.59,
      shippingAddress: 'Alexander Wright, 104 Fifth Ave, NY 10011',
      phoneNumber: '+1 (555) 987-6543',
      customerEmail: 'alex@example.com',
      paymentMethod: 'Apple / Google Pay',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Shipped',
    ),
    OrderModel(
      id: 'ORD_1740000420',
      items: [],
      subtotal: 198.50,
      tax: 15.88,
      shipping: 0.0,
      totalAmount: 214.38,
      shippingAddress: 'Emma Watson, 50 Rockfeller Plaza, NY 10020',
      phoneNumber: '+1 (555) 456-7890',
      customerEmail: 'emma@example.com',
      paymentMethod: 'Cash on Delivery',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Delivered',
    ),
  ];

  /// Fetch products from Supabase database or local list
  Future<List<Product>> getProducts() async {
    final client = _client;
    if (client != null) {
      try {
        final response = await client
            .from('products')
            .select()
            .order('created_at', ascending: false);
        final List data = response as List;
        if (data.isNotEmpty) {
          return data.map((json) => Product.fromMap(json)).toList();
        }
      } catch (_) {}
    }
    return List.from(_mockProducts);
  }

  /// Add a new product to Supabase
  Future<Product> addProduct(Product product) async {
    final client = _client;
    if (client != null) {
      try {
        await client.from('products').insert(product.toMap());
      } catch (_) {}
    }
    _mockProducts.insert(0, product);
    return product;
  }

  /// Update an existing product
  Future<Product> updateProduct(Product product) async {
    final client = _client;
    if (client != null) {
      try {
        await client
            .from('products')
            .update(product.toMap())
            .eq('id', product.id);
      } catch (_) {}
    }
    final index = _mockProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _mockProducts[index] = product;
    }
    return product;
  }

  /// Delete a product
  Future<bool> deleteProduct(String productId) async {
    final client = _client;
    if (client != null) {
      try {
        await client.from('products').delete().eq('id', productId);
      } catch (_) {}
    }
    _mockProducts.removeWhere((p) => p.id == productId);
    return true;
  }

  /// Fetch all customer orders for Admin Panel
  Future<List<OrderModel>> getOrders() async {
    final client = _client;
    if (client != null) {
      try {
        final response = await client
            .from('orders')
            .select()
            .order('created_at', ascending: false);
        final List data = response as List;
        if (data.isNotEmpty) {
          return data.map((json) => OrderModel.fromMap(json)).toList();
        }
      } catch (_) {}
    }
    return List.from(_mockOrders);
  }

  /// Create an order in Supabase
  Future<bool> createOrder(OrderModel order) async {
    final client = _client;
    if (client != null) {
      try {
        await client.from('orders').insert(order.toMap());
      } catch (_) {}
    }
    _mockOrders.insert(0, order);
    return true;
  }

  /// Update order status in Supabase database
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    final client = _client;
    if (client != null) {
      try {
        await client
            .from('orders')
            .update({'status': newStatus}).eq('id', orderId);
      } catch (_) {}
    }
    final idx = _mockOrders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _mockOrders[idx] = _mockOrders[idx].copyWith(status: newStatus);
    }
    return true;
  }
}
