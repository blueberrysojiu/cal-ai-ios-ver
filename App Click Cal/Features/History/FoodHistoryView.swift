import SwiftUI

struct FoodHistoryView: View {
    @StateObject private var viewModel: FoodAnalysisViewModel
    @State private var selectedDate = Date()
    
    init(openAIService: OpenAIService, foodHistoryService: FoodHistoryService) {
        _viewModel = StateObject(wrappedValue: FoodAnalysisViewModel(
            openAIService: openAIService,
            foodHistoryService: foodHistoryService
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                let foodItems = viewModel.getFoodItemsForDate(selectedDate)
                
                if foodItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No food entries for this date")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(foodItems) { foodItem in
                            NavigationLink(destination: FoodDetailView(foodItem: foodItem)) {
                                FoodHistoryRow(foodItem: foodItem)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteFoodItem(foodItems[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Food History")
        }
    }
}

struct FoodHistoryRow: View {
    let foodItem: FoodItem
    
    var body: some View {
        HStack {
            if let imageData = foodItem.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 30))
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading) {
                Text(foodItem.name)
                    .font(.headline)
                Text("\(Int(foodItem.calories)) calories")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(foodItem.date, style: .time)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

struct FoodDetailView: View {
    let foodItem: FoodItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageData = foodItem.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(foodItem.name)
                        .font(.title)
                        .bold()
                    
                    HStack {
                        NutrientCard(title: "Calories", value: "\(Int(foodItem.calories))")
                        NutrientCard(title: "Protein", value: "\(Int(foodItem.protein))g")
                        NutrientCard(title: "Carbs", value: "\(Int(foodItem.carbs))g")
                        NutrientCard(title: "Fat", value: "\(Int(foodItem.fat))g")
                    }
                    
                    Text("Ingredients")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(foodItem.ingredients) { ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            Text("\(ingredient.amount) \(ingredient.unit)")
                            Text("(\(Int(ingredient.calories)) cal)")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Food Details")
    }
} 