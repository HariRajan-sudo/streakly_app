# Supabase Integration Setup Guide

## Prerequisites

1. **Create a Supabase Account**
   - Go to [supabase.com](https://supabase.com)
   - Sign up for a free account

2. **Create a New Project**
   - Click "New Project"
   - Choose your organization
   - Enter project name: "Streakly"
   - Enter database password (save this!)
   - Select region closest to your users
   - Click "Create new project"

## Step 1: Get Your Project Credentials

1. Go to your project dashboard
2. Click on "Settings" (gear icon) in the sidebar
3. Click on "API" in the settings menu
4. Copy the following values:
   - **Project URL** (looks like: `https://your-project-id.supabase.co`)
   - **Anon Public Key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

## Step 2: Configure Your Flutter App

1. Open `lib/config/supabase_config.dart`
2. Replace the placeholder values:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
  
  // ... rest of the file stays the same
}
```

## Step 3: Set Up Database Schema

1. In your Supabase dashboard, go to "SQL Editor"
2. Click "New Query"
3. Copy the entire contents of `supabase_schema.sql` file
4. Paste it into the SQL editor
5. Click "Run" to execute the schema

This will create:
- **users** table for user profiles
- **habits** table for storing habits
- **habit_completions** table for tracking daily completions
- **user_stats** table for analytics and leaderboards
- Row Level Security (RLS) policies
- Automatic triggers and functions

## Step 4: Configure Authentication

1. In Supabase dashboard, go to "Authentication" → "Settings"
2. **Email Settings:**
   - Enable "Enable email confirmations" if you want email verification
   - Configure your email templates (optional)

3. **URL Configuration:**
   - Site URL: `http://localhost:3000` (for development)
   - Redirect URLs: Add your app's deep link URLs

## Step 5: Install Dependencies and Run

1. **Install Flutter dependencies:**
```bash
cd /home/harirajan/Documents/Streakly/streakly_app
flutter pub get
```

2. **Run the app:**
```bash
flutter run
```

## Step 6: Test the Integration

1. **Registration:**
   - Open the app
   - Go through onboarding
   - Register with a new email/password
   - Check if user appears in Supabase "Authentication" → "Users"

2. **Habit Management:**
   - Create a new habit
   - Check if it appears in "Table Editor" → "habits"
   - Mark habit as complete
   - Check if completion appears in "habit_completions" table

3. **Data Sync:**
   - Log out and log back in
   - Verify habits persist across sessions
   - Try on different devices with same account

## Step 7: Production Setup (Optional)

For production deployment:

1. **Environment Variables:**
   - Create separate Supabase projects for staging/production
   - Use environment variables or build configurations
   - Never commit API keys to version control

2. **Email Configuration:**
   - Set up custom SMTP for email authentication
   - Configure proper redirect URLs for your domain

3. **Security:**
   - Review RLS policies
   - Set up proper backup strategies
   - Monitor usage and performance

## Troubleshooting

### Common Issues:

1. **"Invalid API Key" Error:**
   - Double-check your URL and anon key
   - Ensure no extra spaces or characters
   - Verify project is not paused

2. **Authentication Not Working:**
   - Check if email confirmation is required
   - Verify redirect URLs are correct
   - Check Supabase logs in dashboard

3. **Database Errors:**
   - Ensure schema was created successfully
   - Check RLS policies are enabled
   - Verify user has proper permissions

4. **Network Issues:**
   - Check internet connection
   - Verify Supabase project is active
   - Try different network if behind firewall

### Useful Supabase Dashboard Sections:

- **Table Editor:** View and edit data directly
- **Authentication:** Manage users and auth settings  
- **API Logs:** Debug API calls and errors
- **Database:** Monitor performance and usage
- **Storage:** Manage file uploads (for future features)

## Features Enabled

✅ **User Authentication**
- Email/password registration and login
- Password reset functionality
- Automatic user profile creation

✅ **Habit Management**
- Create, update, delete habits
- Real-time sync across devices
- Offline support with fallback

✅ **Progress Tracking**
- Daily habit completions
- Streak calculations
- Historical data storage

✅ **Security**
- Row Level Security (RLS)
- User data isolation
- Secure API access

## Next Steps (Future Enhancements)

1. **Real-time Subscriptions:**
   - Live updates when habits change
   - Multi-device synchronization

2. **File Storage:**
   - Profile pictures
   - Habit images/icons

3. **Social Features:**
   - Friend connections
   - Shared challenges
   - Leaderboards

4. **Analytics:**
   - Advanced streak calculations
   - Habit performance insights
   - Weekly/monthly reports

5. **Notifications:**
   - Push notifications for reminders
   - Achievement notifications
   - Streak milestone alerts
