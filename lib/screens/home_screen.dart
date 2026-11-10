import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'browse_screen.dart';
import 'cart_screen.dart';
import 'track_order_screen.dart';
import 'admin_product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BrowseScreen(),
    CartScreen(),
    TrackOrderScreen(),
    AdminProductScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[500],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded, color: Colors.black),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cartProvider.totalItemCount > 0,
                label: Text('${cartProvider.totalItemCount}'),
                backgroundColor: Colors.deepOrange,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: cartProvider.totalItemCount > 0,
                label: Text('${cartProvider.totalItemCount}'),
                backgroundColor: Colors.deepOrange,
                child: const Icon(Icons.shopping_bag, color: Colors.black),
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping, color: Colors.black),
              label: 'Track Order',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings, color: Colors.black),
              label: 'Manage App',
            ),
          ],
        ),
      ),
    );
  }
}
