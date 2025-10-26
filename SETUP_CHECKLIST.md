# 🚀 Streakly App Setup Checklist

## ✅ Completed Setup Steps

### 1. Supabase Configuration
- [x] Added Supabase URL and Anon Key to `lib/config/supabase_config.dart`
- [x] URL: `https://zpohnnokdhrsclmnfstd.supabase.co`
- [x] App detects real Supabase (not mock mode)

### 2. Code Fixes Applied
- [x] Fixed icon/color column types (INTEGER → BIGINT)
- [x] Fixed duplicate user profile creation
- [x] Removed manual profile creation (uses database trigger)
- [x] Updated time of day: anytime → night
- [x] Implemented habit completion lock (can't re-check same day)

### 3. Features Implemented
- [x] Full authentication (login/register/logout)
- [x] Habit creation with icons, colors, frequency
- [x] Multi-completion tracking (X/Y per day)
- [x] Habit completion lock until next day
- [x] 4 time periods: Morning, Afternoon, Evening, Night
- [x] Real-time sync with Supabase
- [x] Home screen with time-based sections
- [x] Habits screen with filterable tabs

## 🔧 Required Database Setup

### Step 1: Run Database Schema
1. Open [Supabase Dashboard](https://supabase.com/dashboard)
2. Go to **SQL Editor** → **New Query**
3. Copy contents of `supabase_schema.sql`
4. Click **Run**

This creates:
- ✅ `users` table
- ✅ `habits` table (with BIGINT columns)
- ✅ `habit_completions` table
- ✅ `user_stats` table
- ✅ Row Level Security policies
- ✅ Automatic triggers

### Step 2: Fix Icon Column Types (If Already Created)
If you already ran the old schema, run this migration:

```sql
-- In Supabase SQL Editor
ALTER TABLE public.habits 
ALTER COLUMN icon_code_point TYPE BIGINT;

ALTER TABLE public.habits 
ALTER COLUMN color_value TYPE BIGINT;
```

### Step 3: Migrate Anytime → Night (Optional)
If you have existing habits with `time_of_day = 'anytime'`:

```sql
UPDATE public.habits 
SET time_of_day = 'night',
    updated_at = NOW()
WHERE time_of_day = 'anytime';
```

### Step 4: Configure Authentication
1. Go to **Authentication** → **Settings**
2. **Disable** "Enable email confirmations" (for easier testing)
3. Set **Site URL**: `http://localhost:3000`

## 🎯 Testing Checklist

### Authentication
- [ ] Register new account
- [ ] Verify user appears in Supabase Auth
- [ ] Verify profile created in `users` table
- [ ] Login with credentials
- [ ] Logout works

### Habit Creation
- [ ] Create habit with Morning time
- [ ] Create habit with Afternoon time
- [ ] Create habit with Evening time
- [ ] Create habit with Night time
- [ ] Verify habits appear in Supabase `habits` table
- [ ] Check icon_code_point and color_value are stored

### Habit Display
- [ ] Home screen shows all 4 time sections
- [ ] Habits appear in correct time sections
- [ ] Habits screen shows all 5 tabs (All, Morning, Afternoon, Evening, Night)
- [ ] Habits appear in correct tabs

### Habit Completion
- [ ] Single completion habit (1/day):
  - [ ] Tap to complete → Shows checkmark
  - [ ] Try tapping again → Disabled/no action
  - [ ] Check console → Shows "already completed" message
- [ ] Multi-completion habit (3/day):
  - [ ] Tap 1st time → Shows 1/3
  - [ ] Tap 2nd time → Shows 2/3
  - [ ] Tap 3rd time → Shows 3/3 with checkmark
  - [ ] Try tapping again → Disabled/no action
- [ ] Verify completion in `habit_completions` table

### Data Persistence
- [ ] Close and reopen app
- [ ] Habits still appear
- [ ] Completions still show
- [ ] Streaks maintained

## 📋 Console Logs to Watch For

### Successful Supabase Connection
```
🚀 Initializing REAL Supabase connection...
✅ Supabase initialized successfully!
🔧 Supabase Configuration Check:
   ✓ Configured: true
   ✓ URL: https://zpohnnokdhrsclmnfstd.supabase.co
   ✓ Using: REAL SUPABASE
```

### Authentication
```
📝 SignUp Request for: user@example.com
   ✅ Using REAL Supabase for signup
   ✅ User profile will be auto-created by database trigger
```

### Habit Operations
```
➕ Creating habit: Exercise
   ✅ Creating in REAL Supabase
✅ Habit "Exercise" marked complete (1/3)
⚠️  Habit "Exercise" is fully completed for today. Try again tomorrow!
```

## ⚠️ Common Issues & Solutions

### Issue: "Value out of range for type integer"
**Solution:** Run the BIGINT migration (Step 2 above)

### Issue: "Duplicate key value violates unique constraint users_pkey"
**Solution:** 
- Delete user from Authentication → Users
- Delete profile from Table Editor → users
- Register with new email or re-register

### Issue: Habits not appearing
**Solution:**
- Check console for "Using: REAL SUPABASE"
- Verify habits exist in Supabase Table Editor
- Check RLS policies are enabled
- Ensure you're logged in

### Issue: Can't complete habit again
**Solution:** This is expected! Habits lock after full completion until next day (midnight)

## 📚 Documentation Files

- `SETUP_SUPABASE_NOW.md` - Complete Supabase setup guide
- `FIX_DATABASE_NOW.md` - Fix icon column type error
- `FIX_DUPLICATE_USER_ERROR.md` - Fix duplicate user profile error
- `HABIT_COMPLETION_LOCK.md` - Habit completion lock feature
- `TIME_OF_DAY_UPDATE.md` - Anytime → Night change
- `TEST_CREDENTIALS.md` - Demo mode test accounts
- `supabase_schema.sql` - Complete database schema
- `migrate_anytime_to_night.sql` - Migration script

## 🎉 Success Indicators

You'll know everything is working when:
1. ✅ Console shows "Using: REAL SUPABASE"
2. ✅ Can register and login
3. ✅ Habits save to database
4. ✅ Habits appear on Home and Habits screens
5. ✅ Completions sync to database
6. ✅ Data persists after app restart
7. ✅ All 4 time sections show on Home screen
8. ✅ Habits lock after completion

## 🚀 Next Steps

1. **Hot restart your app** (press 'R' or restart)
2. **Complete database setup** (run schema if not done)
3. **Test authentication** (register/login)
4. **Create test habits** (one for each time of day)
5. **Test completions** (single and multi-completion)
6. **Verify persistence** (close/reopen app)

## 📞 Need Help?

Check the console logs for detailed information about each operation. The emojis and messages will guide you:
- 🚀 = Initialization
- ✅ = Success
- ⚠️ = Warning/Info
- ❌ = Error
- 📝 = Auth operation
- ➕ = Create operation
- ✏️ = Update operation
- 🗑️ = Delete operation

Happy habit tracking! 🎯
