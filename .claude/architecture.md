# CalAI Flutter Migration - Architecture

## Tech Stack

### Framework
- **Flutter** (Android minSdk 29)
- Kotlin DSL build configuration (`build.gradle.kts`)

### API & AI
- **Groq API**: `https://api.groq.com/openai/v1/chat/completions`
- **Model**: `meta-llama/llama-4-scout-17b-16e-instruct` (vision-capable)
- **Response format**: OpenAI-compatible chat completions
- **Performance**: ~0.3-0.4s response time
- **Cost**: ~$0.0003 per analysis

### Dependencies (pubspec.yaml)
```yaml
image_picker: ^1.0.4        # Camera & gallery access
http: ^1.1.0                # API requests
shared_preferences: ^2.2.2  # Local storage
provider: ^6.1.1            # State management
table_calendar: ^3.0.9      # Calendar UI
flutter_dotenv: ^5.1.0      # Environment variables
```

### Android Permissions (AndroidManifest.xml)
- `CAMERA`
- `READ_EXTERNAL_STORAGE`
- `WRITE_EXTERNAL_STORAGE`
- `INTERNET`

---

## Folder Structure

```
calai_flutter/
├── lib/
│   ├── models/
│   │   ├── ingredient.dart
│   │   └── food_item.dart
│   ├── services/
│   │   ├── food_analysis_service.dart
│   │   └── food_history_service.dart
│   ├── providers/
│   │   └── food_analysis_provider.dart
│   ├── widgets/
│   │   ├── nutrient_card.dart
│   │   └── food_history_row.dart
│   ├── screens/
│   │   ├── food_analysis_screen.dart (upcoming)
│   │   ├── food_detail_screen.dart (upcoming)
│   │   └── food_history_screen.dart (upcoming)
│   └── main.dart
├── test/
│   ├── models_test.dart
│   ├── food_history_service_test.dart
│   ├── food_analysis_provider_test.dart
│   └── widgets_test.dart
├── .env (gitignored)
└── pubspec.yaml
```

---

## Models

### Ingredient (`lib/models/ingredient.dart`)

**Properties:**
- `name` (String): Ingredient name
- `calories` (double): Calorie count

**Methods:**
- `toJson()`: Serialize to JSON map
- `fromJson(Map<String, dynamic> json)`: Deserialize from JSON
- **Null safety**: Defaults to `''` and `0.0` for missing fields

**Usage:**
```dart
final ingredient = Ingredient(name: 'Chicken', calories: 165.0);
final json = ingredient.toJson();
final parsed = Ingredient.fromJson(json);
```

---

### FoodItem (`lib/models/food_item.dart`)

**Properties:**
- `id` (String): UUID generated with `uuid.v4()`
- `name` (String): Food name
- `timestamp` (DateTime): When food was analyzed (ISO8601 format)
- `imageData` (String): Base64-encoded image
- `ingredients` (List<Ingredient>): List of ingredients
- `totalNutrition` (Map<String, double>): Keys: 'calories', 'protein', 'carbs', 'fat'

**Methods:**
- `toJson()`: Serialize to JSON (includes nested ingredient serialization)
- `fromJson(Map<String, dynamic> json)`: Deserialize from JSON
- **Null safety**: Provides safe defaults for all fields
  - Strings → `''`
  - Numbers → `0.0`
  - Lists → `[]`
  - Maps → `{}`
  - DateTime → `DateTime.now()`

**Usage:**
```dart
final foodItem = FoodItem(
  name: 'Grilled Chicken',
  imageData: base64String,
  ingredients: [ingredient1, ingredient2],
  totalNutrition: {'calories': 614, 'protein': 55, 'carbs': 60, 'fat': 20}
);
final json = foodItem.toJson();
final parsed = FoodItem.fromJson(json);
```

---

## Services

### FoodAnalysisService (`lib/services/food_analysis_service.dart`)

**Purpose:** Analyze food images using Groq API (Llama 4 Scout)

**Key Methods:**

#### `Future<FoodItem> analyzeFood(File imageFile)`
Main entry point for food analysis.

**Flow:**
1. Optimize image (resize to 1024px max, JPEG 70% quality)
2. Encode to base64
3. Send HTTP POST to Groq API
4. Parse OpenAI-compatible response
5. Extract JSON using regex (handles extra text)
6. Return FoodItem with nutrition data

**Error Handling:**
- `401/403`: Throws "Authentication failed. Check your GROQ_API_KEY."
- `500+`: Throws "Server error occurred. Please try again."
- Network errors: Throws "Network error. Check your internet connection."
- Timeout (30s): Throws "Request timed out."
- Malformed JSON: Throws "Invalid response format from API."

**Image Optimization Settings:**
- Max dimension: 1024px (maintains aspect ratio)
- Quality: 70% JPEG compression
- Format: JPEG (converted from PNG if needed)

**API Request Format:**
```json
{
  "model": "meta-llama/llama-4-scout-17b-16e-instruct",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,..."
          }
        },
        {
          "type": "text",
          "text": "Analyze this food image and return JSON..."
        }
      ]
    }
  ],
  "temperature": 0.1
}
```

**Expected Response Structure:**
```json
{
  "name": "Food Name",
  "ingredients": [
    {"name": "Ingredient", "calories": 100}
  ],
  "totalNutrition": {
    "calories": 500,
    "protein": 30,
    "carbs": 40,
    "fat": 15
  }
}
```

---

### FoodHistoryService (`lib/services/food_history_service.dart`)

**Purpose:** Persist food items to SharedPreferences with date filtering and CRUD operations

**Key Methods:**

#### `Future<void> saveFoodItem(FoodItem item)`
Save a food item to SharedPreferences. If an item with the same ID exists, it will be replaced.

**Behavior:**
- Loads existing items
- Checks for duplicate ID and replaces if found
- Adds new item if ID is unique
- Saves all items back to storage

#### `Future<List<FoodItem>> loadAllFoodItems()`
Load all stored food items from SharedPreferences.

**Error Handling:**
- Returns empty list if no data exists
- Returns empty list if data is corrupt (logs error)
- Uses safe JSON parsing with FoodItem.fromJson()

#### `Future<List<FoodItem>> getFoodItemsByDate(DateTime date)`
Filter food items by date (ignores time component).

**Date Normalization:**
- Normalizes input date to `DateTime(year, month, day)`
- Compares only year, month, and day (ignores time)
- Returns items matching the same calendar day

#### `Future<void> deleteFoodItem(String id)`
Delete a food item by its unique ID.

**Behavior:**
- Loads all items
- Removes item with matching ID
- Saves updated list
- No error if ID doesn't exist

#### `Future<void> clearAll()`
Clear all food items from storage. Useful for testing.

**Storage Implementation:**
- **Storage key**: `'food_history'` (single key for all items)
- **Data format**: JSON-encoded list of FoodItem objects
- **Duplicate handling**: Same ID replaces existing item
- **Error strategy**: Graceful degradation (returns empty list on corrupt data)

---

## Providers

### FoodAnalysisProvider (`lib/providers/food_analysis_provider.dart`)

**Purpose:** Centralized state management for food analysis

**Architecture:**
- Extends `ChangeNotifier` from Provider package
- Manages instances of `FoodAnalysisService` and `FoodHistoryService`
- Supports dependency injection for testing

**State Variables:**
- `bool isLoading` - Tracks if API call is in progress
- `String? errorMessage` - Holds error message when operations fail
- `FoodItem? currentAnalysis` - Stores the most recent analysis result
- `List<FoodItem> foodHistory` - Holds all food items from storage
- `List<FoodItem> selectedDateItems` - Filtered items for selected date
- `DateTime selectedDate` - Currently selected date (defaults to today)

**Getters:**
- `bool get hasError` - Convenience check for error state
- `bool get hasCurrentAnalysis` - Convenience check for analysis result

**Key Methods:**

#### `Future<void> analyzeFood(File imageFile)`
Analyzes food image and saves result to storage.

**Flow:**
1. Sets `isLoading = true`, clears previous errors
2. Calls `FoodAnalysisService.analyzeFood(imageFile)`
3. On success: saves to storage via `FoodHistoryService.saveFoodItem()`
4. Updates `currentAnalysis` with result
5. Reloads all food items from storage
6. If analysis is for today, reloads today's items
7. On error: catches exception and sets `errorMessage`
8. Always sets `isLoading = false` and calls `notifyListeners()`

#### `Future<void> loadAllFoodItems()`
Loads all food items from storage.
- Calls `FoodHistoryService.loadAllFoodItems()`
- Updates `foodHistory` list
- Calls `notifyListeners()`

#### `Future<void> loadFoodItemsByDate(DateTime date)`
Filters food items by specific date.
- Updates `selectedDate`
- Calls `FoodHistoryService.getFoodItemsByDate(date)`
- Updates `selectedDateItems` list
- Calls `notifyListeners()`

#### `Future<void> deleteFoodItem(String id)`
Deletes a food item by ID.
- Calls `FoodHistoryService.deleteFoodItem(id)`
- Reloads all items and selected date items
- Calls `notifyListeners()`

#### `void clearError()`
Clears error message (useful for dismissing error dialogs).
- Sets `errorMessage = null`
- Calls `notifyListeners()`

#### `void clearCurrentAnalysis()`
Clears current analysis (useful for resetting state).
- Sets `currentAnalysis = null`
- Calls `notifyListeners()`

**Usage Pattern:**
```dart
// Initialize provider (typically in main.dart)
ChangeNotifierProvider(
  create: (_) => FoodAnalysisProvider(),
  child: MyApp(),
)

// Access in widgets
final provider = Provider.of<FoodAnalysisProvider>(context);
final provider = context.watch<FoodAnalysisProvider>(); // reactive
final provider = context.read<FoodAnalysisProvider>(); // non-reactive

// Trigger analysis
await provider.analyzeFood(imageFile);
if (provider.hasError) {
  showErrorDialog(provider.errorMessage);
}

// Show loading state
if (provider.isLoading) {
  return CircularProgressIndicator();
}

// Display results
if (provider.hasCurrentAnalysis) {
  return FoodDetailsView(provider.currentAnalysis!);
}
```

**Testing:**
- Supports dependency injection via constructor parameters
- Tests use `dotenv.testLoad()` to mock API keys
- All methods verified with 16 comprehensive test cases

---

## Widgets

### NutrientCard (`lib/widgets/nutrient_card.dart`)

**Purpose:** Display a single nutrition metric (calories, protein, carbs, fat)

**Design:** Replicates iOS NutrientCard from `FoodAnalysisView.swift:108-125`

**Properties:**
- `title` (String): Nutrient label (e.g., "Calories", "Protein")
- `value` (String): Nutrient value (e.g., "614", "55g")

**Layout:**
- Vertical Column: title on top, value below
- Light gray background (`Colors.grey.withOpacity(0.1)`)
- Rounded corners (10px)
- Padding: 12px
- Expanded widget for equal width distribution in horizontal rows

**Usage:**
```dart
Row(
  children: [
    NutrientCard(title: 'Calories', value: '614'),
    NutrientCard(title: 'Protein', value: '55g'),
    NutrientCard(title: 'Carbs', value: '60g'),
    NutrientCard(title: 'Fat', value: '20g'),
  ],
)
```

**Styling:**
- Title: 12px, gray color
- Value: 17px, bold

---

### FoodHistoryRow (`lib/widgets/food_history_row.dart`)

**Purpose:** Display a food item row in the history list

**Design:** Replicates iOS FoodHistoryRow from `FoodHistoryView.swift:58-94`

**Properties:**
- `foodItem` (FoodItem): The food item to display

**Layout:**
- Horizontal Row with three sections:
  1. **Image** (60x60): Rounded corners (8px) or fallback to `Icons.photo`
  2. **Details** (Expanded): Food name + calories text
  3. **Time**: Formatted timestamp

**Features:**
- **Image handling:** Checks if file exists at `imagePath`, displays image or fallback icon
- **Fallback icon:** `Icons.photo` on gray background when image missing
- **Calories format:** "{value} calories" (e.g., "614 calories") - integer only
- **Time format:** "12:30 PM" (12-hour format with AM/PM)
- **Text overflow:** Food name truncates with ellipsis if too long

**Helper Method:**
- `_formatTime(DateTime)` - Converts timestamp to readable 12-hour format

**Usage:**
```dart
ListView(
  children: foodItems.map((item) => FoodHistoryRow(foodItem: item)).toList(),
)
```

**Styling:**
- Food name: 17px, semibold
- Calories: 15px, gray
- Time: 12px, gray
- Vertical padding: 8px

---

## Critical Configuration

### Environment Variables (.env)
```
GROQ_API_KEY=your_api_key_here
```

**⚠️ CRITICAL:** This variable name must NOT be changed. The service file expects `GROQ_API_KEY`.

### API Configuration
- **Endpoint:** `https://api.groq.com/openai/v1/chat/completions`
- **Model:** `meta-llama/llama-4-scout-17b-16e-instruct`
- **Timeout:** 30 seconds
- **Temperature:** 0.1 (deterministic responses)

### Image Processing
- **Max dimension:** 1024px (width or height)
- **Quality:** 70% JPEG compression
- **Format:** JPEG (auto-converted)

---

## DO NOT Break These in Future Phases

### 1. Environment Variable Name
**DO NOT** change `GROQ_API_KEY` in:
- `.env` file
- `food_analysis_service.dart`

**Why:** Service file expects this exact name. Changing it will break API authentication.

### 2. API Endpoint & Model
**DO NOT** modify:
- API URL: `https://api.groq.com/openai/v1/chat/completions`
- Model name: `meta-llama/llama-4-scout-17b-16e-instruct`

**Why:** These have been tested and validated. Changing them requires re-testing the entire API integration.

### 3. Image Optimization Settings
**DO NOT** change:
- Max dimension: 1024px
- Quality: 70%

**Why:** These settings are optimized for API performance and cost. Higher settings increase latency and cost without significant quality gains.

### 4. JSON Parsing Logic
**DO NOT** remove the regex JSON extraction in `food_analysis_service.dart`.

**Why:** The model sometimes returns extra text around the JSON. Regex extraction ensures we parse only the JSON block.

### 5. HTTP Timeout
**DO NOT** extend the 30-second timeout without thorough testing.

**Why:** 30s is sufficient for normal operations. Longer timeouts degrade user experience.

### 6. DateTime Serialization Format
**DO NOT** change `toIso8601String()` / `DateTime.parse()` in FoodItem.

**Why:** ISO8601 is the standard for JSON date serialization. Changing it breaks persistence.

### 7. Service Integration Pattern
**When integrating with Provider/UI:**
- Pass `File` object to `analyzeFood()` (not base64)
- Always wrap calls in try-catch
- Show loading state during API call
- Handle exception messages for user display
- Service returns FoodItem with all nutrition data populated

**Why:** This pattern ensures proper error handling and user feedback.

### 8. Storage Service Key Name
**DO NOT** change `'food_history'` storage key in `food_history_service.dart`.

**Why:** Changing the key name will cause all existing saved food items to become inaccessible. Users would lose their history.

### 9. Date Filtering Logic
**DO NOT** change the date normalization logic in `getFoodItemsByDate()`.

**Current implementation:**
```dart
final normalizedDate = DateTime(date.year, date.month, date.day);
```

**Why:** This ensures date filtering ignores time components. Changing it would break calendar filtering in the UI.

### 10. FoodHistoryService Integration Pattern
**When integrating with Provider/UI:**
- Call `saveFoodItem()` immediately after successful `analyzeFood()` to persist results
- Use `getFoodItemsByDate()` for calendar-based filtering (not manual filtering)
- Handle empty lists gracefully (no items for selected date)
- Don't assume `deleteFoodItem()` will throw an error for missing IDs

**Why:** This pattern ensures data persistence works correctly and UX remains smooth.

### 11. FoodAnalysisProvider State Management Pattern
**DO NOT:**
- Forget to call `notifyListeners()` after state changes
- Modify state directly without using provider methods
- Create multiple provider instances (use single instance via ChangeNotifierProvider)
- Access `_analysisService` or `_historyService` directly from UI (use provider methods)

**DO:**
- Always use `context.watch<FoodAnalysisProvider>()` for reactive UI updates
- Use `context.read<FoodAnalysisProvider>()` for one-time actions (button clicks)
- Check `provider.isLoading` before triggering operations
- Check `provider.hasError` and display `provider.errorMessage` to users
- Call `provider.clearError()` after showing error to user
- Handle null cases for `provider.currentAnalysis` and empty lists

**Why:** This pattern ensures reactive UI updates work correctly and prevents state synchronization issues.

---

## Breaking Change Checklist

Before modifying any architecture component, ask:
1. Does this change affect environment variables?
2. Does this change affect API endpoints or models?
3. Does this change affect serialization/deserialization?
4. Does this change affect image processing?
5. Does this change affect error handling?
6. Does this change affect storage keys or data persistence?
7. Does this change affect date filtering logic?

If **YES** to any → **TEST THOROUGHLY** before proceeding.
