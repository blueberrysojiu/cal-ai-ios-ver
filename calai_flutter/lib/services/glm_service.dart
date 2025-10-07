import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import '../models/food_item.dart';

class GlmService {
  static const String _apiUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String _model = 'glm-4v-flash';
  static const int _maxImageSize = 1024;
  static const int _jpegQuality = 70;

  /// Optimize image: resize to max 1024px and compress as JPEG
  Future<String> _optimizeImage(File imageFile) async {
    // Read image bytes
    final bytes = await imageFile.readAsBytes();

    // Decode image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize if larger than max size (maintain aspect ratio)
    if (image.width > _maxImageSize || image.height > _maxImageSize) {
      image = img.copyResize(
        image,
        width: image.width > image.height ? _maxImageSize : null,
        height: image.height > image.width ? _maxImageSize : null,
      );
    }

    // Encode as JPEG with quality 0.7 (70%)
    final optimizedBytes = img.encodeJpg(image, quality: _jpegQuality);

    // Convert to base64
    return base64Encode(optimizedBytes);
  }

  /// Analyze food image using GLM-4.5V API
  Future<FoodItem> analyzeFood(File imageFile) async {
    try {
      // Get API key from .env
      final apiKey = dotenv.env['GLM_API_KEY'];
      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
        throw Exception('GLM_API_KEY not configured in .env file');
      }

      // Optimize image
      print('Optimizing image...');
      final base64Image = await _optimizeImage(imageFile);
      print('Image optimized. Base64 length: ${base64Image.length}');

      // Construct API request
      final requestBody = {
        'model': _model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                }
              },
              {
                'type': 'text',
                'text': '''Analyze this food image and return a JSON object with the following structure:
{
  "name": "name of the dish or main food item",
  "ingredients": [
    {"name": "ingredient name", "calories": estimated_calories_as_number}
  ],
  "calories": total_calories_as_number,
  "protein": protein_in_grams_as_number,
  "carbs": carbs_in_grams_as_number,
  "fat": fat_in_grams_as_number
}

Return ONLY the JSON object, no additional text or explanation.'''
              }
            ]
          }
        ],
        'temperature': 0.7,
      };

      print('Sending request to GLM API...');
      print('Request body: ${jsonEncode(requestBody).substring(0, 500)}...');

      // Make API request
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check for HTTP errors
      if (response.statusCode != 200) {
        throw Exception('API request failed with status ${response.statusCode}: ${response.body}');
      }

      // Parse response
      final responseData = jsonDecode(response.body);

      // Extract the content from GLM response
      // Expected structure: {"choices": [{"message": {"content": "..."}}]}
      final content = responseData['choices']?[0]?['message']?['content'];
      if (content == null) {
        throw Exception('Invalid API response structure: $responseData');
      }

      print('API content: $content');

      // Parse the JSON content
      // The content might have extra text, so extract JSON using regex
      String jsonString = content.toString().trim();

      // Try to extract JSON object if there's extra text
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(jsonString);
      if (jsonMatch != null) {
        jsonString = jsonMatch.group(0)!;
      }

      final foodData = jsonDecode(jsonString);

      // Add required fields that aren't in the API response
      foodData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      foodData['imagePath'] = imageFile.path;
      foodData['timestamp'] = DateTime.now().toIso8601String();

      // Create FoodItem from the complete data
      return FoodItem.fromJson(foodData);

    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Failed to parse response: $e');
    } catch (e) {
      throw Exception('Food analysis failed: $e');
    }
  }
}
