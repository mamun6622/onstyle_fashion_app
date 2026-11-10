import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/supabase_service.dart';

class OrderProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<OrderModel> _orders = [];
  String _statusFilter = 'All';
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  String get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;

  static const List<String> statusOptions = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  OrderProvider() {
    loadOrders();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    _orders = await _supabaseService.getOrders();

    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  List<OrderModel> get filteredOrders {
    if (_statusFilter == 'All') return _orders;
    return _orders.where((o) => o.status == _statusFilter).toList();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _supabaseService.updateOrderStatus(orderId, newStatus);
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void addOrderLocally(OrderModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}
