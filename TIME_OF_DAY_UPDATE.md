# 🌙 Time of Day Update: Anytime → Night

## Changes Made

### 1. Enum Update (`lib/models/habit.dart`)
```dart
// Before
enum HabitTimeOfDay { morning, afternoon, evening, anytime }

// After
enum HabitTimeOfDay { morning, afternoon, evening, night }
```

### 2. Home Screen (`lib/screens/main/home_screen.dart`)
- ✅ Added **Night** section with moon icon (🌙)
- ✅ Changed Evening icon to twilight (🌆)
- ✅ Night section uses deep purple color
- ✅ Displays habits with `timeOfDay: night`

**Sections Now:**
1. 🌅 **Morning** - Sunrise icon, Orange color
2. ☀️ **Afternoon** - Sun icon, Amber color
3. 🌆 **Evening** - Twilight icon, Indigo color
4. 🌙 **Night** - Moon icon, Deep Purple color

### 3. Habits Screen (`lib/screens/habits/habits_screen.dart`)
- ✅ Added **Night** tab (5 tabs total now)
- ✅ Updated TabController length from 4 to 5
- ✅ Added TabBarView for night habits

**Tabs:**
- All
- Morning
- Afternoon
- Evening
- **Night** (NEW)

### 4. Add Habit Screen (`lib/screens/habits/add_habit_screen.dart`)
- ✅ Updated label from "Anytime" to "Night"
- ✅ Time of day selector now shows "Night" option

### 5. Database Schema (`supabase_schema.sql`)
```sql
-- Before
time_of_day TEXT NOT NULL DEFAULT 'anytime'

-- After
time_of_day TEXT NOT NULL DEFAULT 'night'
```

### 6. Supabase Service (`lib/services/supabase_service.dart`)
- ✅ Updated fallback from `HabitTimeOfDay.anytime` to `HabitTimeOfDay.night`

### 7. Mock Service (`lib/services/mock_habit_service.dart`)
- ✅ Updated sample habit from `anytime` to `night`

## Visual Design

### Home Screen Sections
```
┌─────────────────────────────────┐
│ 🌅 Morning                      │
│ [Morning habits here]           │
├─────────────────────────────────┤
│ ☀️ Afternoon                    │
│ [Afternoon habits here]         │
├─────────────────────────────────┤
│ 🌆 Evening                      │
│ [Evening habits here]           │
├─────────────────────────────────┤
│ 🌙 Night                        │
│ [Night habits here]             │
└─────────────────────────────────┘
```

### Habits Screen Tabs
```
┌────┬─────────┬───────────┬─────────┬───────┐
│ All│ Morning │ Afternoon │ Evening │ Night │
└────┴─────────┴───────────┴─────────┴───────┘
```

## Color Scheme

| Time of Day | Icon | Color |
|-------------|------|-------|
| Morning | 🌅 `Icons.wb_sunny` | Orange |
| Afternoon | ☀️ `Icons.wb_sunny_outlined` | Amber |
| Evening | 🌆 `Icons.wb_twilight` | Indigo |
| Night | 🌙 `Icons.nights_stay` | Deep Purple |

## Database Migration

If you have existing habits with `time_of_day = 'anytime'`, they will automatically be treated as `night` habits due to the fallback logic.

### Optional: Update Existing Data
If you want to explicitly update existing "anytime" habits to "night":

```sql
-- Run in Supabase SQL Editor
UPDATE public.habits 
SET time_of_day = 'night' 
WHERE time_of_day = 'anytime';
```

## Testing

### 1. Create New Habit
1. Open Add Habit screen
2. Select "Night" as time of day
3. Create habit
4. Verify it appears in Night section on Home screen
5. Verify it appears in Night tab on Habits screen

### 2. Verify All Sections
1. Create habits for each time of day:
   - Morning habit
   - Afternoon habit
   - Evening habit
   - Night habit
2. Check Home screen shows all 4 sections
3. Check Habits screen shows all 5 tabs
4. Verify habits appear in correct sections/tabs

### 3. Database Sync
1. Create a night habit
2. Check Supabase Table Editor → habits
3. Verify `time_of_day` column shows "night"

## Benefits

✅ **More Specific**: "Night" is clearer than "Anytime"
✅ **Better Organization**: Habits organized by actual time of day
✅ **Visual Clarity**: Each time period has distinct icon and color
✅ **Complete Coverage**: Morning → Afternoon → Evening → Night
✅ **Consistent**: All screens show the same 4 time periods

## User Experience

### Before
- "Anytime" was ambiguous - could mean any time or no specific time
- Only 3 time-specific sections (Morning, Afternoon, Evening)

### After
- "Night" is specific - habits done before bed or late evening
- 4 clear time periods covering the full day
- Better habit scheduling and tracking
- More intuitive for users

## Examples of Night Habits

- 🌙 Skincare routine
- 📖 Read before bed
- 🧘 Evening meditation
- 📝 Journal
- 🦷 Brush teeth
- 💊 Take vitamins
- 📱 Phone-free time
- 🛏️ Prepare for tomorrow

## Hot Restart Required

After these changes, you must **hot restart** (not hot reload) your app:
```bash
# Press 'R' in terminal, or stop and run:
flutter run
```

This ensures the enum changes are properly loaded.
