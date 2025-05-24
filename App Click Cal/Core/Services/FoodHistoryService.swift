import Foundation

class FoodHistoryService {
    private let userDefaults = UserDefaults.standard
    private let foodHistoryKey = "foodHistory"
    
    func saveFoodItem(_ foodItem: FoodItem) {
        var history = getAllFoodItems()
        history.append(foodItem)
        saveFoodHistory(history)
    }
    
    func getAllFoodItems() -> [FoodItem] {
        guard let data = userDefaults.data(forKey: foodHistoryKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([FoodItem].self, from: data)
        } catch {
            print("Error decoding food history: \(error)")
            return []
        }
    }
    
    func getFoodItemsForDate(_ date: Date) -> [FoodItem] {
        let calendar = Calendar.current
        return getAllFoodItems().filter { foodItem in
            calendar.isDate(foodItem.date, inSameDayAs: date)
        }
    }
    
    func deleteFoodItem(_ foodItem: FoodItem) {
        var history = getAllFoodItems()
        history.removeAll { $0.id == foodItem.id }
        saveFoodHistory(history)
    }
    
    private func saveFoodHistory(_ history: [FoodItem]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(history)
            userDefaults.set(data, forKey: foodHistoryKey)
        } catch {
            print("Error encoding food history: \(error)")
        }
    }
} 