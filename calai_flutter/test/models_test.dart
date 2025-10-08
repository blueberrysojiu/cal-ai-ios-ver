import 'package:flutter_test/flutter_test.dart';
import 'package:calai_flutter/models/ingredient.dart';
import 'package:calai_flutter/models/food_item.dart';
import 'dart:convert';

void main() {
  group('Ingredient Model Tests', () {
    test('Ingredient serialization - roundtrip test', () {
      // Create an ingredient
      final ingredient = Ingredient(
        name: 'Rice',
        calories: 130.0,
      );

      // Convert to JSON
      final json = ingredient.toJson();
      print('Ingredient JSON: ${jsonEncode(json)}');

      // Convert back from JSON
      final parsedIngredient = Ingredient.fromJson(json);

      // Verify
      expect(parsedIngredient.name, ingredient.name);
      expect(parsedIngredient.calories, ingredient.calories);
    });

    test('Ingredient handles missing fields', () {
      // Test with empty map
      final ingredient = Ingredient.fromJson({});

      expect(ingredient.name, '');
      expect(ingredient.calories, 0.0);
    });

    test('Ingredient handles null values', () {
      final json = {'name': null, 'calories': null};
      final ingredient = Ingredient.fromJson(json);

      expect(ingredient.name, '');
      expect(ingredient.calories, 0.0);
    });
  });

  group('FoodItem Model Tests', () {
    test('FoodItem serialization - roundtrip test', () {
      // Create a food item
      final foodItem = FoodItem(
        id: '123',
        name: 'Chicken Rice',
        imagePath: '/path/to/image.jpg',
        timestamp: DateTime(2025, 10, 6, 12, 30),
        ingredients: [
          Ingredient(name: 'Chicken', calories: 250.0),
          Ingredient(name: 'Rice', calories: 250.0),
        ],
        calories: 500.0,
        protein: 30.5,
        carbs: 60.2,
        fat: 15.8,
      );

      // Convert to JSON
      final json = foodItem.toJson();
      print('FoodItem JSON: ${jsonEncode(json)}');

      // Convert back from JSON
      final parsedFoodItem = FoodItem.fromJson(json);

      // Verify
      expect(parsedFoodItem.id, foodItem.id);
      expect(parsedFoodItem.name, foodItem.name);
      expect(parsedFoodItem.imagePath, foodItem.imagePath);
      expect(parsedFoodItem.timestamp, foodItem.timestamp);
      expect(parsedFoodItem.ingredients.length, 2);
      expect(parsedFoodItem.ingredients[0].name, 'Chicken');
      expect(parsedFoodItem.ingredients[1].calories, 250.0);
      expect(parsedFoodItem.calories, 500.0);
      expect(parsedFoodItem.protein, 30.5);
      expect(parsedFoodItem.carbs, 60.2);
      expect(parsedFoodItem.fat, 15.8);
    });

    test('FoodItem handles empty ingredients list', () {
      final foodItem = FoodItem(
        id: '456',
        name: 'Water',
        imagePath: '/path/to/water.jpg',
        timestamp: DateTime.now(),
        ingredients: [],
        calories: 0.0,
        protein: 0.0,
        carbs: 0.0,
        fat: 0.0,
      );

      final json = foodItem.toJson();
      final parsedFoodItem = FoodItem.fromJson(json);

      expect(parsedFoodItem.ingredients.length, 0);
      expect(parsedFoodItem.name, 'Water');
    });

    test('FoodItem handles missing fields', () {
      final json = {'id': '789'};
      final foodItem = FoodItem.fromJson(json);

      expect(foodItem.id, '789');
      expect(foodItem.name, '');
      expect(foodItem.imagePath, '');
      expect(foodItem.ingredients.length, 0);
      expect(foodItem.calories, 0.0);
      expect(foodItem.protein, 0.0);
      expect(foodItem.carbs, 0.0);
      expect(foodItem.fat, 0.0);
    });

    test('FoodItem handles null ingredients', () {
      final json = {
        'id': '999',
        'name': 'Test Food',
        'ingredients': null,
      };
      final foodItem = FoodItem.fromJson(json);

      expect(foodItem.ingredients.length, 0);
    });

    test('Sample JSON format verification', () {
      // Create sample that matches expected API response
      final sampleJson = {
        'id': 'sample-123',
        'name': 'Grilled Chicken with Vegetables',
        'imagePath': '/storage/image123.jpg',
        'timestamp': '2025-10-06T12:30:00.000',
        'ingredients': [
          {'name': 'Grilled Chicken Breast', 'calories': 250.0},
          {'name': 'Broccoli', 'calories': 100.0},
          {'name': 'Carrots', 'calories': 100.0},
        ],
        'calories': 450.0,
        'protein': 45.0,
        'carbs': 35.0,
        'fat': 12.0,
      };

      print('\nSample API Response JSON:');
      print(jsonEncode(sampleJson));

      final foodItem = FoodItem.fromJson(sampleJson);
      expect(foodItem.name, 'Grilled Chicken with Vegetables');
      expect(foodItem.ingredients.length, 3);
      expect(foodItem.calories, 450.0);
    });
  });
}
