class Product {
  final String name; // اسم المنتج
  final String code; // كود المنتج
  final String type ; 
  final String move ; 
  final String image; // رابط أو مسار الصورة
  final int totalQuantity; // الكمية الكلية
  final int soldQuantity; // الكمية المباعة
  final double purchasePrice; // سعر الشراء
  final double sellingPrice; // سعر البيع


  Product({
    required this.name,
    required this.code,
    required this.type,
    required this.move,
    required this.image,
    required this.totalQuantity,
    required this.soldQuantity,
    required this.purchasePrice,
    required this.sellingPrice,
  });

  
  int get remainingQuantity => totalQuantity - soldQuantity;

  
  Map<String, dynamic> json() {
    return {
      'name': name,
      'code': code,
      'type':type,
      'move':move, 
      'image': image,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'totalQuantity': totalQuantity,
      'soldQuantity': soldQuantity,
    };
  }

  // 🔹 إنشاء كائن Product من Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      type: map['type'] ?? '',
      move: map['move'] ?? '',
      image: map['image'] ?? '',
      totalQuantity: map['totalQuantity'] ?? 0,
      soldQuantity: map['soldQuantity'] ?? 0,
      purchasePrice: (map['purchasePrice'] ?? 0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0).toDouble(),
    );
  }
}
