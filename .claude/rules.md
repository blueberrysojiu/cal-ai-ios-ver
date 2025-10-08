# CalAI Flutter Migration - Development Rules

## DO:
- ✅ **ONLY do what I expect you to do, nothing more or less**
- ✅ **Always ask before assuming requirements**
- ✅ **Prioritize clarity and simplicity**
- ✅ **Utilize the DRY (don't repeat yourself) principle**
  - Reuse widgets across screens
  - Extract common logic into services
  - Share models across the app
- ✅ **Test each phase independently before moving forward**
- ✅ **Report test results and wait for approval before proceeding**
- ✅ **Follow the iOS app's functionality exactly** - no extra features
- ✅ **Reference iOS Swift files for UI implementation** (Phases 6-8)
  - Check `App Click Cal/Features/` for exact designs
  - Replicate layouts, spacing, colors, interactions
  - Translate SwiftUI patterns to Flutter/Material Design
  - Goal: Make Flutter app look and feel identical to iOS app
- ✅ **Handle errors gracefully with user-friendly messages**
- ✅ **Use safe defaults for null values in JSON parsing**

---

## DO NOT:
- ❌ **Add extra libraries unless necessary**
  - Current dependencies are sufficient for the entire project
  - Only add new packages if explicitly required for a feature
- ❌ **Create new dependencies unless absolutely necessary**
  - Avoid adding state management libraries beyond Provider
  - Avoid adding extra image processing libraries
- ❌ **Create advanced patterns prematurely**
  - No complex architecture patterns (BLoC, Redux, etc.)
  - Keep state management simple with Provider
- ❌ **Design for edge cases unless asked**
  - Focus on happy path first
  - Add edge case handling only after core functionality works
- ❌ **Structure components for prop drilling**
  - Use Provider to avoid passing data through multiple widget layers
- ❌ **Over-engineer the solution**
  - Stick to exactly what the iOS app does
  - No "future-proofing" or "scalability" enhancements
- ❌ **Skip testing checkpoints**
  - Every phase must pass its tests before moving forward
  - Never assume functionality works without testing
- ❌ **Modify critical configuration without testing**
  - See `.claude/architecture.md` → "DO NOT Break These" section
  - Always test after changing API endpoints, env vars, or serialization

---

## Execution Strategy

### Approach
Build incrementally with testing checkpoints after each phase. No phase begins until the previous phase's tests pass.

### Workflow
1. Implement phase tasks
2. Run testing checkpoint
3. Report results
4. Wait for approval
5. Proceed to next phase

### If Tests Fail
- **STOP** - Do not proceed to the next phase
- Debug and fix issues
- Re-run tests
- Report results again
- Only proceed after approval

---

## Testing Philosophy

### Test Each Layer Independently
- Models: Test serialization/deserialization in isolation
- Services: Test API calls and storage independently
- Providers: Test state management without UI
- Widgets: Test rendering with sample data
- Screens: Test full integration

### Validate API Contracts Early
- Test API calls with real endpoints in Phase 3
- Verify response format matches expected structure
- Handle all error cases (auth, network, timeout)

### Ensure Data Persistence Works Before Building UI
- Test storage in Phase 4 before creating screens
- Verify data survives app restarts
- Test edge cases (empty storage, corrupt data)

### Testing Methods
- **Manual testing**: UI, camera, API integration
- **Basic unit tests**: Models, services (where applicable)
- **Integration testing**: Full flow in Phase 8

### Pause Points
Every phase has a **"PAUSE HERE"** checkpoint. Do not proceed past this gate until tests pass and approval is given.

---

## Code Quality Standards

### Clarity
- Use descriptive variable names
- Add comments for complex logic
- Keep functions small and focused

### Simplicity
- Avoid unnecessary abstractions
- Use built-in Flutter widgets whenever possible
- Keep state management straightforward

### DRY Principle
- Extract reusable widgets (NutrientCard, FoodHistoryRow)
- Share service methods across providers
- Use models consistently across the app

### Error Handling
- Always wrap API calls in try-catch
- Provide user-friendly error messages
- Log errors for debugging (use print or logger)

---

## Communication Rules

### When to Ask
- If requirements are unclear
- If multiple approaches are possible
- If a decision affects architecture
- Before adding new dependencies

### When to Report
- After completing a phase
- After running tests
- If tests fail
- If unexpected issues arise

### What to Report
- Test results (pass/fail)
- Files created/modified
- Any blockers or issues
- Next steps (wait for approval)

---

## Phase Completion Checklist

Before marking a phase as complete:
1. ✅ All tasks completed
2. ✅ All tests pass
3. ✅ Files created/modified documented
4. ✅ No critical errors or warnings
5. ✅ Results reported to user
6. ✅ Approval received

Only then proceed to the next phase.
