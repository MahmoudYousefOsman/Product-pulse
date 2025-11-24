
class Product {
  final int? id;
  final String name;
  final String code;
  final String image;
  final int totalQuantity;
  final int soldQuantity;
  final double purchasePrice;
  final double sellingPrice;
  final String type;
  final String move;

  Product({
    this.id,
    required this.name,
    required this.code,
    required this.image,
    required this.totalQuantity,
    required this.soldQuantity,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.type,
    required this.move,
  });

  int get remainingQuantity => totalQuantity - soldQuantity;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'no-name', 
      code: json['code'] as String? ?? '---',
      image: json['image'] as String? ??'---',
      
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
      soldQuantity: (json['soldQuantity'] as num?)?.toInt() ?? 0,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? '',
      move: json['move'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'image':image,
        'totalQuantity': totalQuantity,
        'soldQuantity': soldQuantity,
        'purchasePrice': purchasePrice,
        'sellingPrice': sellingPrice,
        'type': type,
        'move': move,
      };
}