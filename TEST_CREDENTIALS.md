# Test Credentials for Streakly App

## Demo Mode (Mock Service)

When Supabase is not configured, the app runs in demo mode with these pre-registered test accounts:

### Test Account 1
- **Email:** `test@example.com`
- **Password:** `password123`

### Test Account 2
- **Email:** `demo@streakly.com`
- **Password:** `demo123`

## How to Use

1. **Login:** Use one of the test accounts above
2. **Register:** Create a new account with any email/password (6+ characters)
3. **After Registration:** Login with the credentials you just created

## Features Available in Demo Mode

✅ Full authentication (login/register/logout)
✅ Create, edit, and delete habits
✅ Track habit completions
✅ View habit statistics and streaks
✅ Create and view notes
✅ All data stored in memory (resets on app restart)

## Switching to Real Supabase

1. Open `lib/config/supabase_config.dart`
2. Replace `YOUR_SUPABASE_URL` with your actual Supabase project URL
3. Replace `YOUR_SUPABASE_ANON_KEY` with your actual Supabase anon key
4. Restart the app
5. Register a new account (data will persist in Supabase)

## Notes

- Demo mode data is **not persistent** - it resets when you restart the app
- With real Supabase, all data persists in the cloud
- Password validation: minimum 6 characters
