-- =====================================================
-- COMPLETE NOTES APPLICATION DATABASE MIGRATION
-- =====================================================
-- This migration sets up the complete database schema for the notes application
-- Run this as a single script in Supabase SQL Editor

-- =====================================================
-- STEP 1: CLEANUP - Remove existing tables and dependencies
-- =====================================================

-- Drop existing tables if they exist (including the ones from your image: notes, profiles, user_profiles)
DROP TABLE IF EXISTS public.notes CASCADE;
DROP TABLE IF EXISTS public.folders CASCADE;
DROP TABLE IF EXISTS public.user_profiles CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Drop existing functions
DROP FUNCTION IF EXISTS public.handle_updated_at() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.update_notes_content_text() CASCADE;

-- Drop existing triggers (these will safely ignore if they don't exist)
DO $$
BEGIN
    DROP TRIGGER IF EXISTS on_user_profiles_updated ON public.user_profiles;
    DROP TRIGGER IF EXISTS on_notes_updated ON public.notes;
    DROP TRIGGER IF EXISTS on_folders_updated ON public.folders;
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
    DROP TRIGGER IF EXISTS on_notes_content_update ON public.notes;
    DROP TRIGGER IF EXISTS on_profiles_updated ON public.profiles;
EXCEPTION
    WHEN undefined_table THEN
        -- Ignore if table doesn't exist
        NULL;
END $$;

-- Clean up any existing RLS policies (these will safely ignore if they don't exist)
DO $$
BEGIN
    DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
    DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
    DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;
    DROP POLICY IF EXISTS "Users can view their own notes" ON public.notes;
    DROP POLICY IF EXISTS "Users can insert their own notes" ON public.notes;
    DROP POLICY IF EXISTS "Users can update their own notes" ON public.notes;
    DROP POLICY IF EXISTS "Users can delete their own notes" ON public.notes;
    DROP POLICY IF EXISTS "Users can view their own folders" ON public.folders;
    DROP POLICY IF EXISTS "Users can insert their own folders" ON public.folders;
    DROP POLICY IF EXISTS "Users can update their own folders" ON public.folders;
    DROP POLICY IF EXISTS "Users can delete their own folders" ON public.folders;
    DROP POLICY IF EXISTS "Users can view their own profiles" ON public.profiles;
    DROP POLICY IF EXISTS "Users can update their own profiles" ON public.profiles;
    DROP POLICY IF EXISTS "Users can insert their own profiles" ON public.profiles;
EXCEPTION
    WHEN undefined_table THEN
        -- Ignore if table doesn't exist
        NULL;
END $$;

-- =====================================================
-- STEP 2: CREATE UTILITY FUNCTIONS
-- =====================================================

-- Function to handle updated_at timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- =====================================================
-- STEP 3: CREATE USER PROFILES TABLE
-- =====================================================

-- User profiles table extends auth.users with additional information
CREATE TABLE public.user_profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  email TEXT UNIQUE,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  preferences JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  PRIMARY KEY (id)
);

-- Create updated_at trigger for user_profiles
CREATE TRIGGER on_user_profiles_updated
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_updated_at();

-- Enable Row Level Security for user_profiles
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for user_profiles
CREATE POLICY "Users can view their own profile" ON public.user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.user_profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- =====================================================
-- STEP 4: CREATE FOLDERS TABLE
-- =====================================================

-- Folders table for organizing notes
CREATE TABLE public.folders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT DEFAULT '#6366f1',
  parent_id UUID REFERENCES public.folders ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create updated_at trigger for folders
CREATE TRIGGER on_folders_updated
  BEFORE UPDATE ON public.folders
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_updated_at();

-- Enable Row Level Security for folders
ALTER TABLE public.folders ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for folders
CREATE POLICY "Users can view their own folders" ON public.folders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own folders" ON public.folders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own folders" ON public.folders
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own folders" ON public.folders
  FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- STEP 5: CREATE NOTES TABLE
-- =====================================================

-- Notes table - main table for storing notes (Notion-style)
CREATE TABLE public.notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL DEFAULT 'Untitled',
  content JSONB DEFAULT '{"type":"doc","content":[]}' NOT NULL,
  content_text TEXT, -- Plain text version for search
  is_favorite BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  folder_id UUID REFERENCES public.folders ON DELETE SET NULL,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create updated_at trigger for notes
CREATE TRIGGER on_notes_updated
  BEFORE UPDATE ON public.notes
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_updated_at();

-- Enable Row Level Security for notes
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for notes
CREATE POLICY "Users can view their own notes" ON public.notes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notes" ON public.notes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own notes" ON public.notes
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notes" ON public.notes
  FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- STEP 6: CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Indexes for notes table
CREATE INDEX notes_user_id_idx ON public.notes(user_id);
CREATE INDEX notes_created_at_idx ON public.notes(created_at DESC);
CREATE INDEX notes_updated_at_idx ON public.notes(updated_at DESC);
CREATE INDEX notes_folder_id_idx ON public.notes(folder_id);
CREATE INDEX notes_is_favorite_idx ON public.notes(is_favorite);
CREATE INDEX notes_is_archived_idx ON public.notes(is_archived);
CREATE INDEX notes_content_text_idx ON public.notes USING gin(to_tsvector('english', content_text));

-- Indexes for folders table
CREATE INDEX folders_user_id_idx ON public.folders(user_id);
CREATE INDEX folders_parent_id_idx ON public.folders(parent_id);

-- Indexes for user_profiles table
CREATE INDEX user_profiles_email_idx ON public.user_profiles(email);

-- =====================================================
-- STEP 7: CREATE CONTENT TEXT SEARCH FUNCTION
-- =====================================================

-- Function to update content_text when content changes
CREATE OR REPLACE FUNCTION public.update_notes_content_text()
RETURNS TRIGGER AS $$
BEGIN
  -- Extract text content from JSONB for search purposes
  -- This removes JSON formatting and extracts readable text
  NEW.content_text = regexp_replace(NEW.content::text, '[{}"\[\],:]+', ' ', 'g');
  NEW.content_text = regexp_replace(NEW.content_text, '\s+', ' ', 'g');
  NEW.content_text = trim(NEW.content_text);
  
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Create trigger for content_text update
CREATE TRIGGER on_notes_content_update
  BEFORE INSERT OR UPDATE ON public.notes
  FOR EACH ROW
  EXECUTE PROCEDURE public.update_notes_content_text();

-- =====================================================
-- STEP 8: AUTO-CREATE USER PROFILE ON SIGNUP
-- =====================================================

-- Function to automatically create user profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

-- Create trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_new_user();

-- =====================================================
-- STEP 9: INSERT SAMPLE DATA (OPTIONAL)
-- =====================================================

-- You can uncomment the following to insert sample data for testing
-- Note: This will only work after you have at least one user registered

/*
-- Insert sample folder (replace USER_ID with actual user ID)
INSERT INTO public.folders (user_id, name, description, color) 
VALUES ('YOUR_USER_ID_HERE', 'My First Folder', 'Sample folder for organizing notes', '#6366f1');

-- Insert sample note (replace USER_ID and FOLDER_ID with actual IDs)
INSERT INTO public.notes (user_id, title, content_text, folder_id, tags) 
VALUES (
  'YOUR_USER_ID_HERE', 
  'Welcome to Your Notes App', 
  'This is your first note! You can edit this and create many more.',
  'YOUR_FOLDER_ID_HERE',
  ARRAY['welcome', 'first-note']
);
*/

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
-- Your notes application database is now ready!
-- 
-- Tables created:
-- - user_profiles: Extended user information
-- - folders: For organizing notes
-- - notes: Main notes storage with JSONB content
--
-- Features enabled:
-- - Row Level Security (RLS) for all tables
-- - Automatic user profile creation on signup
-- - Full-text search on notes
-- - Automatic timestamp updates
-- - Hierarchical folder structure
-- - Note favoriting and archiving
-- - Tag system for notes
