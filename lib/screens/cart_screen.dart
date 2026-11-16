import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/common_widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.products,
    required this.cart,
    required this.onQuantityChange,
    required this.onContinue,
    required this.onOrderComplete,
  });

  final List<Product> products;
  final Map<String, int> cart;
  final void Function(Product product, int change) onQuantityChange;
  final VoidCallback onContinue;
  final VoidCallback onOrderComplete;

  @override
  Widget build(BuildContext context) {
    final cartProducts = products
        .where((product) => (cart[product.id] ?? 0) > 0)
        .toList(growable: false);
    final itemCount = cart.values.fold<int>(0, (sum, quantity) => sum + quantity);
    final total = cartProducts.fold<double>(
      0,
      (sum, product) => sum + product.price * (cart[product.id] ?? 0),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onContinue,
                    tooltip: 'Continue shopping',
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFFF5F5F3)),
                    icon: const Icon(Icons.arrow_back_rounded, size: 19),
                  ),
                  const Expanded(
                    child: Text('My Cart',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(
                    width: 42,
                    child: Text('$itemCount',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF777777))),
                  ),
                ],
              ),
            ),
            if (cartProducts.isEmpty)
              ...[
                Expanded(
                  child: EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your cart is empty',
                    message: 'Discover something you love and it will appear here.',
                    actionLabel: 'Continue shopping',
                    onAction: onContinue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE8E8E5))),
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: null,
                      child: Text('Checkout'),
                    ),
                  ),
                ),
              ]
            else ...[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 7, 22, 18),
                  children: [
                    ...cartProducts.map((product) => Padding(
                          padding: const EdgeInsets.only(bottom: 13),
                          child: _CartItem(
                            product: product,
                            quantity: cart[product.id] ?? 0,
                            onQuantityChange: (change) => onQuantityChange(product, change),
                          ),
                        )),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Order total',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                          Text(formatPrice(total, currency: cartProducts.first.currency),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text('Shipping and taxes calculated at checkout',
                          style: TextStyle(fontSize: 11, color: Color(0xFF777777))),
                    ),
                  ],
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
                  child: FilledButton(
                    onPressed: () => _confirmOrder(context),
                    child: const Text('Checkout'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Demo checkout'),
        content: const Text('This project does not process real payments. Place a sample order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Place order'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      onOrderComplete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sample order placed. Thank you!'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.product,
    required this.quantity,
    required this.onQuantityChange,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChange;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8E5)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 86,
                height: 88,
                child: ColoredBox(
                  color: const Color(0xFFF5F5F3),
                  child: ProductImage(product: product),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand.toUpperCase(),
                      style: const TextStyle(fontSize: 9, letterSpacing: 1, color: Color(0xFF777777))),
                  const SizedBox(height: 5),
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 7),
                  Text(formatPrice(product.price, currency: product.currency),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _QuantityControl(
                        icon: quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                        onTap: () => onQuantityChange(-1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        child: Text('$quantity', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      _QuantityControl(
                        icon: Icons.add_rounded,
                        onTap: () => onQuantityChange(1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFFF5F5F3),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(width: 24, height: 24, child: Icon(icon, size: 14)),
        ),
      );
}
