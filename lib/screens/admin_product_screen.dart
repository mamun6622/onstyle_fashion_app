import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../widgets/supabase_settings_dialog.dart';
import '../models/order.dart';
import 'admin_login_screen.dart';
import 'add_edit_product_screen.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminAuth = Provider.of<AdminAuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    // Check if user is logged in as Admin
    if (!adminAuth.isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Admin Authentication Required',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: const SafeArea(child: AdminLoginScreen()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Admin Control Panel',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.green[900],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text('Inventory & Stock (${productProvider.products.length})'),
                ],
              ),
            ),
            Tab(
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text('Orders (${orderProvider.orders.length})'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync, color: Colors.indigo),
            tooltip: 'Supabase Settings',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const SupabaseSettingsDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout Admin',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout Admin Session'),
                  content: const Text(
                    'Are you sure you want to log out of Admin mode? Viewers cannot edit or add products.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        adminAuth.logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInventoryTab(context, productProvider),
            _buildOrdersTab(context, orderProvider),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditProductScreen(),
            ),
          );
        },
      ),
    );
  }

  // TAB 1: INVENTORY & STOCK QUANTITY MANAGEMENT
  Widget _buildInventoryTab(
    BuildContext context,
    ProductProvider productProvider,
  ) {
    final products = productProvider.products;
    final outOfStockCount = products.where((p) => p.isOutOfStock).length;
    final lowStockCount = products.where((p) => p.isLowStock).length;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            // Stock Summary Stat Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildStatCard(
                    'Total Items',
                    '${products.length}',
                    Colors.blue[800]!,
                    Colors.blue[50]!,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Low Stock (≤5)',
                    '$lowStockCount',
                    Colors.amber[900]!,
                    Colors.amber[50]!,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Out of Stock',
                    '$outOfStockCount',
                    Colors.red[800]!,
                    Colors.red[50]!,
                  ),
                ],
              ),
            ),

            // Products List with Stock Quantity Controller
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 70,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No products in inventory',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.checkroom),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Product info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildStockBadge(product),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity / Stock Management Control
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Stock Qty',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              productProvider.updateStock(
                                                product.id,
                                                product.stock - 1,
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(6),
                                              child:
                                                  Icon(Icons.remove, size: 16),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              '${product.stock}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              productProvider.updateStock(
                                                product.id,
                                                product.stock + 1,
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(6),
                                              child: Icon(Icons.add, size: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 8),

                                // Actions (Edit / Delete)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AddEditProductScreen(
                                              product: product,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _showDeleteDialog(
                                          context,
                                          productProvider,
                                          product,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 2: ORDER MANAGEMENT SYSTEM
  Widget _buildOrdersTab(BuildContext context, OrderProvider orderProvider) {
    final filteredOrders = orderProvider.filteredOrders;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            // Status Filter Chips
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: OrderProvider.statusOptions.length,
                itemBuilder: (context, index) {
                  final status = OrderProvider.statusOptions[index];
                  final isSelected = orderProvider.statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (_) => orderProvider.setStatusFilter(status),
                      selectedColor: Colors.black,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Orders List
            Expanded(
              child: filteredOrders.isEmpty
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
                            'No ${orderProvider.statusFilter} orders found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(
                          context,
                          orderProvider,
                          filteredOrders[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderProvider orderProvider,
    OrderModel order,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Status Dropdown Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Placed on ${_formatDate(order.createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Order Status Change Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getStatusColor(order.status),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: order.status,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: _getStatusColor(order.status),
                    ),
                    onChanged: (String? newStatus) {
                      if (newStatus != null) {
                        orderProvider.updateOrderStatus(order.id, newStatus);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Order ${order.id} status updated to "$newStatus"',
                            ),
                          ),
                        );
                      }
                    },
                    items: OrderProvider.statusOptions
                        .where((s) => s != 'All')
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Customer Shipping Address
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.shippingAddress,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Payment Method & Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payment, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      order.paymentMethod,
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                  ],
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color textColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge(dynamic product) {
    if (product.isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'OUT OF STOCK',
          style: TextStyle(
            color: Colors.red[900],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (product.isLowStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.amber[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'LOW STOCK (${product.stock})',
          style: TextStyle(
            color: Colors.amber[900],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'In Stock (${product.stock})',
          style: TextStyle(
            color: Colors.green[900],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
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

  void _showDeleteDialog(
    BuildContext context,
    ProductProvider productProvider,
    dynamic product,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.title}" from Supabase database?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await productProvider.deleteProduct(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Deleted "${product.title}" successfully!',
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
