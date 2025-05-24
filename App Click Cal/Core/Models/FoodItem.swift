import Foundation

struct FoodItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var imageData: Data?
    var date: Date
    var ingredients: [Ingredient]
    
    init(id: UUID = UUID(), name: String, calories: Double, protein: Double, carbs: Double, fat: Double, imageData: Data? = nil, date: Date = Date(), ingredients: [Ingredient] = []) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.imageData = imageData
        self.date = date
        self.ingredients = ingredients
    }
}

struct Ingredient: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var unit: String
    var calories: Double
    
    init(id: UUID = UUID(), name: String, amount: Double, unit: String, calories: Double) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.calories = calories
    }
} 