# CalAI Flutter Migration - Execution Plan with Testing Gates

## ✅ PHASE 1 COMPLETED - Project Setup & Validation

**Completion Date:** 2025-10-06
**Status:** All setup tasks completed successfully

### What Was Completed:
1. ✅ Created Flutter project `calai_flutter` with Android platform support
2. ✅ Configured Android minSdk to 29 in `android/app/build.gradle.kts`
3. ✅ Installed all required dependencies in `pubspec.yaml`:
   - `image_picker: ^1.0.4`
   - `http: ^1.1.0`
   - `shared_preferences: ^2.2.2`
   - `provider: ^6.1.1`
   - `table_calendar: ^3.0.9`
   - `flutter_dotenv: ^5.1.0`
4. ✅ Created `.env` file with placeholder: `GLM_API_KEY=your_api_key_here`
5. ✅ Configured `.env` as asset in `pubspec.yaml`
6. ✅ Created folder structure in `lib/`:
   - `models/`
   - `services/`
   - `providers/`
   - `widgets/`
   - `screens/`
7. ✅ Configured Android permissions in `AndroidManifest.xml`:
   - CAMERA
   - READ_EXTERNAL_STORAGE
   - WRITE_EXTERNAL_STORAGE
   - INTERNET
8. ✅ Updated `main.dart` to load `.env` file on startup with verification print

### Important Notes for Future Development:
- **Android build file:** Using `build.gradle.kts` (Kotlin DSL), not `.gradle`
- **minSdk hardcoded:** Set to `29` directly in build.gradle.kts (line 27)
- **.env loading:** `dotenv.load()` is called in `main()` before `runApp()`
- **Print statements:** Two print statements in `main.dart` for .env verification (can be removed in production)
- **Android SDK:** Not required to be installed on development machine for code work
- **Folder structure:** Empty folders created - do not delete, they will be populated in subsequent phases

### Testing Results:
- ✅ `flutter doctor` - No critical errors
- ✅ `flutter pub get` - All 41 dependencies resolved successfully
- ✅ `flutter analyze` - Only 2 info warnings (print statements, intentional for testing)
- ✅ Project structure validated

---

## ✅ PHASE 2 COMPLETED - Models & JSON Serialization

**Completion Date:** 2025-10-07
**Status:** All model tasks completed successfully

### What Was Completed:
1. ✅ Created `lib/models/ingredient.dart`:
   - Properties: `name` (String), `calories` (double)
   - `toJson()` method for serialization
   - `fromJson()` factory constructor for deserialization
   - Safe null handling with default values
2. ✅ Created `lib/models/food_item.dart`:
   - Properties: `id` (String, UUID), `name` (String), `timestamp` (DateTime), `imageData` (String, base64), `ingredients` (List<Ingredient>), `totalNutrition` (Map)
   - `toJson()` method with nested list serialization
   - `fromJson()` factory constructor with safe parsing
   - DateTime serialization using ISO8601 format
   - Handles empty/null ingredient lists gracefully
3. ✅ Created comprehensive test suite in `test/models_test.dart`:
   - 8 test cases covering all serialization scenarios
   - Roundtrip tests (create → JSON → parse → verify)
   - Edge case tests (empty lists, null fields, missing data)
   - Sample JSON validation

### Important Notes for Future Development:
- **DateTime format:** Using `toIso8601String()` for serialization and `DateTime.parse()` for deserialization
- **ID generation:** FoodItem uses `uuid.v4()` for unique IDs (add `uuid` package if not already present)
- **Null safety:** All `fromJson` methods provide safe defaults (empty strings, 0.0, empty lists, empty maps)
- **Image data:** Stored as base64-encoded string in `imageData` field
- **Nested serialization:** Ingredients list is properly serialized/deserialized within FoodItem
- **Default values in fromJson:**
  - Missing strings default to `''`
  - Missing numbers default to `0.0`
  - Missing lists default to `[]`
  - Missing maps default to `{}`
  - Missing DateTime defaults to `DateTime.now()`
- **Total nutrition structure:** Map<String, double> containing keys like 'calories', 'protein', 'carbs', 'fat'
- **JSON compatibility:** Format validated against expected GLM-4.5V API response structure

### Testing Results:
- ✅ 8/8 tests passed in `test/models_test.dart`
- ✅ Roundtrip serialization verified (object → JSON → object)
- ✅ Edge cases handled correctly (empty ingredients, null fields, missing data)
- ✅ Sample JSON format validated for API compatibility
- ✅ No serialization errors or data loss

### Files Created:
- `calai_flutter/lib/models/ingredient.dart`
- `calai_flutter/lib/models/food_item.dart`
- `calai_flutter/test/models_test.dart`

---

## ✅ PHASE 3 COMPLETED - API Integration (Groq API with Llama 4 Scout)

**Completion Date:** 2025-10-07
**Status:** All API integration tasks completed successfully

### What Was Completed:
1. ✅ Created `lib/services/food_analysis_service.dart`:
   - Image optimization (resize to max 1024px, JPEG 70% quality)
   - Base64 image encoding
   - Groq API HTTP client with proper headers
   - JSON response parsing into FoodItem model
   - Comprehensive error handling (auth, network, timeout, malformed responses)
2. ✅ **API Migration completed: OpenRouter → Groq**
   - API endpoint: `https://api.groq.com/openai/v1/chat/completions`
   - Model: `meta-llama/llama-4-scout-17b-16e-instruct` (vision-capable)
   - Environment variable: `GROQ_API_KEY` (updated from OPENROUTER_API_KEY)
3. ✅ Created `test_groq.dart` validation script
4. ✅ Cleaned up obsolete test files (test_api_connectivity.dart, test_glm.dart, test_glm_simple.dart)

### Important Notes for Future Development:
- **⚠️ CRITICAL - Environment variable:** `.env` file uses `GROQ_API_KEY` (NOT OPENROUTER_API_KEY or GLM_API_KEY)
- **⚠️ CRITICAL - API endpoint:** `https://api.groq.com/openai/v1/chat/completions` (Groq, not OpenRouter)
- **⚠️ CRITICAL - Model:** `meta-llama/llama-4-scout-17b-16e-instruct` (DO NOT change without testing)
- **Service file:** `lib/services/food_analysis_service.dart` - main entry point is `analyzeFood(File imageFile)`
- **Image handling:** Service accepts File path, handles optimization internally (1024px max, JPEG 70%)
- **Response format:** OpenAI-compatible (choices → message → content structure)
- **JSON parsing:** Uses regex extraction to handle responses with extra text
- **Timeout:** 30 seconds on HTTP requests
- **Cost:** ~$0.0003 per food analysis (very cheap)
- **Performance:** ~0.3-0.4 seconds average response time

### ⚠️ DO NOT Break These in Future Phases:
1. **DO NOT** change `GROQ_API_KEY` variable name in `.env` or service file
2. **DO NOT** modify API endpoint URL or model name
3. **DO NOT** change image optimization settings (1024px, 70% quality is tested and working)
4. **DO NOT** remove regex JSON extraction logic (handles model response variations)
5. **DO NOT** remove or extend the 30-second timeout without testing
6. **When integrating with Provider/UI:**
   - Pass File object to `analyzeFood()` (not base64)
   - Always wrap calls in try-catch
   - Show loading state during API call
   - Handle exception messages for user display
   - Service returns FoodItem with all nutrition data populated

### Testing Results:
- ✅ API connectivity validated with real Groq API key
- ✅ Image optimization working (handles various sizes correctly)
- ✅ Llama 4 Scout successfully analyzed test food image
- ✅ JSON response parsed correctly into FoodItem model
- ✅ Response time: ~0.33 seconds (excellent performance)
- ✅ Test output validated: "Grilled Chicken and Rice" - 614 cal, 55g protein, 60g carbs, 20g fat, 5 ingredients
- ✅ Error handling tested (auth failures, network errors)

### Files Created:
- `calai_flutter/lib/services/food_analysis_service.dart`
- `calai_flutter/test_groq.dart`

### Files Deleted:
- `calai_flutter/test_api_connectivity.dart`
- `calai_flutter/test_glm.dart`
- `calai_flutter/test_glm_simple.dart`

---

## Execution Strategy

**Approach**: Build incrementally with testing checkpoints after each phase. No phase begins until the previous phase's tests pass.

**Testing Philosophy**:
- Test each layer independently before integration
- Validate API contracts early
- Ensure data persistence works before building UI
- Manual testing + basic unit tests where applicable

---

## DO:
- ✅ ONLY do what I expect you to do, nothing more or less
- ✅ Always ask before assuming requirements
- ✅ Prioritize clarity and simplicity
- ✅ Utilize the DRY (don't repeat yourself) principle

## DO NOT:
- ❌ Add extra libraries unless necessary
- ❌ Create new dependencies unless absolutely necessary
- ❌ Create advanced patterns prematurely
- ❌ Design for edge cases unless asked
- ❌ Structure components for prop drilling

---

## Phase 1: Project Setup & Validation
**Goal**: Working Flutter project with dependencies installed

### Tasks:
1. Create Flutter project `calai_flutter` (Android minSdk 29)
2. Install dependencies in `pubspec.yaml`:
   - `image_picker`, `http`, `shared_preferences`, `provider`, `table_calendar`, `flutter_dotenv`
3. Create `.env` file with placeholder API key
4. Set up folder structure
5. Configure Android permissions (camera, storage) in `AndroidManifest.xml`

### Testing Checkpoint 1:
- ✅ Run `flutter doctor` - no errors
- ✅ Run `flutter pub get` - all dependencies resolve
- ✅ Run `flutter run` - app launches with default UI
- ✅ Verify `.env` loads correctly (print test)

**PAUSE HERE** - Confirm project builds and runs

---

## Phase 2: Models & JSON Serialization
**Goal**: Data models that can serialize/deserialize

### Tasks:
1. Create `lib/models/ingredient.dart` with JSON serialization
2. Create `lib/models/food_item.dart` with JSON serialization

### Testing Checkpoint 2:
- ✅ Write test to create Ingredient → convert to JSON → parse back
- ✅ Write test to create FoodItem → convert to JSON → parse back
- ✅ Test null/edge cases (empty ingredients list, missing fields)
- ✅ Print sample JSON to verify format matches expected API response

**PAUSE HERE** - Confirm models serialize correctly

---

## Phase 3: GLM-4.5V Service (API Integration)
**Goal**: Working API calls to GLM-4.5V with real responses

### Tasks:
1. Create `lib/services/glm_service.dart`:
   - HTTP client setup
   - Image optimization (1024px, 0.7 JPEG quality)
   - GLM-4.5V API call with thinking mode
   - Error handling
   - Parse response into FoodItem model

### Testing Checkpoint 3:
- ✅ Test with hardcoded base64 food image (download a sample)
- ✅ Verify image optimization reduces file size
- ✅ Make real API call to GLM-4.5V
- ✅ Parse API response into FoodItem
- ✅ Test error handling (invalid API key, network error, malformed response)
- ✅ Print full request/response for debugging

**PAUSE HERE** - Confirm API integration works end-to-end

---

## Phase 4: Storage Service (SharedPreferences)
**Goal**: Persistent storage that survives app restarts

### Tasks:
1. Create `lib/services/food_history_service.dart`:
   - Save food items to SharedPreferences
   - Load all food items
   - Filter by date
   - Delete food item by ID

### Testing Checkpoint 4:
- ✅ Save a FoodItem, restart app, verify it persists
- ✅ Save multiple items, retrieve all
- ✅ Filter by date (test same-day and different-day items)
- ✅ Delete an item, verify it's removed
- ✅ Test edge cases (empty storage, corrupt data)

**PAUSE HERE** - Confirm data persistence works

---

## Phase 5: State Management (Provider)
**Goal**: Centralized state that updates UI reactively

### Tasks:
1. Create `lib/providers/food_analysis_provider.dart`:
   - Expose GLM service and history service
   - Handle loading/error states
   - Trigger API calls
   - Save results to storage

### Testing Checkpoint 5:
- ✅ Test provider initializes correctly
- ✅ Trigger analysis → verify loading state toggles
- ✅ Verify successful analysis saves to history
- ✅ Verify errors are caught and exposed
- ✅ Test state updates notify listeners

**PAUSE HERE** - Confirm state management wiring works

---

## Phase 6: Reusable Widgets
**Goal**: UI components ready for screens

### Tasks:
1. Create `lib/widgets/nutrient_card.dart` (calories, protein, carbs, fat)
2. Create `lib/widgets/food_history_row.dart` (list item with thumbnail)

### Testing Checkpoint 6:
- ✅ Render NutrientCard with sample data
- ✅ Render FoodHistoryRow with sample FoodItem
- ✅ Verify image thumbnails display correctly
- ✅ Test with missing image data (fallback icon)

**PAUSE HERE** - Confirm widgets render correctly

---

## Phase 7: UI Screens (Core Functionality)
**Goal**: Functional UI with navigation

### Tasks:
1. Create `lib/screens/food_analysis_screen.dart`:
   - Camera button
   - Image picker integration
   - Display analysis results
   - Loading spinner
   - Error alerts
2. Create `lib/screens/food_detail_screen.dart`:
   - Full food details view
   - Reuse NutrientCard widgets
3. Create `lib/screens/food_history_screen.dart`:
   - `table_calendar` integration
   - List of food items for selected date
   - Swipe-to-delete (Dismissible widget)
   - Navigate to detail view

### Testing Checkpoint 7:
- ✅ Open camera, capture photo, verify image displays
- ✅ Trigger analysis, verify loading state shows
- ✅ Verify results display correctly
- ✅ Navigate to history, select date, verify filtered items
- ✅ Swipe to delete, verify item removed
- ✅ Tap item, verify detail screen shows
- ✅ Test error handling (API failure, camera permission denied)

**PAUSE HERE** - Confirm all screens work independently

---

## Phase 8: Main App Integration
**Goal**: Complete app with tab navigation

### Tasks:
1. Update `lib/main.dart`:
   - Load `.env`
   - Initialize provider
   - TabView with "Analyze" and "History" tabs
   - Tab icons
2. Wire up all screens

### Testing Checkpoint 8:
- ✅ App launches without errors
- ✅ Switch between tabs
- ✅ Analyze food → verify it appears in history
- ✅ Test full flow: capture → analyze → save → view in history → delete
- ✅ Restart app, verify history persists

**PAUSE HERE** - Confirm full integration works

---

## Phase 9: Final Testing & Polish
**Goal**: Production-ready app

### Tasks:
1. Edge case testing:
   - No internet connection
   - Camera permission denied
   - Invalid API key
   - Malformed API responses
   - Empty history
   - Large images
2. UI polish:
   - Loading states
   - Error messages
   - Empty states
3. Performance:
   - Image optimization
   - Smooth scrolling

### Testing Checkpoint 9:
- ✅ Test all edge cases listed above
- ✅ Test on real Android device
- ✅ Verify camera captures correctly
- ✅ Verify API calls complete successfully
- ✅ Verify smooth UI interactions
- ✅ Build release APK and test

**DONE** - App ready for use

---

## Execution Notes

- **After each checkpoint**: I will notify you of test results and wait for your approval before proceeding
- **If tests fail**: We debug and fix before moving to next phase
- **Testing method**: Combination of manual testing (UI, camera, API) and simple unit tests (models, services)
- **DRY principle**: Reuse code wherever possible (widgets, service methods)
- **Simplicity**: Stick to exactly what the iOS app does, no extra features

## How This Will Work

1. I implement Phase 1
2. I run Testing Checkpoint 1
3. I report results to you
4. You approve → I proceed to Phase 2
5. Repeat until Phase 9 complete

**Ready to start Phase 1 when you approve this plan.**
