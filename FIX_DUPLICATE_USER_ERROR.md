# 🔧 Fix Duplicate User Profile Error

## Problem
You're getting this error when registering:
```
PostgrestException(message: duplicate key value violates unique constraint "users_pkey", code: 23505)
```

## Root Cause
Your Supabase database has an **automatic trigger** (`handle_new_user`) that creates user profiles when someone signs up. The app code was **also** trying to create the profile manually, causing a duplicate.

## ✅ What I Fixed

### In Code (`lib/services/supabase_service.dart`)
- ✅ Removed manual `_createUserProfile()` call from signup
- ✅ Now relies on database trigger to create profiles automatically
- ✅ Added logging to confirm trigger-based creation

## 🚀 How to Test

### Option 1: Register a New User (Recommended)
1. **Hot restart your app**
2. **Register with a NEW email** (one you haven't used before)
3. Should work without errors!

### Option 2: Clean Up and Re-register
If you want to use the same email you just tried:

1. **Delete the test user from Supabase**:
   - Go to Supabase Dashboard → **Authentication** → **Users**
   - Find your test user
   - Click the **trash icon** to delete
   - Go to **Table Editor** → **users** table
   - Delete the user profile if it exists there too

2. **Hot restart your app**

3. **Register again** with the same email

## 🔍 Verify Database Trigger

Your database should have this trigger (created by `supabase_schema.sql`):

```sql
-- Check if trigger exists
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
```

Should return:
```
trigger_name         | event_manipulation | event_object_table
---------------------|--------------------|-----------------
on_auth_user_created | INSERT             | users
```

## 📋 What Happens Now

When you register:
1. ✅ User created in `auth.users` (Supabase Auth)
2. ✅ Trigger `on_auth_user_created` fires automatically
3. ✅ Function `handle_new_user()` creates profile in `public.users`
4. ✅ Function also creates entry in `user_stats`
5. ✅ No duplicate key errors!

## 🎯 Console Output

After the fix, you should see:
```
📝 SignUp Request for: user@example.com
   ✅ Using REAL Supabase for signup
   ✅ User profile will be auto-created by database trigger
```

## ⚠️ If Still Getting Errors

### Error: "Trigger not found"
Run the full `supabase_schema.sql` again - the trigger might not have been created.

### Error: "User already exists"
Delete the user from both:
- **Authentication** → **Users**
- **Table Editor** → **users**

Then try again.

## ✅ Success Indicators

After registering successfully:
1. ✅ No errors in console
2. ✅ User appears in **Authentication** → **Users**
3. ✅ Profile appears in **Table Editor** → **users**
4. ✅ Stats entry in **Table Editor** → **user_stats**
5. ✅ Can login with the new account

## 🎉 You're All Set!

The duplicate user error is now fixed. The database trigger handles all user profile creation automatically!
