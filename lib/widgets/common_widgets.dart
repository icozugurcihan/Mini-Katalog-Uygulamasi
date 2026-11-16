import 'package:flutter/material.dart';

import '../models/product.dart';

String formatPrice(double amount, {String currency = 'USD'}) {
  final whole = amount.round().toString();
  final grouped = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return currency == 'TRY' ? '$grouped ₺' : '\$$grouped';
}

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product, this.fit = BoxFit.contain});

  final Product product;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => _assetOrPlaceholder(),
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
      );
    }
    return _assetOrPlaceholder();
  }

  Widget _assetOrPlaceholder() {
    if (product.imageAsset.isNotEmpty) {
      return Image.asset(
        product.imageAsset,
        fit: fit,
        errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
      );
    }
    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: Color(0xFFF5F5F3),
        child: Center(
          child: Icon(Icons.devices_other_outlined,
              size: 42, color: Color(0xFFB8B8B4)),
        ),
      );
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product-${product.id}',
                    child: ProductImage(product: product),
                  ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Material(
                      color: Colors.white.withValues(alpha: .92),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onFavoriteTap,
                        child: SizedBox(
                          width: 34,
                          height: 34,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFavorite ? const Color(0xFFE55A63) : const Color(0xFF252525),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1D1D1F),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFE7A83E)),
                      const SizedBox(width: 3),
                      Text(product.rating.toStringAsFixed(1),
                          style: const TextStyle(color: Color(0xFF777777), fontSize: 11)),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          formatPrice(product.price, currency: product.currency),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1D1D1F),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: const Color(0xFFB8B8B4)),
              const SizedBox(height: 17),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF777777), height: 1.45)),
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
        ),
      );
}
