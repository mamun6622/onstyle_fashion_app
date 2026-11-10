import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../utils/responsive.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final filteredList = productProvider.filteredProducts;

    final int crossAxisCount = Responsive.getGridCrossAxisCount(context);
    final double aspectRatio = Responsive.getGridAspectRatio(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => productProvider.loadProducts(),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: CustomScrollView(
                slivers: [
                  // Top Custom App Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ON:STYLE FASHION',
                                  style: TextStyle(
                                    letterSpacing: 2.0,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'ON:STYLE',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Supabase status indicator & config button

                        ],
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        onChanged: (val) => productProvider.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search clothes, shoes, bags...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black54,
                          ),
                          suffixIcon: productProvider.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () =>
                                      productProvider.setSearchQuery(''),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Promotional Banner
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      height: Responsive.isDesktop(context) ? 180 : 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            top: -20,
                            child: Opacity(
                              opacity: 0.35,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&q=80&w=400',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'SUMMER SALE 2025',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Up to 40% OFF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        Responsive.isDesktop(context) ? 28 : 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Explore modern minimalist trends',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Categories Selector
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: ProductProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = ProductProvider.categories[index];
                          final isSelected =
                              productProvider.selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (_) =>
                                  productProvider.setCategory(category),
                              selectedColor: Colors.black,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[300]!,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Results Count & Sorting Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredList.length} Products Found',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          DropdownButton<SortOption>(
                            value: productProvider.sortOption,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.sort, size: 20),
                            onChanged: (SortOption? newOption) {
                              if (newOption != null) {
                                productProvider.setSortOption(newOption);
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: SortOption.newest,
                                child: Text(
                                  'Newest Arrival',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              DropdownMenuItem(
                                value: SortOption.priceLowToHigh,
                                child: Text(
                                  'Price: Low to High',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              DropdownMenuItem(
                                value: SortOption.priceHighToLow,
                                child: Text(
                                  'Price: High to Low',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              DropdownMenuItem(
                                value: SortOption.rating,
                                child: Text(
                                  'Highest Rated',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Product Grid / Loading / Empty State
                  if (productProvider.isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (filteredList.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No fashion products found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                productProvider.setCategory('All');
                                productProvider.setSearchQuery('');
                              },
                              child: const Text('Clear Filters'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ProductCard(product: filteredList[index]);
                          },
                          childCount: filteredList.length,
                        ),
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
}
