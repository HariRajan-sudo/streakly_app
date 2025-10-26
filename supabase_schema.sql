-- Supabase Database Schema for Streakly Habit Tracker App
-- Run these commands in your Supabase SQL Editor

-- Create users table (extends auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    avatar_url TEXT,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create habits table
CREATE TABLE public.habits (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    icon_code_point BIGINT NOT NULL,
    color_value BIGINT NOT NULL,
    frequency TEXT NOT NULL DEFAULT 'daily', -- daily, weekly, monthly
    time_of_day TEXT NOT NULL DEFAULT 'night', -- morning, afternoon, evening, night
    is_active BOOLEAN DEFAULT TRUE,
    reminder_hour INTEGER,
    reminder_minute INTEGER,
    reminders_per_day INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create habit_completions table
CREATE TABLE public.habit_completions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    completion_date DATE NOT NULL,
    completion_count INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(habit_id, completion_date)
);

-- Create user_stats table (for analytics and leaderboards)
CREATE TABLE public.user_stats (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    total_habits INTEGER DEFAULT 0,
    total_completions INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_habits_user_id ON public.habits(user_id);
CREATE INDEX idx_habits_created_at ON public.habits(created_at);
CREATE INDEX idx_habit_completions_habit_id ON public.habit_completions(habit_id);
CREATE INDEX idx_habit_completions_user_id ON public.habit_completions(user_id);
CREATE INDEX idx_habit_completions_date ON public.habit_completions(completion_date);
CREATE INDEX idx_user_stats_user_id ON public.user_stats(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies

-- Users can only see and modify their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Users can only see and modify their own habits
CREATE POLICY "Users can view own habits" ON public.habits
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own habits" ON public.habits
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habits" ON public.habits
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own habits" ON public.habits
    FOR DELETE USING (auth.uid() = user_id);

-- Users can only see and modify their own habit completions
CREATE POLICY "Users can view own completions" ON public.habit_completions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own completions" ON public.habit_completions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own completions" ON public.habit_completions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own completions" ON public.habit_completions
    FOR DELETE USING (auth.uid() = user_id);

-- Users can only see and modify their own stats
CREATE POLICY "Users can view own stats" ON public.user_stats
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stats" ON public.user_stats
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stats" ON public.user_stats
    FOR UPDATE USING (auth.uid() = user_id);

-- Create functions for automatic timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for automatic timestamps
CREATE TRIGGER handle_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_habits_updated_at
    BEFORE UPDATE ON public.habits
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_habit_completions_updated_at
    BEFORE UPDATE ON public.habit_completions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_user_stats_updated_at
    BEFORE UPDATE ON public.user_stats
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create function to automatically create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
    );
    
    INSERT INTO public.user_stats (user_id)
    VALUES (NEW.id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Create function to update user stats
CREATE OR REPLACE FUNCTION public.update_user_stats(user_uuid UUID)
RETURNS VOID AS $$
DECLARE
    habit_count INTEGER;
    completion_count INTEGER;
    current_streak INTEGER;
    longest_streak INTEGER;
BEGIN
    -- Count total habits
    SELECT COUNT(*) INTO habit_count
    FROM public.habits
    WHERE user_id = user_uuid AND is_active = TRUE;
    
    -- Count total completions
    SELECT COUNT(*) INTO completion_count
    FROM public.habit_completions
    WHERE user_id = user_uuid;
    
    -- Calculate current streak (simplified - you may want to implement more complex logic)
    SELECT COALESCE(MAX(completion_count), 0) INTO current_streak
    FROM public.habit_completions
    WHERE user_id = user_uuid AND completion_date = CURRENT_DATE;
    
    -- Calculate longest streak (simplified)
    SELECT COALESCE(MAX(completion_count), 0) INTO longest_streak
    FROM public.habit_completions
    WHERE user_id = user_uuid;
    
    -- Update user stats
    UPDATE public.user_stats
    SET 
        total_habits = habit_count,
        total_completions = completion_count,
        current_streak = current_streak,
        longest_streak = GREATEST(longest_streak, current_streak),
        last_activity_date = CURRENT_DATE,
        updated_at = NOW()
    WHERE user_id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
