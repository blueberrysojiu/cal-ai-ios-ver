import Foundation
import SwiftUI

@MainActor
class FoodAnalysisViewModel: ObservableObject {
    @Published var currentFoodItem: FoodItem?
    @Published var isAnalyzing = false
    @Published var error: String?
    
    private let openAIService: OpenAIService
    private let foodHistoryService: FoodHistoryService
    
    init(openAIService: OpenAIService, foodHistoryService: FoodHistoryService) {
        self.openAIService = openAIService
        self.foodHistoryService = foodHistoryService
    }
    
    func analyzeImage(_ imageData: Data) async {
        isAnalyzing = true
        error = nil
        do {
            let foodItem = try await openAIService.analyzeFoodImage(imageData)
            currentFoodItem = foodItem
            foodHistoryService.saveFoodItem(foodItem)
        } catch {
            print(String(describing: error))
            self.error = error.localizedDescription
        }
        isAnalyzing = false
    }
    
    func updateFoodItem(_ foodItem: FoodItem) {
        currentFoodItem = foodItem
        foodHistoryService.saveFoodItem(foodItem)
    }
    
    func deleteFoodItem(_ foodItem: FoodItem) {
        foodHistoryService.deleteFoodItem(foodItem)
        if currentFoodItem?.id == foodItem.id {
            currentFoodItem = nil
        }
    }
    
    func getFoodItemsForDate(_ date: Date) -> [FoodItem] {
        foodHistoryService.getFoodItemsForDate(date)
    }
} 
