// Modelo de datos y datos dummy
class Product {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final int discount;
  final String description;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    this.discount = 0,
    required this.description,
    this.isFavorite = false,
  });
}