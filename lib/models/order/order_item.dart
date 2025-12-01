class OrderItem {
  final String id;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subTotal;
  final OrderProduct? product;

  OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subTotal,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      product: json['product'] != null
          ? OrderProduct.fromJson(json['product'])
          : null,
    );
  }

  String? get imageUrl => product?.imageUrl;
}

class OrderProduct {
  final String id;
  final String name;
  final String? description;
  final List<ProductImage> images;

  OrderProduct({
    required this.id,
    required this.name,
    this.description,
    this.images = const [],
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      images: json['images'] != null
          ? (json['images'] as List)
                .map((img) => ProductImage.fromJson(img))
                .toList()
          : [],
    );
  }

  String? get imageUrl => images.isNotEmpty ? images.first.url : null;
}

class ProductImage {
  final String id;
  final String url;

  ProductImage({required this.id, required this.url});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(id: json['id'] ?? '', url: json['url'] ?? '');
  }
}
