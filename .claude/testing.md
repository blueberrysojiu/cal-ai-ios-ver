# CalAI Flutter Migration - Testing Checkpoints

## Testing Workflow

**Rule:** No phase begins until the previous phase's tests pass.

**After each checkpoint:**
1. Run all tests for the phase
2. Report results
3. Wait for approval
4. Proceed to next phase (or debug if tests fail)

---

## Phase 1: Project Setup & Validation

**Goal:** Working Flutter project with dependencies installed

### Tasks:
1. Create Flutter project `calai_flutter` (Android minSdk 29)
2. Install dependencies in `pubspec.yaml`:
   - `image_picker`, `http`, `shared_preferences`, `provider`, `table_calendar`, `flutter_dotenv`
3. Create `.env` file with placeholder API key
4. Set up folder structure
5. Configure Android permissions (camera, storage) in `AndroidManifest.xml`

### Testing Checkpoint 1:
- [ ] Run `flutter doctor` - no errors
- [ ] Run `flutter pub get` - all dependencies resolve
- [ ] Run `flutter run` - app launches with default UI
- [ ] Verify `.env` loads correctly (print test)

**PAUSE HERE** - Confirm project builds and runs

---

## Phase 2: Models & JSON Serialization

**Goal:** Data models that can serialize/deserialize

### Tasks:
1. Create `lib/models/ingredient.dart` with JSON serialization
2. Create `lib/models/food_item.dart` with JSON serialization

### Testing Checkpoint 2:
- [ ] Write test to create Ingredient → convert to JSON → parse back
- [ ] Write test to create FoodItem → convert to JSON → parse back
- [ ] Test null/edge cases (empty ingredients list, missing fields)
- [ ] Print sample JSON to verify format matches expected API response

**PAUSE HERE** - Confirm models serialize correctly

---

## Phase 3: API Integration (Groq API)

**Goal:** Working API calls with real responses

### Tasks:
1. Create `lib/services/food_analysis_service.dart`:
   - HTTP client setup
   - Image optimization (1024px, 0.7 JPEG quality)
   - Groq API call
   - Error handling
   - Parse response into FoodItem model

### Testing Checkpoint 3:
- [ ] Test with hardcoded base64 food image (download a sample)
- [ ] Verify image optimization reduces file size
- [ ] Make real API call to Groq
- [ ] Parse API response into FoodItem
- [ ] Test error handling (invalid API key, network error, malformed response)
- [ ] Print full request/response for debugging

**PAUSE HERE** - Confirm API integration works end-to-end

---

## Phase 4: Storage Service (SharedPreferences)

**Goal:** Persistent storage that survives app restarts

### Tasks:
1. Create `lib/services/food_history_service.dart`:
   - Save food items to SharedPreferences
   - Load all food items
   - Filter by date
   - Delete food item by ID

### Testing Checkpoint 4:
- [ ] Save a FoodItem, restart app, verify it persists
- [ ] Save multiple items, retrieve all
- [ ] Filter by date (test same-day and different-day items)
- [ ] Delete an item, verify it's removed
- [ ] Test edge cases (empty storage, corrupt data)

**PAUSE HERE** - Confirm data persistence works

---

## Phase 5: State Management (Provider)

**Goal:** Centralized state that updates UI reactively

### Tasks:
1. Create `lib/providers/food_analysis_provider.dart`:
   - Expose service methods
   - Handle loading/error states
   - Trigger API calls
   - Save results to storage

### Testing Checkpoint 5:
- [ ] Test provider initializes correctly
- [ ] Trigger analysis → verify loading state toggles
- [ ] Verify successful analysis saves to history
- [ ] Verify errors are caught and exposed
- [ ] Test state updates notify listeners

**PAUSE HERE** - Confirm state management wiring works

---

## Phase 6: Reusable Widgets

**Goal:** UI components ready for screens

### Tasks:
1. Create `lib/widgets/nutrient_card.dart` (calories, protein, carbs, fat)
2. Create `lib/widgets/food_history_row.dart` (list item with thumbnail)

### Testing Checkpoint 6:
- [ ] Render NutrientCard with sample data
- [ ] Render FoodHistoryRow with sample FoodItem
- [ ] Verify image thumbnails display correctly
- [ ] Test with missing image data (fallback icon)

**PAUSE HERE** - Confirm widgets render correctly

---

## Phase 7: UI Screens (Core Functionality)

**Goal:** Functional UI with navigation

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
- [ ] Open camera, capture photo, verify image displays
- [ ] Trigger analysis, verify loading state shows
- [ ] Verify results display correctly
- [ ] Navigate to history, select date, verify filtered items
- [ ] Swipe to delete, verify item removed
- [ ] Tap item, verify detail screen shows
- [ ] Test error handling (API failure, camera permission denied)

**PAUSE HERE** - Confirm all screens work independently

---

## Phase 8: Main App Integration

**Goal:** Complete app with tab navigation

### Tasks:
1. Update `lib/main.dart`:
   - Load `.env`
   - Initialize provider
   - TabView with "Analyze" and "History" tabs
   - Tab icons
2. Wire up all screens

### Testing Checkpoint 8:
- [ ] App launches without errors
- [ ] Switch between tabs
- [ ] Analyze food → verify it appears in history
- [ ] Test full flow: capture → analyze → save → view in history → delete
- [ ] Restart app, verify history persists

**PAUSE HERE** - Confirm full integration works

---

## Phase 9: Final Testing & Polish

**Goal:** Production-ready app

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
- [ ] Test all edge cases listed above
- [ ] Test on real Android device
- [ ] Verify camera captures correctly
- [ ] Verify API calls complete successfully
- [ ] Verify smooth UI interactions
- [ ] Build release APK and test

**DONE** - App ready for use

---

## Testing Guidelines

### Manual Testing
- **UI elements**: Visual inspection
- **Camera**: Test on real device
- **API calls**: Verify responses with print statements
- **Navigation**: Test all screen transitions
- **Persistence**: Restart app to verify storage

### Unit Testing
- **Models**: `test/models_test.dart` (roundtrip serialization)
- **Services**: Test API calls with real endpoints
- **Providers**: Test state changes and listener notifications

### Integration Testing
- **Phase 8**: Full flow from capture to storage to display
- **Phase 9**: All edge cases and error scenarios

### When Tests Fail
1. **STOP** - Do not proceed
2. Debug the issue
3. Fix the code
4. Re-run tests
5. Report results
6. Wait for approval

### Reporting Format
For each phase, report:
1. **Status**: Pass/Fail
2. **Test results**: Which tests passed/failed
3. **Files created/modified**
4. **Any issues encountered**
5. **Next steps**: Wait for approval or proceed (if approved)
