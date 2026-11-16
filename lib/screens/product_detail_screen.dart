import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/common_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.initialFavorite,
    required this.onFavoriteTap,
    required this.onAddToCart,
  });

  final Product product;
  final bool initialFavorite;
  final ValueChanged<Product> onFavoriteTap;
  final ValueChanged<Product> onAddToCart;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isFavorite = widget.initialFavorite;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
              child: Row(
                children: [
                  _circleAction(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                    tooltip: 'Back',
                  ),
                  const Spacer(),
                  const Text('Product details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  _circleAction(
                    icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? const Color(0xFFE55A63) : const Color(0xFF1D1D1F),
                    onTap: () {
                      setState(() => _isFavorite = !_isFavorite);
                      widget.onFavoriteTap(product);
                    },
                    tooltip: 'Save product',
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: ColoredBox(
                          color: const Color(0xFFF5F5F3),
                          child: Hero(
                            tag: 'product-${product.id}',
                            child: ProductImage(product: product),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Color(0xFF1D1D1F),
                        fontSize: 25,
                        height: 1.15,
                        letterSpacing: -.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 17, color: Color(0xFFE7A83E)),
                        const SizedBox(width: 4),
                        Text(product.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        Text('(${product.reviewCount} reviews)',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF777777))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(formatPrice(product.price, currency: product.currency),
                            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                        if (product.oldPrice != null) ...[
                          const SizedBox(width: 9),
                          Text(
                            formatPrice(product.oldPrice!, currency: product.currency),
                            style: const TextStyle(
                              color: Color(0xFF999999),
                              decoration: TextDecoration.lineThrough,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1, color: Color(0xFFE8E8E5)),
                    ),
                    const Text('Description',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                    if (product.features.isNotEmpty) ...[
                      const SizedBox(height: 21),
                      const Text('Highlights',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.features.take(4).map((feature) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(feature,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF555555))),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 19),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text('Free delivery on orders over \$100. Easy returns within 30 days.',
                                style: TextStyle(fontSize: 11, height: 1.4, color: Color(0xFF555555))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE8E8E5))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    widget.onAddToCart(product);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text('Added to your cart.'),
                        behavior: SnackBarBehavior.floating,
                      ));
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: Text('Add to cart  ·  ${formatPrice(product.price, currency: product.currency)}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleAction({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    Color color = const Color(0xFF1D1D1F),
  }) => IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFF5F5F3),
          foregroundColor: color,
          fixedSize: const Size(42, 42),
        ),
        icon: Icon(icon, size: 19),
      );
}
