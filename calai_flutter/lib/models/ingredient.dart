class Ingredient {
  final String name;
  final double calories;

  Ingredient({
    required this.name,
    required this.calories,
  });

  // Convert Ingredient to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
    };
  }

  // Create Ingredient from JSON
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
