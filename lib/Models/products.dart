class Product {
  final int? id;
  final String name;
  final String code;
  final String image;
  final int totalQuantity;
  final double purchasePrice;
  final double sellingPrice;
 

  Product({
    this.id,
    required this.name,
    required this.code,
    required this.image,
    required this.totalQuantity,
    required this.purchasePrice,
    required this.sellingPrice,
  });

  // قراءة من Supabase
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      image: json['image'] ?? '',
      totalQuantity: (json['totalQuantity'] ?? 0).toInt(),
      purchasePrice: (json['PurchasePrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['SellingPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // كتابة / إرسال إلى Supabase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'image': image,
      'totalQuantity': totalQuantity,
      'PurchasePrice': purchasePrice,
      'SellingPrice': sellingPrice,
    };
  }
}
