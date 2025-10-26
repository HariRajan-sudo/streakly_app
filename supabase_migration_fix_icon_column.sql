-- Migration: Fix icon_code_point and color_value column types
-- This fixes the "value is out of range for type integer" error
-- Run this in Supabase SQL Editor if you already created the habits table

-- Change icon_code_point from INTEGER to BIGINT
ALTER TABLE public.habits 
ALTER COLUMN icon_code_point TYPE BIGINT;

-- Change color_value from INTEGER to BIGINT
ALTER TABLE public.habits 
ALTER COLUMN color_value TYPE BIGINT;

-- Verify the changes
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'habits' 
AND column_name IN ('icon_code_point', 'color_value');
