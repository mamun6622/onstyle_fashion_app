import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String _selectedSize;
  late String _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizes.isNotEmpty
        ? widget.product.sizes.first
        : 'M';
    _selectedColor = widget.product.colors.isNotEmpty
        ? widget.product.colors.first
        : 'Black';
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isFav = productProvider.isFavorite(widget.product.id);
    final isWide = MediaQuery.of(context).size.width >= 750;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isWide
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const BackButton(color: Colors.black),
              title: Text(
                widget.product.title,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    productProvider.toggleFavorite(widget.product.id);
                  },
                ),
                const SizedBox(width: 12),
              ],
            )
          : null,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: isWide
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side: Image preview
                        Expanded(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              widget.product.imageUrl,
                              height: 500,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 500,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.checkroom,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),

                        // Right side: Details & Buy actions
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: _buildDetailsColumn(
                              context,
                              productProvider,
                              cartProvider,
                              isFav,
                              isWide: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Big Image
                            Stack(
                              children: [
                                Image.network(
                                  widget.product.imageUrl,
                                  width: double.infinity,
                                  height: 400,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 400,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.checkroom,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  right: 16,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.9),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.arrow_back,
                                            color: Colors.black,
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                      CircleAvatar(
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.9),
                                        child: IconButton(
                                          icon: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFav
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                          onPressed: () {
                                            productProvider.toggleFavorite(
                                              widget.product.id,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: _buildDetailsColumn(
                                context,
                                productProvider,
                                cartProvider,
                                isFav,
                                isWide: false,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom action bar for mobile
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildBottomActionBar(context, cartProvider),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsColumn(
    BuildContext context,
    ProductProvider productProvider,
    CartProvider cartProvider,
    bool isFav, {
    required bool isWide,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Tag & Rating
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.product.category.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${widget.product.rating}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  ' (128 reviews)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Title
        Text(
          widget.product.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),

        // Price & Discount
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              if (widget.product.originalPrice != null &&
                  widget.product.originalPrice! > widget.product.price) ...[
                const SizedBox(width: 10),
                Text(
                  '\$${widget.product.originalPrice!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'SAVE ${widget.product.discountPercent.toInt()}%',
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),

        // Select Size
        const Text(
          'SELECT SIZE',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: widget.product.sizes.map((size) {
            final isSelected = _selectedSize == size;
            return ChoiceChip(
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(size),
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedSize = size),
              selectedColor: Colors.black,
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Select Color
        const Text(
          'SELECT COLOR',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: widget.product.colors.map((color) {
            final isSelected = _selectedColor == color;
            return ChoiceChip(
              label: Text(color),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedColor = color),
              selectedColor: Colors.grey[900],
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Quantity Selector
        Row(
          children: [
            const Text(
              'QUANTITY',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),

        // Description
        const Text(
          'DESCRIPTION',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),

        // If Desktop/Tablet wide view, place buttons inline here instead of floating bottom bar
        if (isWide) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      cartProvider.addToCart(
                        widget.product,
                        _selectedSize,
                        _selectedColor,
                        quantity: _quantity,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${widget.product.title} ($_selectedSize, $_selectedColor) added to cart!',
                          ),
                          backgroundColor: Colors.black,
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text(
                      'ADD TO CART',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      cartProvider.addToCart(
                        widget.product,
                        _selectedSize,
                        _selectedColor,
                        quantity: _quantity,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'BUY NOW',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 90), // Spacing for sticky bottom bar on mobile
        ],
      ],
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  cartProvider.addToCart(
                    widget.product,
                    _selectedSize,
                    _selectedColor,
                    quantity: _quantity,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.product.title} ($_selectedSize, $_selectedColor) added to cart!',
                      ),
                      backgroundColor: Colors.black,
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text(
                  'ADD TO CART',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  cartProvider.addToCart(
                    widget.product,
                    _selectedSize,
                    _selectedColor,
                    quantity: _quantity,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CheckoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'BUY NOW',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
