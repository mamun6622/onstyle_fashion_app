class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final String imageUrl;
  final double rating;
  final List<String> sizes;
  final List<String> colors;
  final bool isPopular;
  final int stock;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.imageUrl,
    this.rating = 4.5,
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.colors = const ['Black', 'White', 'Beige'],
    this.isPopular = false,
    this.stock = 15,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= 5;

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).roundToDouble();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'category': category,
      'image_url': imageUrl,
      'rating': rating,
      'sizes': sizes,
      'colors': colors,
      'is_popular': isPopular,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['original_price'] as num?)?.toDouble(),
      category: map['category']?.toString() ?? 'Tops',
      imageUrl: map['image_url']?.toString() ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      sizes: (map['sizes'] as List?)?.map((e) => e.toString()).toList() ??
          ['S', 'M', 'L', 'XL'],
      colors: (map['colors'] as List?)?.map((e) => e.toString()).toList() ??
          ['Black', 'White', 'Beige'],
      isPopular: map['is_popular'] == true,
      stock: (map['stock'] as num?)?.toInt() ?? 15,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    String? imageUrl,
    double? rating,
    List<String>? sizes,
    List<String>? colors,
    bool? isPopular,
    int? stock,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      isPopular: isPopular ?? this.isPopular,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
