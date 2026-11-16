import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/common_widgets.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.products,
    required this.favorites,
    required this.onProductTap,
    required this.onFavoriteTap,
    required this.onContinue,
  });

  final List<Product> products;
  final Set<String> favorites;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onFavoriteTap;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final saved = products
        .where((product) => favorites.contains(product.id))
        .toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: saved.isEmpty
            ? Column(
                children: [
                  const _FavoritesHeader(),
                  Expanded(
                    child: EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'No favorites yet',
                      message: 'Tap the heart on a product to save it here.',
                      actionLabel: 'Explore products',
                      onAction: onContinue,
                    ),
                  ),
                ],
              )
            : CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _FavoritesHeader()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 25),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = saved[index];
                          return ProductCard(
                            product: product,
                            isFavorite: true,
                            onTap: () => onProductTap(product),
                            onFavoriteTap: () => onFavoriteTap(product),
                          );
                        },
                        childCount: saved.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.sizeOf(context).width >= 700 ? 3 : 2,
                        crossAxisSpacing: 13,
                        mainAxisSpacing: 13,
                        childAspectRatio:
                            MediaQuery.sizeOf(context).width < 360 ? .68 : .72,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Favorites',
            style: TextStyle(
              color: Color(0xFF1D1D1F),
              fontSize: 27,
              letterSpacing: -.6,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
