// Model class representing a scanned food product
class ScannedProduct {
  final String barcode;      // Barcode used for unique identification
  String name;               // Name of the product
  String? storage;           // Storage location: 'fridge' or 'freezer'
  DateTime? expiryDate;      // Expiration date of the product

  ScannedProduct({
    required this.barcode,
    required this.name,
    this.storage,
    this.expiryDate,
  });

  // Convert the ScannedProduct object to a map for saving to database
  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'storage': storage,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  // Create a ScannedProduct object from a map retrieved from database
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
