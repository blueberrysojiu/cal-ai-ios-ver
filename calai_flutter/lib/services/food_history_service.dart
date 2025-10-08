import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';

class FoodHistoryService {
  static const String _storageKey = 'food_history';

  // Save a food item to SharedPreferences
  Future<void> saveFoodItem(FoodItem item) async {
    try {
      // Load existing items
      final items = await loadAllFoodItems();

      // Check if item with same ID exists and replace it, otherwise add new
      final existingIndex = items.indexWhere((i) => i.id == item.id);
      if (existingIndex != -1) {
        items[existingIndex] = item;
      } else {
        items.add(item);
      }

      // Save all items
      await _saveAllItems(items);
    } catch (e) {
      throw Exception('Failed to save food item: $e');
    }
  }

  // Load all food items from SharedPreferences
  Future<List<FoodItem>> loadAllFoodItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      // Return empty list if no data exists
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      // Decode JSON string to list
      final List<dynamic> jsonList = json.decode(jsonString);

      // Convert each JSON object to FoodItem
      return jsonList
          .map((jsonItem) => FoodItem.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list if data is corrupt
      print('Error loading food items (corrupt data): $e');
      return [];
    }
  }

  // Get food items for a specific date (same day only)
  Future<List<FoodItem>> getFoodItemsByDate(DateTime date) async {
    try {
      final allItems = await loadAllFoodItems();

      // Normalize date to ignore time
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Filter items by date
      return allItems.where((item) {
        final itemDate = DateTime(
          item.timestamp.year,
          item.timestamp.month,
          item.timestamp.day,
        );
        return itemDate == normalizedDate;
      }).toList();
    } catch (e) {
      throw Exception('Failed to filter food items by date: $e');
    }
  }

  // Delete a food item by ID
  Future<void> deleteFoodItem(String id) async {
    try {
      // Load existing items
      final items = await loadAllFoodItems();

      // Remove item with matching ID
      items.removeWhere((item) => item.id == id);

      // Save updated list
      await _saveAllItems(items);
    } catch (e) {
      throw Exception('Failed to delete food item: $e');
    }
  }

  // Private helper method to save all items
  Future<void> _saveAllItems(List<FoodItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert list of FoodItems to JSON
      final jsonList = items.map((item) => item.toJson()).toList();

      // Encode to JSON string and save
      final jsonString = json.encode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save items to storage: $e');
    }
  }

  // Clear all food items (useful for testing)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }
}
