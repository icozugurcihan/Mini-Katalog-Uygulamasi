import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../models/product.dart';

class CatalogRepository {
  const CatalogRepository();

  static final Uri _catalogUri = Uri.https(
    'dummyjson.com',
    '/products/search',
    {'q': 'apple', 'limit': '30'},
  );

  static final Uri _replacementUri = Uri.https(
    'dummyjson.com',
    '/products/search',
    {'q': 'samsung', 'limit': '30'},
  );

  Future<List<Product>> loadProducts() async {
    try {
      final results = await Future.wait<List<Product>>([
        _fetchProducts(_catalogUri),
        _fetchProducts(_replacementUri).catchError((Object _) => <Product>[]),
      ]);

      final products = results[0]
          .where((product) => !_isSuspiciousApplePrice(product))
          .toList(growable: true);

      Product? replacement;
      for (final product in results[1]) {
        final isSamsungPhone =
            product.category == 'smartphones' &&
            (product.brand.toLowerCase().contains('samsung') ||
                product.name.toLowerCase().contains('samsung')) &&
            !_isSuspiciousApplePrice(product);
        if (isSamsungPhone) {
          replacement = product;
          break;
        }
      }

      final samsungPhone = replacement;
      if (samsungPhone != null &&
          !products.any((product) => product.id == samsungPhone.id)) {
        products.insert(products.length > 1 ? 1 : products.length, samsungPhone);
      }
      if (products.isNotEmpty) return products;
    } catch (_) {
      // Offline or blocked networks use the bundled catalog below.
    }

    final jsonString = await rootBundle.loadString('assets/data/products.json');
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  bool _isSuspiciousApplePrice(Product product) {
    final isApple = product.brand.toLowerCase().contains('apple') ||
        product.name.toLowerCase().contains('apple');
    return isApple && product.price < 2.5;
  }

  Future<List<Product>> _fetchProducts(Uri uri) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final request =
          await client.getUrl(uri).timeout(const Duration(seconds: 8));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('DummyJSON returned ${response.statusCode}');
      }
      final body = await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 8));
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final entries = decoded['products'] as List<dynamic>;
      return entries
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } finally {
      client.close(force: true);
    }
  }
}
