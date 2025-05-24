import SwiftUI

struct FoodAnalysisView: View {
    @StateObject private var viewModel: FoodAnalysisViewModel
    @State private var showingCamera = false
    
    @State private var image : UIImage = UIImage()
    @State private var imageURL : String = ""
    @State private var dummyImageURL : String = ""
    
    init(openAIService: OpenAIService, foodHistoryService: FoodHistoryService) {
        _viewModel = StateObject(wrappedValue: FoodAnalysisViewModel(
            openAIService: openAIService,
            foodHistoryService: foodHistoryService
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let foodItem = viewModel.currentFoodItem {
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
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Take a photo of your food")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showingCamera = true
                        }) {
                            Text("Take Photo")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .navigationTitle("Food Analysis")
            .sheet(isPresented: $showingCamera) {
                ImagePicker(sourceType: .camera, selectedImage: self.$image, selectedImageURL: $imageURL, imageURL: self.$dummyImageURL)
            }
            .onChange(of: image) { newValue in
                if let imageData = newValue.jpegData(compressionQuality: 0.8) {
                    Task {
                        await viewModel.analyzeImage(imageData)
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
    }
}

struct NutrientCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
} 
