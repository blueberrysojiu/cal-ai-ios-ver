import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../services/food_analysis_service.dart';
import '../services/food_history_service.dart';

/// Provider for managing food analysis state and operations
///
/// This provider serves as the central state management layer that:
/// - Connects FoodAnalysisService and FoodHistoryService
/// - Manages loading/error states
/// - Triggers API calls and saves results to storage
/// - Notifies listeners on state changes
class FoodAnalysisProvider extends ChangeNotifier {
  late final FoodAnalysisService _analysisService;
  late final FoodHistoryService _historyService;

  /// Constructor with optional service injection for testing
  FoodAnalysisProvider({
    FoodAnalysisService? analysisService,
    FoodHistoryService? historyService,
  }) {
    _analysisService = analysisService ?? FoodAnalysisService();
    _historyService = historyService ?? FoodHistoryService();
  }

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  FoodItem? _currentAnalysis;
  List<FoodItem> _foodHistory = [];
  List<FoodItem> _selectedDateItems = [];
  DateTime _selectedDate = DateTime.now();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FoodItem? get currentAnalysis => _currentAnalysis;
  List<FoodItem> get foodHistory => _foodHistory;
  List<FoodItem> get selectedDateItems => _selectedDateItems;
  DateTime get selectedDate => _selectedDate;
  bool get hasError => _errorMessage != null;
  bool get hasCurrentAnalysis => _currentAnalysis != null;

  /// Analyze food image and save result to storage
  ///
  /// This method:
  /// 1. Sets loading state
  /// 2. Calls FoodAnalysisService to analyze the image
  /// 3. Saves the result to storage
  /// 4. Updates the current analysis and history
  /// 5. Handles any errors gracefully
  Future<void> analyzeFood(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call API to analyze food
      final foodItem = await _analysisService.analyzeFood(imageFile);

      // Save to storage
      await _historyService.saveFoodItem(foodItem);

      // Update current analysis
      _currentAnalysis = foodItem;

      // Reload history to include new item
      await loadAllFoodItems();

      // If the analyzed item is for today, reload today's items
      final today = DateTime.now();
      final itemDate = DateTime(
        foodItem.timestamp.year,
        foodItem.timestamp.month,
        foodItem.timestamp.day,
      );
      final todayNormalized = DateTime(today.year, today.month, today.day);

      if (itemDate == todayNormalized) {
        await loadFoodItemsByDate(_selectedDate);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all food items from storage
  Future<void> loadAllFoodItems() async {
    try {
      _foodHistory = await _historyService.loadAllFoodItems();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load food history: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load food items for a specific date
  Future<void> loadFoodItemsByDate(DateTime date) async {
    try {
      _selectedDate = date;
      _selectedDateItems = await _historyService.getFoodItemsByDate(date);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load food items for selected date: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Delete a food item by ID
  Future<void> deleteFoodItem(String id) async {
    try {
      await _historyService.deleteFoodItem(id);

      // Reload all items
      await loadAllFoodItems();

      // Reload selected date items
      await loadFoodItemsByDate(_selectedDate);

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete food item: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Clear error message (useful for dismissing error dialogs)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear current analysis (useful for resetting state)
  void clearCurrentAnalysis() {
    _currentAnalysis = null;
    notifyListeners();
  }
}
