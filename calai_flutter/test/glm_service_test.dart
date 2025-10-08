import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/services/glm_service.dart';

void main() async {
  // Load .env before tests
  await dotenv.load(fileName: '.env');

  group('GLM Service Tests', () {
    late GlmService glmService;

    setUp(() {
      glmService = GlmService();
    });

    test('Analyze real food image', () async {
      // Use the test image provided by user
      final testImage = File(r'c:\Users\JI\Downloads\calai test.jpg');

      print('Testing with image: ${testImage.path}');
      print('Image exists: ${await testImage.exists()}');

      if (!await testImage.exists()) {
        fail('Test image not found at ${testImage.path}');
      }

      // Get file size before optimization
      final originalSize = await testImage.length();
      print('Original image size: ${originalSize} bytes');

      // Analyze the food
      print('\n--- Starting API call ---');
      final foodItem = await glmService.analyzeFood(testImage);

      // Print results
      print('\n--- Results ---');
      print('Food name: ${foodItem.name}');
      print('Total calories: ${foodItem.calories}');
      print('Protein: ${foodItem.protein}g');
      print('Carbs: ${foodItem.carbs}g');
      print('Fat: ${foodItem.fat}g');
      print('\nIngredients:');
      for (var ingredient in foodItem.ingredients) {
        print('  - ${ingredient.name}: ${ingredient.calories} cal');
      }

      // Verify we got valid data
      expect(foodItem.name, isNotEmpty);
      expect(foodItem.ingredients, isNotEmpty);
      expect(foodItem.calories, greaterThan(0));
    });
  });
}
