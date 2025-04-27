// models/scanned_product.dart

class ScannedProduct {
  final String barcode;      // ✅ 新增：用于唯一标识
  String name;
  String? storage;           // 'fridge' or 'freezer'
  DateTime? expiryDate;

  ScannedProduct({
    required this.barcode,
    required this.name,
    this.storage,
    this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'storage': storage,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  static ScannedProduct fromMap(Map<String, dynamic> map) {
    return ScannedProduct(
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      storage: map['storage'],
      expiryDate: map['expiryDate'] != null
          ? DateTime.tryParse(map['expiryDate'])
          : null,
    );
  }
}
