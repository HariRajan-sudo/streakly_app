-- Migration: Update existing "anytime" habits to "night"
-- Run this in Supabase SQL Editor if you have existing habits with time_of_day = 'anytime'

-- Step 1: Check how many habits need updating
SELECT COUNT(*) as anytime_habits_count
FROM public.habits
WHERE time_of_day = 'anytime';

-- Step 2: Preview which habits will be updated
SELECT id, name, time_of_day, created_at
FROM public.habits
WHERE time_of_day = 'anytime';

-- Step 3: Update all "anytime" habits to "night"
UPDATE public.habits 
SET time_of_day = 'night',
    updated_at = NOW()
WHERE time_of_day = 'anytime';

-- Step 4: Verify the update
SELECT time_of_day, COUNT(*) as count
FROM public.habits
GROUP BY time_of_day
ORDER BY time_of_day;

-- Expected result after migration:
-- time_of_day | count
-- ------------|------
-- afternoon   | X
-- evening     | X
-- morning     | X
-- night       | X
