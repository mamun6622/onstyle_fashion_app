import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final _searchController = TextEditingController();
  List<OrderModel>? _searchResults;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchOrder(OrderProvider orderProvider) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    final results = orderProvider.orders.where((o) {
      final phone = o.phoneNumber.toLowerCase();
      final email = (o.customerEmail ?? '').toLowerCase();
      final orderId = o.id.toLowerCase();

      return phone.contains(query) ||
          email == query ||
          (query.length >= 4 && orderId.contains(query));
    }).toList();

    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Track Your Order',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: Colors.black87,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Find Order by Phone or Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter the phone number or email address used during checkout to view live order progress.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                keyboardType: TextInputType.text,
                                onSubmitted: (_) =>
                                    _searchOrder(orderProvider),
                                decoration: InputDecoration(
                                  hintText: 'e.g. +1 555-234-5678 or email',
                                  prefixIcon: const Icon(Icons.phone_iphone),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () => _searchOrder(orderProvider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'TRACK',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Results Header
                  if (_hasSearched) ...[
                    Text(
                      _searchResults!.isEmpty
                          ? 'No orders found for "${_searchController.text.trim()}"'
                          : 'Found ${_searchResults!.length} Order(s)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Orders Search Results List
                  Expanded(
                    child: !_hasSearched
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_shipping_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Enter your details above to track your order live.',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _searchResults!.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.find_in_page_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No matching orders found.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Double check your phone number or email.',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _searchResults!.length,
                                itemBuilder: (context, index) {
                                  return _buildTrackingCard(
                                    _searchResults![index],
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Placed on ${_formatDate(order.createdAt)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(order.status)),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Order Timeline Tracker
            _buildTimelineTracker(order.status),

            const Divider(height: 24),

            // Shipping Address & Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipping Address',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                      Text(
                        order.shippingAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Paid',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTracker(String status) {
    int currentStep = 0;
    if (status == 'Processing') currentStep = 1;
    if (status == 'Shipped') currentStep = 2;
    if (status == 'Delivered') currentStep = 3;

    if (status == 'Cancelled') {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red[800], size: 20),
            const SizedBox(width: 8),
            Text(
              'This order has been cancelled.',
              style: TextStyle(
                color: Colors.red[900],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        _buildTimelineNode('Ordered', currentStep >= 1, isFirst: true),
        _buildTimelineLine(currentStep >= 2),
        _buildTimelineNode('Shipped', currentStep >= 2),
        _buildTimelineLine(currentStep >= 3),
        _buildTimelineNode('Delivered', currentStep >= 3, isLast: true),
      ],
    );
  }

  Widget _buildTimelineNode(String label, bool isCompleted,
      {bool isFirst = false, bool isLast = false}) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor:
                isCompleted ? Colors.black : Colors.grey[300],
            child: Icon(
              isCompleted ? Icons.check : Icons.circle,
              size: 14,
              color: isCompleted ? Colors.white : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
              color: isCompleted ? Colors.black : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineLine(bool isCompleted) {
    return Container(
      width: 30,
      height: 2,
      color: isCompleted ? Colors.black : Colors.grey[300],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green[800]!;
      case 'Shipped':
        return Colors.blue[800]!;
      case 'Processing':
        return Colors.amber[900]!;
      case 'Cancelled':
        return Colors.red[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
