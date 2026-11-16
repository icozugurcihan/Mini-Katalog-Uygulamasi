class Product {
  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.category,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageAsset,
    required this.features,
    this.currency = 'USD',
    this.imageUrl,
    this.oldPrice,
  });

  final String id;
  final String brand;
  final String name;
  final String category;
  final String subtitle;
  final String description;
  final double price;
  final double? oldPrice;
  final double rating;
  final int reviewCount;
  final String imageAsset;
  final String currency;
  final String? imageUrl;
  final List<String> features;

  factory Product.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? json['name'] ?? 'Product').toString();
    final category = (json['category'] ?? 'electronics').toString();
    final brand = (json['brand'] ?? 'Store').toString();
    final price = _number(json['price']);
    final discount = _number(json['discountPercentage']);
    final rawReviews = json['reviews'];
    final reviewCount = json['reviewCount'] is num
        ? (json['reviewCount'] as num).toInt()
        : rawReviews is List
            ? rawReviews.length
            : 0;
    final rawFeatures = json['features'] ?? json['tags'];
    final features = rawFeatures is List
        ? rawFeatures.map((value) => value.toString()).toList(growable: false)
        : <String>[];

    return Product(
      id: json['id'].toString(),
      brand: brand,
      name: title,
      category: category,
      subtitle: (json['subtitle'] ?? '$brand · $category').toString(),
      description: (json['description'] ?? 'A closer look at thoughtful design and everyday performance.').toString(),
      price: price,
      oldPrice: json['oldPrice'] is num
          ? _number(json['oldPrice'])
          : discount > 0 && discount < 100
              ? price / (1 - discount / 100)
              : null,
      rating: _number(json['rating']),
      reviewCount: reviewCount,
      imageAsset: (json['imageAsset'] ?? '').toString(),
      currency: (json['currency'] ?? (json['imageAsset'] != null ? 'TRY' : 'USD')).toString(),
      imageUrl: (json['thumbnail'] ?? json['imageUrl'])?.toString(),
      features: features.isNotEmpty
          ? features
          : const ['Thoughtful design', 'Reliable everyday performance'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'name': name,
        'category': category,
        'subtitle': subtitle,
        'description': description,
        'price': price,
        'oldPrice': oldPrice,
        'rating': rating,
        'reviewCount': reviewCount,
        'imageAsset': imageAsset,
        'currency': currency,
        'imageUrl': imageUrl,
        'features': features,
      };

  static double _number(dynamic value) => value is num ? value.toDouble() : 0;
}
