-- =====================================================
-- FIX RLS POLICIES FOR NOTES TABLE
-- =====================================================
-- This migration fixes the Row Level Security policies
-- to handle authentication state properly

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own notes" ON public.notes;
DROP POLICY IF EXISTS "Users can insert their own notes" ON public.notes;
DROP POLICY IF EXISTS "Users can update their own notes" ON public.notes;
DROP POLICY IF EXISTS "Users can delete their own notes" ON public.notes;

-- Create more robust RLS policies that handle auth better
CREATE POLICY "Users can view their own notes" ON public.notes
  FOR SELECT USING (
    auth.uid() IS NOT NULL AND 
    auth.uid() = user_id
  );

CREATE POLICY "Users can insert their own notes" ON public.notes
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    auth.uid() = user_id
  );

CREATE POLICY "Users can update their own notes" ON public.notes
  FOR UPDATE USING (
    auth.uid() IS NOT NULL AND 
    auth.uid() = user_id
  );

CREATE POLICY "Users can delete their own notes" ON public.notes
  FOR DELETE USING (
    auth.uid() IS NOT NULL AND 
    auth.uid() = user_id
  );

-- Also fix user_profiles policies
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;

CREATE POLICY "Users can view their own profile" ON public.user_profiles
  FOR SELECT USING (
    auth.uid() IS NOT NULL AND 
    auth.uid() = id
  );

CREATE POLICY "Users can update their own profile" ON public.user_profiles
  FOR UPDATE USING (
    auth.uid() IS NOT NULL AND 
    auth.uid() = id
  );

CREATE POLICY "Users can insert their own profile" ON public.user_profiles
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    auth.uid() = id
  );

-- Fix folders policies
DROP POLICY IF EXISTS "Users can view their own folders" ON public.folders;
DROP POLICY IF EXISTS "Users can insert their own folders" ON public.folders;
DROP POLICY IF EXISTS "Users can update their own folders" ON public.folders;
DROP POLICY IF EXISTS "Users can delete their own folders" ON public.folders;

CREATE POLICY "Users can view their own folders" ON public.folders
  FOR SELECT USING (
    auth.uid() IS NOT NULL AND 
    auth.uid() = user_id
  );

CREATE POLICY "Users can insert their own folders" ON public.folders
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    auth.uid() = user_id
  );

CREATE POLICY "Users can update their own folders" ON public.folders
  FOR UPDATE USING (
    auth.uid() IS NOT NULL AND 
    auth.uid() = user_id
  );

CREATE POLICY "Users can delete their own folders" ON public.folders
  FOR DELETE USING (
    auth.uid() IS NOT NULL AND 
    auth.uid() = user_id
  );
