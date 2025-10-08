import 'package:flutter_test/flutter_test.dart';
import 'package:calai_flutter/models/ingredient.dart';
import 'package:calai_flutter/models/food_item.dart';
import 'package:calai_flutter/services/food_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Setup: Initialize fake SharedPreferences before each test
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FoodHistoryService Tests', () {
    test('Test 1: Save FoodItem and verify persistence', () async {
      final service = FoodHistoryService();

      final testItem = FoodItem(
        id: 'test-id-001',
        name: 'Grilled Chicken Salad',
        imagePath: '/path/to/image1.jpg',
        timestamp: DateTime.now(),
        ingredients: [
          Ingredient(name: 'Chicken breast', calories: 165.0),
          Ingredient(name: 'Lettuce', calories: 5.0),
          Ingredient(name: 'Tomatoes', calories: 22.0),
        ],
        calories: 300.0,
        protein: 35.0,
        carbs: 15.0,
        fat: 8.0,
      );

      await service.saveFoodItem(testItem);

      // Simulate app restart with new service instance
      final newService = FoodHistoryService();
      final loadedItems = await newService.loadAllFoodItems();

      expect(loadedItems.length, 1);
      expect(loadedItems[0].id, testItem.id);
      expect(loadedItems[0].name, testItem.name);
      expect(loadedItems[0].calories, testItem.calories);
    });

    test('Test 2: Save multiple items and retrieve all', () async {
      final service = FoodHistoryService();

      final testItem1 = FoodItem(
        id: 'test-id-001',
        name: 'Grilled Chicken Salad',
        imagePath: '/path/to/image1.jpg',
        timestamp: DateTime.now(),
        ingredients: [
          Ingredient(name: 'Chicken breast', calories: 165.0),
        ],
        calories: 300.0,
        protein: 35.0,
        carbs: 15.0,
        fat: 8.0,
      );

      final testItem2 = FoodItem(
        id: 'test-id-002',
        name: 'Protein Shake',
        imagePath: '/path/to/image2.jpg',
        timestamp: DateTime.now(),
        ingredients: [
          Ingredient(name: 'Whey protein', calories: 120.0),
        ],
        calories: 255.0,
        protein: 25.0,
        carbs: 30.0,
        fat: 3.0,
      );

      final testItem3 = FoodItem(
        id: 'test-id-003',
        name: 'Brown Rice Bowl',
        imagePath: '/path/to/image3.jpg',
        timestamp: DateTime.now(),
        ingredients: [
          Ingredient(name: 'Brown rice', calories: 215.0),
        ],
        calories: 476.0,
        protein: 40.0,
        carbs: 50.0,
        fat: 12.0,
      );

      await service.saveFoodItem(testItem1);
      await service.saveFoodItem(testItem2);
      await service.saveFoodItem(testItem3);

      final allItems = await service.loadAllFoodItems();

      expect(allItems.length, 3);
      expect(allItems.any((item) => item.id == 'test-id-001'), true);
      expect(allItems.any((item) => item.id == 'test-id-002'), true);
      expect(allItems.any((item) => item.id == 'test-id-003'), true);
    });

    test('Test 3: Filter items by date (same day only)', () async {
      final service = FoodHistoryService();

      final today = DateTime(2025, 10, 8, 10, 30);  // Fixed date with time
      final yesterday = DateTime(2025, 10, 7, 15, 45);
      final twoDaysAgo = DateTime(2025, 10, 6, 8, 0);

      final todayItem = FoodItem(
        id: 'today-001',
        name: 'Today\'s Lunch',
        imagePath: '/path/to/today.jpg',
        timestamp: today,
        ingredients: [Ingredient(name: 'Pasta', calories: 200.0)],
        calories: 200.0,
        protein: 8.0,
        carbs: 40.0,
        fat: 2.0,
      );

      final yesterdayItem = FoodItem(
        id: 'yesterday-001',
        name: 'Yesterday\'s Dinner',
        imagePath: '/path/to/yesterday.jpg',
        timestamp: yesterday,
        ingredients: [Ingredient(name: 'Pizza', calories: 285.0)],
        calories: 285.0,
        protein: 12.0,
        carbs: 36.0,
        fat: 10.0,
      );

      final twoDaysAgoItem = FoodItem(
        id: 'twodays-001',
        name: 'Two Days Ago Breakfast',
        imagePath: '/path/to/twodays.jpg',
        timestamp: twoDaysAgo,
        ingredients: [Ingredient(name: 'Oatmeal', calories: 150.0)],
        calories: 150.0,
        protein: 6.0,
        carbs: 27.0,
        fat: 3.0,
      );

      await service.saveFoodItem(todayItem);
      await service.saveFoodItem(yesterdayItem);
      await service.saveFoodItem(twoDaysAgoItem);

      // Filter by today (should ignore time and match only date)
      final todayItems = await service.getFoodItemsByDate(
        DateTime(2025, 10, 8, 23, 59),  // Different time, same day
      );
      expect(todayItems.length, 1);
      expect(todayItems[0].id, 'today-001');

      // Filter by yesterday
      final yesterdayItems = await service.getFoodItemsByDate(
        DateTime(2025, 10, 7, 0, 0),  // Different time, same day
      );
      expect(yesterdayItems.length, 1);
      expect(yesterdayItems[0].id, 'yesterday-001');

      // Filter by two days ago
      final twoDaysAgoItems = await service.getFoodItemsByDate(twoDaysAgo);
      expect(twoDaysAgoItems.length, 1);
      expect(twoDaysAgoItems[0].id, 'twodays-001');
    });

    test('Test 4: Delete item and verify removal', () async {
      final service = FoodHistoryService();

      final item1 = FoodItem(
        id: 'delete-test-001',
        name: 'Item 1',
        imagePath: '/path/to/image1.jpg',
        timestamp: DateTime.now(),
        ingredients: [],
        calories: 100.0,
        protein: 10.0,
        carbs: 10.0,
        fat: 5.0,
      );

      final item2 = FoodItem(
        id: 'delete-test-002',
        name: 'Item 2',
        imagePath: '/path/to/image2.jpg',
        timestamp: DateTime.now(),
        ingredients: [],
        calories: 200.0,
        protein: 20.0,
        carbs: 20.0,
        fat: 10.0,
      );

      await service.saveFoodItem(item1);
      await service.saveFoodItem(item2);

      // Delete item1
      await service.deleteFoodItem('delete-test-001');

      final afterDeletion = await service.loadAllFoodItems();

      expect(afterDeletion.length, 1);
      expect(afterDeletion[0].id, 'delete-test-002');
      expect(afterDeletion.any((item) => item.id == 'delete-test-001'), false);
    });

    test('Test 5a: Edge case - Empty storage', () async {
      final service = FoodHistoryService();

      final emptyItems = await service.loadAllFoodItems();

      expect(emptyItems, isEmpty);
    });

    test('Test 5b: Edge case - Duplicate ID replacement', () async {
      final service = FoodHistoryService();

      final originalItem = FoodItem(
        id: 'duplicate-test',
        name: 'Original Name',
        imagePath: '/original.jpg',
        timestamp: DateTime.now(),
        ingredients: [],
        calories: 100.0,
        protein: 10.0,
        carbs: 10.0,
        fat: 5.0,
      );

      final updatedItem = FoodItem(
        id: 'duplicate-test', // Same ID
        name: 'Updated Name',
        imagePath: '/updated.jpg',
        timestamp: DateTime.now(),
        ingredients: [],
        calories: 200.0,
        protein: 20.0,
        carbs: 20.0,
        fat: 10.0,
      );

      await service.saveFoodItem(originalItem);
      await service.saveFoodItem(updatedItem); // Should replace

      final items = await service.loadAllFoodItems();

      expect(items.length, 1);
      expect(items[0].id, 'duplicate-test');
      expect(items[0].name, 'Updated Name');
      expect(items[0].calories, 200.0);
    });

    test('Test 5c: Edge case - Clear all items', () async {
      final service = FoodHistoryService();

      // Add some items
      await service.saveFoodItem(FoodItem(
        id: 'clear-test-001',
        name: 'Test Item',
        imagePath: '/path/to/image.jpg',
        timestamp: DateTime.now(),
        ingredients: [],
        calories: 100.0,
        protein: 10.0,
        carbs: 10.0,
        fat: 5.0,
      ));

      // Verify item exists
      var items = await service.loadAllFoodItems();
      expect(items.length, 1);

      // Clear all
      await service.clearAll();

      // Verify empty
      items = await service.loadAllFoodItems();
      expect(items, isEmpty);
    });
  });
}
