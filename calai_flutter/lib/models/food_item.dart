import 'ingredient.dart';

class FoodItem {
  final String id;
  final String name;
  final String imagePath;
  final DateTime timestamp;
  final List<Ingredient> ingredients;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.timestamp,
    required this.ingredients,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  // Convert FoodItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  // Create FoodItem from JSON
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
