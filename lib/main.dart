import 'package:flutter/material.dart';

import 'data/catalog_repository.dart';
import 'models/product.dart';
import 'screens/cart_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/product_detail_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/common_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NovaCatalogApp());
}

class NovaCatalogApp extends StatelessWidget {
  const NovaCatalogApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Discover · Tech & design',
        debugShowCheckedModeBanner: false,
        theme: buildNovaTheme(),
        home: const CatalogController(),
      );
}

class CatalogController extends StatefulWidget {
  const CatalogController({super.key});

  @override
  State<CatalogController> createState() => _CatalogControllerState();
}

class _CatalogControllerState extends State<CatalogController> {
  late Future<List<Product>> _productsFuture;
  final Map<String, int> _cart = {};
  final Set<String> _favorites = {};
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _productsFuture = const CatalogRepository().loadProducts();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _LoadingScreen();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _CatalogErrorScreen(onRetry: _retryLoading);
          }
          final products = snapshot.data!;
          final cartCount =
              _cart.values.fold<int>(0, (sum, quantity) => sum + quantity);
          return Scaffold(
            backgroundColor: Colors.white,
            body: PopScope<Object?>(
              canPop: _selectedTab == 0,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop && _selectedTab != 0) {
                  setState(() => _selectedTab = 0);
                }
              },
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  CatalogScreen(
                    products: products,
                    favorites: _favorites,
                    onProductTap: _openProduct,
                    onFavoriteTap: _toggleFavorite,
                    onCartTap: () => setState(() => _selectedTab = 2),
                    cartCount: cartCount,
                  ),
                  FavoritesScreen(
                    products: products,
                    favorites: _favorites,
                    onProductTap: _openProduct,
                    onFavoriteTap: _toggleFavorite,
                    onContinue: () => setState(() => _selectedTab = 0),
                  ),
                  CartScreen(
                    products: products,
                    cart: _cart,
                    onQuantityChange: _changeQuantity,
                    onContinue: () => setState(() => _selectedTab = 0),
                    onOrderComplete: () => setState(_cart.clear),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedTab,
              onDestinationSelected: (index) => setState(() => _selectedTab = index),
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFF1F1EF),
              elevation: 2,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: 'Discover',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: _CartTabIcon(count: cartCount),
                  selectedIcon: _CartTabIcon(count: cartCount, selected: true),
                  label: 'Cart',
                ),
              ],
            ),
          );
        },
      );

  void _openProduct(Product product) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(
          name: '/product-detail',
          arguments: product,
        ),
        builder: (routeContext) {
          final routeProduct = ModalRoute.of(routeContext)!.settings.arguments! as Product;
          return ProductDetailScreen(
            product: routeProduct,
            initialFavorite: _favorites.contains(routeProduct.id),
            onFavoriteTap: _toggleFavorite,
            onAddToCart: _addToCart,
          );
        },
      ),
    );
  }

  void _toggleFavorite(Product product) {
    setState(() {
      if (!_favorites.add(product.id)) _favorites.remove(product.id);
    });
  }

  void _addToCart(Product product) {
    setState(() {
      _cart.update(product.id, (quantity) => quantity + 1, ifAbsent: () => 1);
    });
  }

  void _changeQuantity(Product product, int change) {
    setState(() {
      final nextQuantity = (_cart[product.id] ?? 0) + change;
      if (nextQuantity <= 0) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = nextQuantity;
      }
    });
  }

  void _retryLoading() {
    setState(() => _productsFuture = const CatalogRepository().loadProducts());
  }
}

class _CartTabIcon extends StatelessWidget {
  const _CartTabIcon({required this.count, this.selected = false});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 28,
        height: 26,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 2,
              bottom: 1,
              child: Icon(
                selected ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
                size: 21,
              ),
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -2,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1D1D1F),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Discover',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              SizedBox(height: 20),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.3),
              ),
            ],
          ),
        ),
      );
}

class _CatalogErrorScreen extends StatelessWidget {
  const _CatalogErrorScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Catalog could not load',
            message: 'The online and saved product catalogs are unavailable. Please try again.',
            actionLabel: 'Try again',
            onAction: onRetry,
          ),
        ),
      );
}
