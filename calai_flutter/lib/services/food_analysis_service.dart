import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../models/food_item.dart';
import '../models/ingredient.dart';

class FoodAnalysisService {
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'meta-llama/llama-4-scout-17b-16e-instruct';
  static const int _maxImageSize = 1024;
  static const int _jpegQuality = 70; // 0.7 quality as percentage

  final String _apiKey;

  FoodAnalysisService() : _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  /// Main entry point: analyzes food image and returns FoodItem
  Future<FoodItem> analyzeFood(File imageFile) async {
    if (_apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY not found in .env file');
    }

    try {
      // Step 1: Optimize image
      final optimizedImage = await _optimizeImage(imageFile);

      // Step 2: Encode to base64
      final base64Image = await _encodeImageToBase64(optimizedImage);

      // Step 3: Call OpenRouter API
      final response = await _callOpenRouterAPI(base64Image);

      // Step 4: Parse response to FoodItem
      final foodItem = await _parseResponseToFoodItem(response, imageFile.path);

      return foodItem;
    } catch (e) {
      throw Exception('Failed to analyze food: $e');
    }
  }

  /// Optimizes image: resize to max 1024px and compress to JPEG 0.7 quality
  Future<File> _optimizeImage(File imageFile) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if needed (maintain aspect ratio)
      if (image.width > _maxImageSize || image.height > _maxImageSize) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? _maxImageSize : null,
          height: image.height > image.width ? _maxImageSize : null,
        );
      }

      // Compress to JPEG with 0.7 quality
      final compressedBytes = img.encodeJpg(image, quality: _jpegQuality);

      // Write to temporary file
      final tempDir = imageFile.parent;
      final tempFile = File('${tempDir.path}/optimized_${imageFile.uri.pathSegments.last}');
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile;
    } catch (e) {
      throw Exception('Failed to optimize image: $e');
    }
  }

  /// Encodes image file to base64 string
  Future<String> _encodeImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Failed to encode image to base64: $e');
    }
  }

  /// Calls OpenRouter API with image and returns response
  Future<Map<String, dynamic>> _callOpenRouterAPI(String base64Image) async {
    final prompt = '''
Analyze this food image and provide detailed nutrition information.

Return your response as a JSON object with this exact structure:
{
  "name": "Name of the food/meal",
  "ingredients": [
    {"name": "ingredient name", "calories": calorie_value},
    ...
  ],
  "calories": total_calories,
  "protein": protein_in_grams,
  "carbs": carbs_in_grams,
  "fat": fat_in_grams
}

Be as accurate as possible. If you cannot identify the food, provide your best estimate.
Only return the JSON object, no additional text.
''';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': prompt,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Invalid API key. Please check your GROQ_API_KEY in .env');
      }

      if (response.statusCode != 200) {
        throw Exception('API request failed with status ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Failed to parse API response: $e');
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  /// Parses OpenRouter API response into FoodItem
  Future<FoodItem> _parseResponseToFoodItem(
    Map<String, dynamic> response,
    String imagePath,
  ) async {
    try {
      // Extract content from OpenRouter response
      final choices = response['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw Exception('No choices in API response');
      }

      final message = choices[0]['message'] as Map<String, dynamic>?;
      if (message == null) {
        throw Exception('No message in API response');
      }

      final content = message['content'] as String?;
      if (content == null || content.isEmpty) {
        throw Exception('No content in API response');
      }

      // Parse JSON from content (may have extra text, so extract JSON)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch == null) {
        throw Exception('No JSON found in response content');
      }

      final nutritionData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      // Parse ingredients
      final ingredientsList = (nutritionData['ingredients'] as List<dynamic>?)
              ?.map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [];

      // Create FoodItem
      final foodItem = FoodItem(
        id: const Uuid().v4(),
        name: nutritionData['name'] as String? ?? 'Unknown Food',
        imagePath: imagePath,
        timestamp: DateTime.now(),
        ingredients: ingredientsList,
        calories: (nutritionData['calories'] as num?)?.toDouble() ?? 0.0,
        protein: (nutritionData['protein'] as num?)?.toDouble() ?? 0.0,
        carbs: (nutritionData['carbs'] as num?)?.toDouble() ?? 0.0,
        fat: (nutritionData['fat'] as num?)?.toDouble() ?? 0.0,
      );

      return foodItem;
    } catch (e) {
      throw Exception('Failed to parse API response: $e');
    }
  }
}
