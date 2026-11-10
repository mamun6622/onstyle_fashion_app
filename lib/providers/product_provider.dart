import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/supabase_service.dart';

enum SortOption { newest, priceLowToHigh, priceHighToLow, rating }

class ProductProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Product> _products = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  SortOption _sortOption = SortOption.newest;
  bool _isLoading = false;
  final Set<String> _favoriteProductIds = {};

  List<Product> get products => _products;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;
  Set<String> get favoriteProductIds => _favoriteProductIds;

  static const List<String> categories = [
    'All',
    'Tops',
    'Dresses',
    'Outerwear',
    'Pants & Skirts',
    'Shoes',
    'Accessories',
  ];

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await _supabaseService.getProducts();

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  void toggleFavorite(String productId) {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    notifyListeners();
  }

  List<Product> get filteredProducts {
    List<Product> list = List.from(_products);

    // Category filter
    if (_selectedCategory != 'All') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    // Search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      }).toList();
    }

    // Sorting
    switch (_sortOption) {
      case SortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return list;
  }

  Future<void> updateStock(String productId, int newStock) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final updated = _products[idx].copyWith(stock: newStock < 0 ? 0 : newStock);
      _products[idx] = updated;
      notifyListeners();
      await _supabaseService.updateProduct(updated);
    }
  }

  /// Deduct stock when an order is successfully placed
  Future<void> deductStockForCart(List<CartItem> cartItems) async {
    for (final item in cartItems) {
      final idx = _products.indexWhere((p) => p.id == item.product.id);
      if (idx != -1) {
        final currentStock = _products[idx].stock;
        final newStock = currentStock - item.quantity;
        final updated = _products[idx].copyWith(
          stock: newStock < 0 ? 0 : newStock,
        );
        _products[idx] = updated;
        await _supabaseService.updateProduct(updated);
      }
    }
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    final newProduct = await _supabaseService.addProduct(product);
    _products.insert(0, newProduct);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    final updated = await _supabaseService.updateProduct(product);
    final idx = _products.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _products[idx] = updated;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    await _supabaseService.deleteProduct(productId);
    _products.removeWhere((p) => p.id == productId);

    _isLoading = false;
    notifyListeners();
  }
}
