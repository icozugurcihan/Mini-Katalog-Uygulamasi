import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/common_widgets.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    required this.products,
    required this.favorites,
    required this.onProductTap,
    required this.onFavoriteTap,
    required this.onCartTap,
    required this.cartCount,
  });

  final List<Product> products;
  final Set<String> favorites;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onFavoriteTap;
  final VoidCallback onCartTap;
  final int cartCount;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>[
      'All',
      ...widget.products.map((product) => product.category).toSet(),
    ];
    final filtered = widget.products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              sliver: SliverToBoxAdapter(child: _header()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
              sliver: SliverToBoxAdapter(child: _searchField()),
            ),
            if (widget.products.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                sliver: SliverToBoxAdapter(child: _feature(widget.products.first)),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 25, 22, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Explore products',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.4,
                      ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 13, 22, 0),
              sliver: SliverToBoxAdapter(child: _categoryFilters(categories)),
            ),
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_rounded,
                  title: 'No products found',
                  message: 'Try another search or choose a different category.',
                  actionLabel: 'Clear filters',
                  onAction: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedCategory = 'All';
                    });
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = filtered[index];
                      return ProductCard(
                        product: product,
                        isFavorite: widget.favorites.contains(product.id),
                        onTap: () => widget.onProductTap(product),
                        onFavoriteTap: () => widget.onFavoriteTap(product),
                      );
                    },
                    childCount: filtered.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 3 : 2,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                    childAspectRatio: MediaQuery.sizeOf(context).width < 360 ? .68 : .72,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Discover',
            style: TextStyle(
              color: Color(0xFF1D1D1F),
              fontSize: 28,
              letterSpacing: -.7,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Material(
          color: const Color(0xFFF5F5F3),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: widget.onCartTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 21),
                  if (widget.cartCount > 0)
                    Positioned(
                      top: 1,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1D1D1F),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${widget.cartCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 9),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchField() => TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search products',
          prefixIcon: const Icon(Icons.search_rounded, size: 21),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(Icons.close_rounded, size: 19),
                ),
        ),
      );

  Widget _feature(Product featured) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F1),
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -15,
            bottom: -15,
            width: 175,
            child: ProductImage(product: featured),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFF4F4F1), const Color(0xFFF4F4F1).withValues(alpha: .05)],
                  stops: const [0, 1],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 19, 15, 16),
            child: SizedBox(
              width: 190,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('THE GIFT STORE',
                      style: TextStyle(fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w700, color: Color(0xFF777777))),
                  const Spacer(),
                  const Text('A little joy,\nevery day.',
                      style: TextStyle(fontSize: 23, height: 1.05, letterSpacing: -.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 7),
                  InkWell(
                    onTap: () => widget.onProductTap(featured),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Shop now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryFilters(List<String> categories) {
    return SizedBox(
      height: 37,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == _selectedCategory;
          return ChoiceChip(
            label: Text(category == 'All' ? 'All' : _capitalize(category)),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => setState(() => _selectedCategory = category),
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF1D1D1F),
            side: BorderSide(color: selected ? const Color(0xFF1D1D1F) : const Color(0xFFE8E8E5)),
            labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF5E5E5E), fontSize: 11, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 7),
          );
        },
      ),
    );
  }

  String _capitalize(String value) => value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1).replaceAll('-', ' ')}';
}
