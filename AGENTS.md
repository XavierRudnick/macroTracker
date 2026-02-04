# agents.md — Macro / Meal Tracking iPhone App (Personal / On-Device)

## Mission
Build a private iPhone app (not public, only for me) to log meals and track daily calories + macros for lean weight gain.

**Daily targets (fixed defaults):**
- Calories: **2,700 kcal**
- Protein: **150 g**
- Fat: **80 g**
- Carbs: **345 g**

Primary goals: fast logging, clear “remaining” numbers, offline-first, and safe backups via export/import.

---

## Product Requirements (MVP)

### Core screens & flows
1. **Daily Dashboard**
   - Shows **Consumed** and **Remaining** for Calories, Protein, Fat, Carbs.
   - Date selector (Today default).
   - Progress indicators for each macro + calories.
   - Clear “over target” state (remaining can go negative).

2. **Add Food / Meal (Quick Add)**
   - Manual entry first (no nutrition API for MVP).
   - Fields:
     - Food name (required)
     - Serving size (optional)
     - Calories (number)
     - Protein/Fat/Carbs (grams; number)
     - Timestamp (default now)
     - Meal category (Breakfast/Lunch/Dinner/Snack/Other)
   - Save → entry appears in today’s log and totals update instantly.

3. **Daily Log**
   - Entries for the selected day grouped by meal category.
   - Edit / delete entries.

4. **Recents (Reuse Foods)**
   - Recent foods list (by last used).
   - Tap to re-add quickly (optionally adjust serving/macros before saving).
   - Search by name.

5. **Weekly View**
   - Last 7 days summary: calories + macros vs targets.
   - Show averages and simple adherence indicator.

---

## Backup & Restore (Required)

### Export
- Provide a **Settings** screen with **Export Data**.
- Export must use the iOS share sheet so I can save to:
  - **Files app** (On My iPhone → App folder)
  - **iCloud Drive**
  - Any provider available in Files (Dropbox, Google Drive, etc.)

**Export format (MVP):**
- Primary: **JSON** for full restore
- Optional: **CSV** for human-readable viewing

**Export output (recommended):**
- Single file: `macro-tracker-backup-YYYY-MM-DD.json`
  - Contains:
    - schemaVersion
    - targets
    - all FoodEntry records
    - (optional) cached food templates if you separate them later

### Import
- In Settings: **Import Data**
- Use a document picker to select a JSON backup.
- Validate:
  - schemaVersion is supported
  - required fields exist
- Import behavior:
  - Default: **merge** (add entries that don’t already exist by UUID)
  - Do not silently wipe data

### Data Safety Notes (Design assumptions)
- Data should **persist across app updates** as long as the bundle id remains unchanged.
- Data may be lost if the app is deleted; export/import is the safety net.

---

## Non-Goals (for MVP)
- Barcode scanning
- Photo recognition
- Online nutrition database integration
- Accounts/login
- Multi-device sync (CloudKit can be considered later)

---

## Tech Constraints / Preferences
- Platform: iOS
- UI: **SwiftUI**
- Persistence: **SwiftData (on-device, local-only)**
- Offline-first: must work fully without internet
- Minimal dependencies

---

## Macro & Calorie Rules
- Daily totals:
  - Calories = sum(entry.calories)
  - Protein/Fat/Carbs = sum(entry.protein/fat/carbs)
- Remaining = Target - Consumed (can go negative)

### Optional soft validation (never block saving)
- Estimated kcal from macros:
  - `est = 4*protein + 9*fat + 4*carbs`
- If discrepancy is large (e.g., >20%), show a non-blocking warning.

---

## Data Model (SwiftData)

### FoodEntry (stored)
- id: UUID
- name: String
- serving: String? (optional)
- calories: Double
- protein: Double
- fat: Double
- carbs: Double
- timestamp: Date
- mealType: MealType (enum)

### Targets (stored or constants with persisted override)
- caloriesTarget: Double (default 2700)
- proteinTarget: Double (default 150)
- fatTarget: Double (default 80)
- carbsTarget: Double (default 345)

**Migration-safe guidance**
- Prefer adding new properties as optional or with defaults.
- Avoid removing/renaming properties early; if needed later, implement migration consciously.

---

## UX Guidelines
- Speed > complexity.
- “Add Food” reachable in one tap.
- Recents prominent for quick add.
- Use clear units (kcal, g).
- Keep Settings minimal: Targets (optional), Export, Import.

---

## Acceptance Criteria
- I can log a food in <10 seconds.
- Dashboard totals and remaining update instantly and correctly.
- I can browse/edit/delete entries for any date.
- Recents allows quick reuse.
- Weekly view shows last 7 days totals vs targets.
- Data persists across normal app updates.
- Export produces a JSON file usable via Files/iCloud Drive.
- Import restores/merges data without wiping existing entries.

---

## Development Instructions for the Agent
1. Create a clean project structure:
   - `Models/`, `Views/`, `Storage/`, `Utilities/`
2. Implement SwiftData models + repository layer first.
3. Build screens in order:
   - Dashboard → Add Food → Daily Log → Recents → Weekly View → Settings (Export/Import)
4. Add unit tests for:
   - totals and remaining calculations
   - macro→kcal estimate logic
   - export JSON encoding and import validation
5. Keep code simple, readable, and minimize dependencies.

---

## Output Expectations
When implementing, always provide:
- File tree changes
- Key code snippets or full files when appropriate
- Short instructions to run and test
- Notes on any migration considerations when changing models

If you must choose between options, pick the simplest approach that meets the acceptance criteria.
