import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _sizesController;
  late TextEditingController _colorsController;
  late TextEditingController _stockController;

  String _category = 'Tops';
  bool _isPopular = false;
  bool _isSaving = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _originalPriceController = TextEditingController(
      text: p?.originalPrice != null ? p!.originalPrice.toString() : '',
    );
    _imageUrlController = TextEditingController(
      text: p?.imageUrl ??
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&q=80&w=600',
    );
    _sizesController = TextEditingController(
      text: p != null ? p.sizes.join(', ') : 'S, M, L, XL',
    );
    _colorsController = TextEditingController(
      text: p != null ? p.colors.join(', ') : 'Black, White, Beige',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '15',
    );
    _category = p?.category ?? 'Tops';
    _isPopular = p?.isPopular ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _imageUrlController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    final double price = double.parse(_priceController.text.trim());
    final double? origPrice = _originalPriceController.text.trim().isNotEmpty
        ? double.tryParse(_originalPriceController.text.trim())
        : null;
    final int stockQty = int.tryParse(_stockController.text.trim()) ?? 15;

    final sizesList = _sizesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final colorsList = _colorsController.text
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    final id =
        widget.product?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}';

    final product = Product(
      id: id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      originalPrice: origPrice,
      category: _category,
      imageUrl: _imageUrlController.text.trim(),
      sizes: sizesList.isNotEmpty ? sizesList : ['S', 'M', 'L'],
      colors: colorsList.isNotEmpty ? colorsList : ['Black', 'White'],
      isPopular: _isPopular,
      stock: stockQty,
      rating: widget.product?.rating ?? 4.8,
    );

    if (isEditing) {
      await productProvider.updateProduct(product);
    } else {
      await productProvider.addProduct(product);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Product updated in Supabase successfully!'
                : 'New Product added to Supabase successfully!',
          ),
          backgroundColor: Colors.green[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 750;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          isEditing ? 'Edit Product' : 'Add New Fashion Item',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: Image preview & Image URL field
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildImagePreviewSection(),
                                const SizedBox(height: 16),
                                _buildImageUrlField(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),

                          // Right column: Title, Category, Pricing, Sizes, Colors, Desc & Submit
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFormFields(),
                                const SizedBox(height: 24),
                                _buildSubmitButton(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePreviewSection(),
                          const SizedBox(height: 16),
                          _buildImageUrlField(),
                          const SizedBox(height: 16),
                          _buildFormFields(),
                          const SizedBox(height: 24),
                          _buildSubmitButton(),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IMAGE PREVIEW',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            height: 220,
            width: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                _imageUrlController.text.trim(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child:
                      Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUrlField() {
    return TextFormField(
      controller: _imageUrlController,
      onChanged: (_) => setState(() {}),
      decoration: const InputDecoration(
        labelText: 'Image URL',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.image),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Enter image URL' : null,
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Product Title',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          validator: (val) =>
              val == null || val.isEmpty ? 'Enter product title' : null,
        ),
        const SizedBox(height: 16),

        // Category Selection Dropdown
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: ProductProvider.categories
              .where((c) => c != 'All')
              .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _category = val);
          },
        ),
        const SizedBox(height: 16),

        // Price, Original Price & Stock Quantity Row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter price';
                  if (double.tryParse(val) == null) return 'Invalid price';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _originalPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Original Price (\$)',
                  hintText: 'Discount',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock Qty',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Qty';
                  if (int.tryParse(val) == null) return 'Invalid';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Sizes & Colors
        TextFormField(
          controller: _sizesController,
          decoration: const InputDecoration(
            labelText: 'Available Sizes (comma separated)',
            hintText: 'S, M, L, XL',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.straighten),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _colorsController,
          decoration: const InputDecoration(
            labelText: 'Available Colors (comma separated)',
            hintText: 'Black, White, Beige',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.color_lens),
          ),
        ),
        const SizedBox(height: 16),

        // Description
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          validator: (val) =>
              val == null || val.isEmpty ? 'Enter description' : null,
        ),
        const SizedBox(height: 16),

        // Popular Toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Mark as Popular / Featured Item'),
          value: _isPopular,
          onChanged: (val) => setState(() => _isPopular = val),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isEditing
                    ? 'UPDATE PRODUCT IN SUPABASE'
                    : 'ADD PRODUCT TO SUPABASE',
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
