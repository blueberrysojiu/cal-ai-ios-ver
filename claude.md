# CalAI Flutter Migration - Project Guide

**Current Phase:** Phase 8 - UI Screens (Core Functionality)

---

## Documentation Structure

This project uses a modular documentation system. **Read the files below for complete context:**

### 📋 [.claude/current-status.md](.claude/current-status.md)
**What's done, what's next**
- ✅ Completed phases (1-6) with full details
- 🔄 Current phase status and tasks
- 📝 Testing results and files created/modified
- 📅 Completion dates

**When to read:** Need to know project progress, what's implemented, or what files exist

---

### 🏗️ [.claude/architecture.md](.claude/architecture.md)
**Technical specifications and critical warnings**
- Tech stack (Flutter, Groq API, dependencies)
- Model specifications (Ingredient, FoodItem)
- Service specifications (FoodAnalysisService, FoodHistoryService)
- ⚠️ **DO NOT BREAK** warnings (10 critical items)
- Breaking change checklist

**When to read:** Need technical details, API specs, or before making architectural changes

---

### ✅ [.claude/testing.md](.claude/testing.md)
**Testing checkpoints for all 9 phases**
- Testing workflow and philosophy
- Phase-by-phase testing gates
- Test requirements for each phase
- When to PAUSE and wait for approval

**When to read:** About to test a phase or need to understand testing requirements

---

### 📏 [.claude/rules.md](.claude/rules.md)
**Development principles and guidelines**
- DO/DON'T rules
- Execution strategy
- Testing philosophy
- Code quality standards
- Communication rules

**When to read:** Need guidance on how to approach development or decision-making

---

## Quick Reference

### Tech Stack
- **Framework:** Flutter (Android minSdk 29)
- **API:** Groq API - `https://api.groq.com/openai/v1/chat/completions`
- **Model:** `meta-llama/llama-4-scout-17b-16e-instruct`
- **State Management:** Provider
- **Storage:** SharedPreferences

### Critical Environment Variables
```env
GROQ_API_KEY=your_api_key_here
```

### Project Structure
```
calai_flutter/
├── lib/
│   ├── models/          ✅ Ingredient, FoodItem
│   ├── services/        ✅ FoodAnalysisService, FoodHistoryService
│   ├── providers/       ✅ FoodAnalysisProvider
│   ├── widgets/         ✅ NutrientCard, FoodHistoryRow
│   └── screens/         🔄 (Phase 8 - current)
├── test/                ✅ models_test.dart, food_history_service_test.dart, food_analysis_provider_test.dart, widgets_test.dart
└── .env                 ✅ (gitignored)
```

### Completed Phases
- ✅ Phase 1: Project Setup & Validation
- ✅ Phase 2: Models & JSON Serialization
- ✅ Phase 3: API Integration (Groq with Llama 4 Scout)
- ✅ Phase 4: Storage Service (SharedPreferences)
- ✅ Phase 5: State Management (Provider)
- ✅ Phase 6: Reusable Widgets (NutrientCard, FoodHistoryRow)
- ✅ Phase 7: Device Deployment & Testing

### Next Phases
- 🔄 Phase 8: UI Screens (Core Functionality) - **CURRENT**
- ⏳ Phase 9: Main App Integration
- ⏳ Phase 10: Final Testing & Polish

---

## Update Instructions (for Claude Code)

When the user says **"update claude.md with the changes we've made so far"**:

### 1. Update `.claude/current-status.md`
- Move completed phase to "Completed Phases" section
- Add completion date and status
- List "What Was Completed" with checkmarks
- Document "Files Created/Modified/Deleted"
- Add "Testing Results" section
- Update "Current Phase" to next phase

### 2. Update `.claude/architecture.md` IF the phase introduced:
- New services or models
- New dependencies or libraries
- Critical API endpoints or configuration
- Breaking change warnings (add to "DO NOT Break These" section)

### 3. Update `.claude/testing.md` IF:
- Testing approach changed
- New testing requirements added
- Testing checkpoints were modified

### 4. Update `.claude/rules.md` (rarely):
- Only if new DO/DON'T rules were added

### 5. Update this file (`CLAUDE.md`) IF:
- Current phase changed (update "Current Phase" at top)
- New phase completed (update checkmarks in "Completed Phases")
- Quick Reference needs updating (folder structure, tech stack)

### Before Finalizing:
**ALWAYS ask the user:** "What are the critical changes or warnings from this phase that we need to remember?"

---

## Development Workflow

### Standard Phase Flow:
1. ✅ Read relevant .claude/*.md files for context
2. 📱 **Check iOS Swift implementation for UI reference** (for Phases 6-8)
3. 🔨 Implement phase tasks
4. 🧪 Run testing checkpoint
5. 📊 Report results to user
6. ⏸️ **PAUSE** - Wait for user approval
7. ➡️ Proceed to next phase (after approval)

### iOS Swift Reference (Frontend Phases)
**For Phases 6-8 (Widgets, Screens, Main App):**
- **ALWAYS** check the Swift files in `App Click Cal/` for iOS design reference
- Key reference files:
  - `Features/Analysis/FoodAnalysisView.swift` - Analysis screen & NutrientCard
  - `Features/History/FoodHistoryView.swift` - History screen & FoodHistoryRow
  - `Core/Models/FoodItem.swift` - Data models
  - `ContentView.swift` - Main app structure with tabs
- **Goal:** Replicate iOS design exactly in Flutter, adapting for Material Design
- **Translation:** SwiftUI → Flutter (VStack → Column, HStack → Row, etc.)

### If Tests Fail:
1. 🛑 **STOP** - Do not proceed
2. 🐛 Debug and fix issues
3. 🔄 Re-run tests
4. 📊 Report results again
5. ⏸️ Wait for approval

---

## Key Principles

- **DRY:** Don't repeat yourself - reuse code wherever possible
- **Simplicity:** Match iOS app functionality exactly, no extra features
- **Testing:** Every phase has a testing gate - must pass before proceeding
- **Clarity:** Prioritize clear, simple code over clever abstractions
- **Incremental:** Build layer by layer with validation at each step

---

## Critical Warnings Summary

⚠️ **DO NOT CHANGE without testing:**
1. Environment variable: `GROQ_API_KEY`
2. API endpoint: `https://api.groq.com/openai/v1/chat/completions`
3. Model: `meta-llama/llama-4-scout-17b-16e-instruct`
4. Image optimization: 1024px max, 70% quality
5. DateTime serialization: `toIso8601String()` / `DateTime.parse()`
6. Storage key: `'food_history'`
7. Date filtering logic: `DateTime(year, month, day)` normalization

See `.claude/architecture.md` → "DO NOT Break These" for full details.

---

## iOS Design Reference

**Location:** `App Click Cal/Features/` (Swift/SwiftUI files)

When implementing UI (Phases 6-8), always reference the iOS implementation:
- Check Swift files for exact design specifications
- Match layouts, spacing, colors, and interactions
- Adapt SwiftUI patterns to Flutter/Material Design
- Goal: Flutter app should look and feel identical to iOS app

**Key Files:**
- `FoodAnalysisView.swift` - Analysis screen with camera, results, NutrientCard
- `FoodHistoryView.swift` - History screen with calendar, list, FoodHistoryRow
- `ContentView.swift` - Tab navigation structure

---

**Ready to continue Phase 8!** 🚀

---

## Phase 7 Summary: Device Deployment

Phase 7 successfully deployed the app to a physical Android device (Samsung Galaxy A22, Android 13). Key accomplishments:

- ✅ Configured Android development environment (SDK licenses, NDK, Build Tools, CMake)
- ✅ Connected physical device with USB debugging
- ✅ **Fixed critical .env bug:** Changed `GLM_API_KEY` → `GROQ_API_KEY` and added real API key
- ✅ Deployed app successfully (first build: 741s, subsequent: ~60s)
- ✅ Verified app launches and .env loads correctly
- ✅ User confirmed: "It works perfectly"

**Critical lesson learned:** The .env file had the wrong variable name (`GLM_API_KEY` instead of `GROQ_API_KEY`), which was caught during deployment testing. This has been fixed and documented.
