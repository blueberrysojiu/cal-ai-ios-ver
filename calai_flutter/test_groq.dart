import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

void main() async {
  print('=== Groq API Test (Llama 4 Scout) ===\n');

  // Read API key from .env
  final envFile = File('.env');
  final envContent = await envFile.readAsString();
  final apiKeyMatch = RegExp(r'GROQ_API_KEY=(.+)').firstMatch(envContent);
  final apiKey = apiKeyMatch?.group(1)?.trim();

  if (apiKey == null || apiKey.isEmpty) {
    print('ERROR: GROQ_API_KEY not configured in .env file');
    exit(1);
  }

  print('✓ API key loaded: ${apiKey.substring(0, 10)}...');

  // Load test image
  final testImage = File(r'c:\Users\JI\Downloads\calai test.jpg');
  print('✓ Test image: ${testImage.path}');

  if (!await testImage.exists()) {
    print('ERROR: Test image not found');
    exit(1);
  }

  final originalSize = await testImage.length();
  print('✓ Original image size: ${(originalSize / 1024).toStringAsFixed(2)} KB');

  // Optimize image
  print('\n--- Optimizing image ---');
  final bytes = await testImage.readAsBytes();
  img.Image? image = img.decodeImage(bytes);

  if (image == null) {
    print('ERROR: Failed to decode image');
    exit(1);
  }

  print('Original dimensions: ${image.width}x${image.height}');

  // Resize if larger than 1024px
  if (image.width > 1024 || image.height > 1024) {
    image = img.copyResize(
      image,
      width: image.width > image.height ? 1024 : null,
      height: image.height > image.width ? 1024 : null,
    );
    print('Resized to: ${image.width}x${image.height}');
  }

  // Encode as JPEG with 70% quality
  final optimizedBytes = img.encodeJpg(image, quality: 70);
  final base64Image = base64Encode(optimizedBytes);

  print('✓ Optimized size: ${(optimizedBytes.length / 1024).toStringAsFixed(2)} KB');
  print('✓ Reduction: ${((1 - optimizedBytes.length / originalSize) * 100).toStringAsFixed(1)}%');
  print('✓ Base64 length: ${base64Image.length} characters');

  // Make API request
  print('\n--- Calling Groq API ---');
  print('Model: meta-llama/llama-4-scout-17b-16e-instruct');

  final requestBody = {
    'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
    'messages': [
      {
        'role': 'user',
        'content': [
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
          },
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$base64Image',
            }
          }
        ]
      }
    ],
    'temperature': 0.7,
  };

  try {
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 60));

    print('✓ Response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      print('ERROR: API request failed');
      print('Response: ${response.body}');
      exit(1);
    }

    final responseData = jsonDecode(response.body);
    print('\n--- API Response ---');
    print(JsonEncoder.withIndent('  ').convert(responseData));

    // Extract content
    final content = responseData['choices']?[0]?['message']?['content'];
    if (content == null) {
      print('ERROR: Invalid response structure');
      exit(1);
    }

    print('\n--- Extracted Content ---');
    print(content);

    // Parse food data
    String jsonString = content.toString().trim();
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(jsonString);
    if (jsonMatch != null) {
      jsonString = jsonMatch.group(0)!;
    }

    final foodData = jsonDecode(jsonString);

    print('\n--- ✅ Parsed Food Data ---');
    print('Name: ${foodData['name']}');
    print('Calories: ${foodData['calories']}');
    print('Protein: ${foodData['protein']}g');
    print('Carbs: ${foodData['carbs']}g');
    print('Fat: ${foodData['fat']}g');
    print('\nIngredients:');
    for (var ingredient in foodData['ingredients']) {
      print('  - ${ingredient['name']}: ${ingredient['calories']} cal');
    }

    print('\n=== ✅ ALL TESTS PASSED ===');
  } catch (e) {
    print('\nERROR: $e');
    exit(1);
  }
}
