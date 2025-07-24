class FoodModel {
  final int? id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final double? stars;
  final String category;

  FoodModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    this.stars,
    required this.category,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      images: (json['images'] is String)
          ? (json['images'] as String).split(',')
          : List<String>.from(json['images'] ?? []),
      stars: json['stars'] != null ? (json['stars'] as num).toDouble() : null,
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images.join(','),
      'category': category,
    };
  }
}

