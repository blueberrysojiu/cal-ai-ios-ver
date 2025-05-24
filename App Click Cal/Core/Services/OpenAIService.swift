import Foundation
import UIKit

enum OpenAIError: Error {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case decodingError
    case invalidImageData
    case invalidAPIKey
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .apiError(let message):
            return "API Error: \(message)"
        case .decodingError:
            return "Failed to decode API response"
        case .invalidImageData:
            return "Invalid image data"
        case .invalidAPIKey:
            return "Invalid API key"
        }
    }
}

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
        print("OpenAIService initialized with API key length: \(apiKey.count)")
    }
    
    private func optimizeImage(_ imageData: Data) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }
        
        // Calculate new size while maintaining aspect ratio
        let maxDimension: CGFloat = 1024
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Compress the image
        return resizedImage?.jpegData(compressionQuality: 0.7)
    }
    
    func analyzeFoodImage(_ imageData: Data) async throws -> FoodItem {
        // Validate API key
        guard !apiKey.isEmpty else {
            print("Error: API key is empty")
            throw OpenAIError.invalidAPIKey
        }
        
        // Validate and optimize image data
        guard let optimizedImageData = optimizeImage(imageData) else {
            print("Error: Failed to optimize image")
            throw OpenAIError.invalidImageData
        }
        
        guard let url = URL(string: baseURL) else {
            print("Error: Invalid URL - \(baseURL)")
            throw OpenAIError.invalidURL
        }
        
        let base64Image = optimizedImageData.base64EncodedString()
        print("Original image size: \(imageData.count) bytes")
        print("Optimized image size: \(optimizedImageData.count) bytes")
        print("Base64 image length: \(base64Image.count) characters")
        
        let prompt = """
        You are a food analysis expert. Analyze this food image and provide detailed nutritional information.
        Focus on identifying the food items and their nutritional content.
        
        Please provide the information in the following JSON format:
        {
            "name": "Main food item name",
            "calories": total calories as a number,
            "protein": protein in grams as a number,
            "carbs": carbohydrates in grams as a number,
            "fat": fat in grams as a number,
            "ingredients": [
                {
                    "name": "ingredient name",
                    "amount": quantity as a number,
                    "unit": "unit of measurement (g, ml, etc.)",
                    "calories": calories for this ingredient as a number
                }
            ]
        }
        
        Important guidelines:
        1. Be specific with food names
        2. Provide accurate measurements
        3. Include all visible ingredients
        4. Use standard units (g for solids, ml for liquids)
        5. Ensure all numbers are actual numbers, not strings
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",  // Updated to latest model
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            print("Request body size: \(request.httpBody?.count ?? 0) bytes")
        } catch {
            print("Error serializing request body: \(error)")
            throw OpenAIError.invalidResponse
        }
        
        do {
            print("Sending request to OpenAI API...")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid HTTP response")
                throw OpenAIError.invalidResponse
            }
            
            print("Received response with status code: \(httpResponse.statusCode)")
            
            // Print response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("API Response: \(responseString)")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                    print("API Error: \(errorResponse.error.message)")
                    throw OpenAIError.apiError(errorResponse.error.message)
                }
                print("HTTP Error: \(httpResponse.statusCode)")
                throw OpenAIError.apiError("HTTP \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
            
            guard let jsonString = openAIResponse.choices.first?.message.content,
                  let jsonData = jsonString.data(using: .utf8) else {
                print("Error: Failed to extract content from response")
                throw OpenAIError.decodingError
            }
            
            // Print parsed JSON for debugging
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Parsed JSON: \(jsonString)")
            }
            
            let foodData = try decoder.decode(FoodAnalysisResponse.self, from: jsonData)
            
            return FoodItem(
                name: foodData.name,
                calories: foodData.calories,
                protein: foodData.protein,
                carbs: foodData.carbs,
                fat: foodData.fat,
                imageData: imageData,
                ingredients: foodData.ingredients.map { ingredient in
                    Ingredient(
                        name: ingredient.name,
                        amount: ingredient.amount,
                        unit: ingredient.unit,
                        calories: ingredient.calories
                    )
                }
            )
        } catch let error as OpenAIError {
            print("OpenAI Error: \(error.localizedDescription)")
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw OpenAIError.apiError(error.localizedDescription)
        }
    }
}

// Response models
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

struct OpenAIErrorResponse: Codable {
    let error: Error
    
    struct Error: Codable {
        let message: String
    }
}

struct FoodAnalysisResponse: Codable {
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let ingredients: [IngredientResponse]
    
    struct IngredientResponse: Codable {
        let name: String
        let amount: Double
        let unit: String
        let calories: Double
    }
} 