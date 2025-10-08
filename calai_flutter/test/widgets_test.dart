import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calai_flutter/widgets/nutrient_card.dart';
import 'package:calai_flutter/widgets/food_history_row.dart';
import 'package:calai_flutter/models/food_item.dart';
import 'package:calai_flutter/models/ingredient.dart';

void main() {
  group('NutrientCard Widget Tests', () {
    testWidgets('NutrientCard renders with correct title and value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                NutrientCard(title: 'Calories', value: '614'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('614'), findsOneWidget);
    });

    testWidgets('NutrientCard renders with protein value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                NutrientCard(title: 'Protein', value: '55g'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('55g'), findsOneWidget);
    });

    testWidgets('NutrientCard displays 4 cards in horizontal row',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                NutrientCard(title: 'Calories', value: '614'),
                NutrientCard(title: 'Protein', value: '55g'),
                NutrientCard(title: 'Carbs', value: '60g'),
                NutrientCard(title: 'Fat', value: '20g'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
      expect(find.byType(NutrientCard), findsNWidgets(4));
    });

    testWidgets('NutrientCard handles zero values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                NutrientCard(title: 'Calories', value: '0'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });
  });

  group('FoodHistoryRow Widget Tests', () {
    testWidgets('FoodHistoryRow renders with complete FoodItem',
        (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-123',
        name: 'Grilled Chicken',
        imagePath: '', // Empty path to test fallback
        timestamp: DateTime(2025, 10, 9, 12, 30),
        ingredients: [
          Ingredient(name: 'Chicken', calories: 250.0),
        ],
        calories: 614.0,
        protein: 55.0,
        carbs: 60.0,
        fat: 20.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryRow(foodItem: foodItem),
          ),
        ),
      );

      expect(find.text('Grilled Chicken'), findsOneWidget);
      expect(find.text('614 calories'), findsOneWidget);
      expect(find.text('12:30 PM'), findsOneWidget);
    });

    testWidgets('FoodHistoryRow shows fallback icon when imagePath is empty',
        (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-456',
        name: 'Test Food',
        imagePath: '', // Empty path
        timestamp: DateTime(2025, 10, 9, 15, 45),
        ingredients: [],
        calories: 500.0,
        protein: 30.0,
        carbs: 40.0,
        fat: 15.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryRow(foodItem: foodItem),
          ),
        ),
      );

      // Verify fallback icon is displayed
      expect(find.byIcon(Icons.photo), findsOneWidget);
    });

    testWidgets('FoodHistoryRow shows fallback icon for non-existent file path',
        (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-789',
        name: 'Another Food',
        imagePath: '/non/existent/path/image.jpg', // Invalid path
        timestamp: DateTime(2025, 10, 9, 9, 15),
        ingredients: [],
        calories: 350.0,
        protein: 20.0,
        carbs: 30.0,
        fat: 10.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryRow(foodItem: foodItem),
          ),
        ),
      );

      // Verify fallback icon is displayed
      expect(find.byIcon(Icons.photo), findsOneWidget);
    });

    testWidgets('FoodHistoryRow formats time correctly (AM)',
        (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-am',
        name: 'Breakfast',
        imagePath: '',
        timestamp: DateTime(2025, 10, 9, 8, 5), // 8:05 AM
        ingredients: [],
        calories: 300.0,
        protein: 15.0,
        carbs: 40.0,
        fat: 8.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryRow(foodItem: foodItem),
          ),
        ),
      );

      expect(find.text('8:05 AM'), findsOneWidget);
    });

    testWidgets('FoodHistoryRow formats time correctly (PM)',
        (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-pm',
        name: 'Dinner',
        imagePath: '',
        timestamp: DateTime(2025, 10, 9, 19, 30), // 7:30 PM
        ingredients: [],
        calories: 700.0,
        protein: 50.0,
        carbs: 70.0,
        fat: 25.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryRow(foodItem: foodItem),
          ),
        ),
      );

      expect(find.text('7:30 PM'), findsOneWidget);
    });

    testWidgets('FoodHistoryRow formats time correctly (midnight)',
        (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-midnight',
        name: 'Late Snack',
        imagePath: '',
        timestamp: DateTime(2025, 10, 9, 0, 15), // 12:15 AM
        ingredients: [],
        calories: 150.0,
        protein: 5.0,
        carbs: 20.0,
        fat: 5.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryRow(foodItem: foodItem),
          ),
        ),
      );

      expect(find.text('12:15 AM'), findsOneWidget);
    });

    testWidgets('FoodHistoryRow formats time correctly (noon)',
        (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-noon',
        name: 'Lunch',
        imagePath: '',
        timestamp: DateTime(2025, 10, 9, 12, 0), // 12:00 PM
        ingredients: [],
        calories: 500.0,
        protein: 30.0,
        carbs: 50.0,
        fat: 15.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryRow(foodItem: foodItem),
          ),
        ),
      );

      expect(find.text('12:00 PM'), findsOneWidget);
    });

    testWidgets('FoodHistoryRow handles long food names with ellipsis',
        (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-long',
        name: 'Extremely Long Food Name That Should Be Truncated With Ellipsis',
        imagePath: '',
        timestamp: DateTime(2025, 10, 9, 14, 20),
        ingredients: [],
        calories: 450.0,
        protein: 25.0,
        carbs: 45.0,
        fat: 12.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryRow(foodItem: foodItem),
          ),
        ),
      );

      // Verify the text exists (it will be truncated visually)
      expect(
          find.text(
              'Extremely Long Food Name That Should Be Truncated With Ellipsis'),
          findsOneWidget);
    });

    testWidgets('FoodHistoryRow formats calories as integer',
        (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-decimal',
        name: 'Salad',
        imagePath: '',
        timestamp: DateTime(2025, 10, 9, 13, 0),
        ingredients: [],
        calories: 324.7, // Decimal value
        protein: 12.0,
        carbs: 35.0,
        fat: 8.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodHistoryRow(foodItem: foodItem),
          ),
        ),
      );

      // Should display as integer (324 calories, not 324.7)
      expect(find.text('324 calories'), findsOneWidget);
    });
  });
}
