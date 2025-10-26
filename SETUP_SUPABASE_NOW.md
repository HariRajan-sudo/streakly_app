# 🚀 Complete Supabase Setup Guide

## ✅ Step 1: Configuration (DONE)

You've already configured your Supabase credentials in `lib/config/supabase_config.dart`:
- URL: `https://zpohnnokdhrsclmnfstd.supabase.co`
- Anon Key: Configured ✅

## 📋 Step 2: Set Up Database Schema (REQUIRED)

Your app needs database tables to store user data. Follow these steps:

### 2.1 Open Supabase Dashboard
1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Select your project: `zpohnnokdhrsclmnfstd`

### 2.2 Run Database Schema
1. Click **"SQL Editor"** in the left sidebar
2. Click **"New Query"** button
3. Open the file `supabase_schema.sql` in your project root
4. **Copy ALL the SQL code** from that file
5. **Paste it** into the SQL Editor
6. Click **"Run"** button (or press Ctrl+Enter)

This will create:
- ✅ `users` table - User profiles
- ✅ `habits` table - User habits
- ✅ `habit_completions` table - Daily completions
- ✅ `user_stats` table - User statistics
- ✅ Row Level Security (RLS) policies
- ✅ Automatic triggers and functions

### 2.3 Verify Tables Created
1. Click **"Table Editor"** in the left sidebar
2. You should see these tables:
   - `users`
   - `habits`
   - `habit_completions`
   - `user_stats`

## 🔐 Step 3: Configure Authentication

### 3.1 Email Settings
1. Go to **"Authentication"** → **"Settings"** → **"Auth Providers"**
2. Make sure **"Email"** is enabled
3. Configure email confirmation (optional):
   - **Disable** "Enable email confirmations" for easier testing
   - **Enable** it for production

### 3.2 Site URL Configuration
1. Go to **"Authentication"** → **"URL Configuration"**
2. Set **Site URL**: `http://localhost:3000` (for development)
3. Add **Redirect URLs** if needed

## 🏃 Step 4: Run Your App

### 4.1 Hot Restart
Since you've configured Supabase, you need to **restart the app** (not hot reload):

```bash
# Stop the current app
# Then run:
flutter run
```

### 4.2 Watch Console Logs
When the app starts, you should see:
```
🚀 Initializing REAL Supabase connection...
✅ Supabase initialized successfully!
🔧 Supabase Configuration Check:
   ✓ Configured: true
   ✓ URL: https://zpohnnokdhrsclmnfstd.supabase.co
   ✓ Using: REAL SUPABASE
```

## ✅ Step 5: Test Your Setup

### 5.1 Register New Account
1. Open the app
2. Click **"Sign Up"**
3. Enter:
   - Name: Your name
   - Email: Your real email
   - Password: At least 6 characters
4. Click **"Create Account"**

### 5.2 Verify in Supabase Dashboard
1. Go to **"Authentication"** → **"Users"**
2. You should see your new user
3. Go to **"Table Editor"** → **"users"**
4. You should see your user profile

### 5.3 Create a Habit
1. Login with your new account
2. Click **"Add Habit"** (+ button)
3. Fill in habit details
4. Click **"Create Habit"**

### 5.4 Verify Habit in Database
1. Go to **"Table Editor"** → **"habits"**
2. You should see your habit with:
   - Your user_id
   - Habit name, description
   - Icon and color codes
   - Timestamps

### 5.5 Mark Habit Complete
1. In the app, click the habit to mark it complete
2. Go to **"Table Editor"** → **"habit_completions"**
3. You should see a completion record

## 🎯 What's Now Using Real Supabase

With your configuration, these operations now use **REAL SUPABASE**:

### Authentication
- ✅ User registration → Stored in Supabase Auth
- ✅ User login → Validated against Supabase
- ✅ User profile → Stored in `users` table
- ✅ Password reset → Handled by Supabase

### Habits
- ✅ Create habit → Stored in `habits` table
- ✅ Update habit → Updated in database
- ✅ Delete habit → Removed from database
- ✅ List habits → Fetched from database

### Completions
- ✅ Mark complete → Stored in `habit_completions` table
- ✅ Track streaks → Calculated from database
- ✅ View history → Fetched from database

### Data Persistence
- ✅ All data persists across app restarts
- ✅ Data syncs across devices with same account
- ✅ No data loss when closing app

## 🔍 Troubleshooting

### "Invalid API Key" Error
- Verify your URL and anon key in `supabase_config.dart`
- Make sure there are no extra spaces
- Check if project is active in Supabase dashboard

### "Row Level Security" Errors
- Make sure you ran the complete `supabase_schema.sql`
- Check that RLS policies were created
- Verify you're logged in when creating habits

### Tables Not Found
- Run the `supabase_schema.sql` script again
- Check SQL Editor for any error messages
- Verify tables exist in Table Editor

### Authentication Not Working
- Check if email confirmation is required
- Look at Supabase logs: **"Logs"** → **"Auth Logs"**
- Verify user was created in Authentication panel

## 📊 Monitoring Your App

### View Logs
1. Go to **"Logs"** in Supabase dashboard
2. Check:
   - **Auth Logs** - Login/signup attempts
   - **API Logs** - Database operations
   - **Database Logs** - SQL queries

### View Data
1. **Table Editor** - See all your data
2. **Authentication** → **Users** - Manage users
3. **Database** → **Roles** - Check permissions

## 🎉 Success Indicators

You'll know everything is working when:
1. ✅ Console shows "Using: REAL SUPABASE"
2. ✅ You can register and login
3. ✅ Habits appear in Supabase Table Editor
4. ✅ Completions are tracked in database
5. ✅ Data persists after app restart
6. ✅ Same account works across devices

## 🚨 Important Notes

- **No Mock Data**: With real Supabase, you won't see sample habits
- **Start Fresh**: Register a new account to test
- **Data Persists**: Unlike demo mode, data is permanent
- **Multi-Device**: Same account syncs across all devices
- **Secure**: All data is protected by Row Level Security

## 📝 Next Steps

After confirming everything works:
1. Create your daily habits
2. Start tracking completions
3. Build your streaks
4. Invite friends to join

Need help? Check the console logs for detailed information about each operation!
