import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../services/supabase_service.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Sophia Martinez');
  final _phoneController = TextEditingController(text: '+1 (555) 234-5678');
  final _emailController = TextEditingController(text: 'sophia@example.com');
  final _addressController =
      TextEditingController(text: '742 Fashion Avenue, Suite 500');
  final _cityController = TextEditingController(text: 'New York');
  final _zipController = TextEditingController(text: '10001');

  String _paymentMethod = 'Credit / Debit Card';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    await Future.delayed(const Duration(seconds: 2));

    final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
    final fullAddress =
        '${_nameController.text.trim()}, ${_addressController.text.trim()}, ${_cityController.text.trim()} ${_zipController.text.trim()}';

    final order = OrderModel(
      id: orderId,
      items: List.from(cartProvider.items),
      subtotal: cartProvider.subtotal,
      tax: cartProvider.tax,
      shipping: cartProvider.shipping,
      totalAmount: cartProvider.total,
      shippingAddress: fullAddress,
      phoneNumber: _phoneController.text.trim(),
      customerEmail: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      paymentMethod: _paymentMethod,
    );

    // Save order to Supabase
    await SupabaseService().createOrder(order);

    // Deduct stock for all items purchased
    await productProvider.deductStockForCart(cartProvider.items);

    // Add order to local order provider
    orderProvider.addOrderLocally(order);

    if (mounted) {
      cartProvider.clearCart();
      setState(() => _isProcessing = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(order: order),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isWide = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Checkout & Payment',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _isProcessing
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.black),
                    const SizedBox(height: 24),
                    const Text(
                      'Processing Payment Securely...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Deducting stock & placing order...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left side: Form fields & payment methods
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildShippingCard(),
                                      const SizedBox(height: 24),
                                      _buildPaymentCard(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),

                                // Right side: Order Summary
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSummaryCard(cartProvider),
                                      const SizedBox(height: 24),
                                      _buildPayButton(cartProvider),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildShippingCard(),
                                const SizedBox(height: 24),
                                _buildPaymentCard(),
                                const SizedBox(height: 24),
                                _buildSummaryCard(cartProvider),
                                const SizedBox(height: 30),
                                _buildPayButton(cartProvider),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildShippingCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SHIPPING & CONTACT DETAILS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Enter recipient name'
                    : null,
              ),
              const SizedBox(height: 12),

              // Phone Number Field (Required)
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Required for order tracking)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Enter phone number for tracking'
                    : null,
              ),
              const SizedBox(height: 12),

              // Email Field (Optional)
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address (Optional)',
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'For tracking & order receipts',
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Enter street address'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter city' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _zipController,
                      decoration: const InputDecoration(
                        labelText: 'Postal Code',
                        prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter zip code' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAYMENT METHOD',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                value: 'Credit / Debit Card',
                groupValue: _paymentMethod,
                onChanged: (val) => setState(() => _paymentMethod = val!),
                title: const Text('Credit or Debit Card'),
                secondary: const Icon(Icons.credit_card, color: Colors.indigo),
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                value: 'Apple / Google Pay',
                groupValue: _paymentMethod,
                onChanged: (val) => setState(() => _paymentMethod = val!),
                title: const Text('Apple Pay / Google Pay'),
                secondary: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.black87,
                ),
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                value: 'Cash on Delivery',
                groupValue: _paymentMethod,
                onChanged: (val) => setState(() => _paymentMethod = val!),
                title: const Text('Cash on Delivery (COD)'),
                secondary: const Icon(
                  Icons.payments_outlined,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ORDER SUMMARY',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Subtotal (${cartProvider.totalItemCount} items)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${cartProvider.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tax (8%)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${cartProvider.tax.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Express Shipping',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    cartProvider.shipping == 0.0
                        ? 'FREE'
                        : '\$${cartProvider.shipping.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cartProvider.shipping == 0.0
                          ? Colors.green[700]
                          : Colors.black,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total to Pay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${cartProvider.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(CartProvider cartProvider) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'PAY \$${cartProvider.total.toStringAsFixed(2)} & PLACE ORDER',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
