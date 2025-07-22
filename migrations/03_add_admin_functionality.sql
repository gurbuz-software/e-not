-- =====================================================
-- ADMIN FUNCTIONALITY MIGRATION
-- =====================================================
-- This migration adds admin functionality to the notes application
-- Allows admin users to view, edit, and delete all notes

-- =====================================================
-- STEP 1: ADD ADMIN ROLE TO USER PROFILES
-- =====================================================

-- Add is_admin column to user_profiles table
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- Create index for faster admin queries
CREATE INDEX IF NOT EXISTS user_profiles_is_admin_idx ON public.user_profiles(is_admin);

-- =====================================================
-- STEP 2: CREATE ADMIN FUNCTIONS
-- =====================================================

-- Function to check if current user is admin
CREATE OR REPLACE FUNCTION public.is_current_user_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_profiles 
    WHERE id = auth.uid() AND is_admin = TRUE
  );
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

-- Function to get all notes with user details (admin only)
CREATE OR REPLACE FUNCTION public.get_all_notes_admin()
RETURNS TABLE (
  note_id UUID,
  note_title TEXT,
  note_content JSONB,
  note_content_text TEXT,
  note_is_favorite BOOLEAN,
  note_is_archived BOOLEAN,
  note_folder_id UUID,
  note_tags TEXT[],
  note_created_at TIMESTAMP WITH TIME ZONE,
  note_updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID,
  user_email TEXT,
  user_first_name TEXT,
  user_last_name TEXT,
  folder_name TEXT
) AS $$
BEGIN
  -- Check if current user is admin
  IF NOT public.is_current_user_admin() THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  RETURN QUERY
  SELECT 
    n.id as note_id,
    n.title as note_title,
    n.content as note_content,
    n.content_text as note_content_text,
    n.is_favorite as note_is_favorite,
    n.is_archived as note_is_archived,
    n.folder_id as note_folder_id,
    n.tags as note_tags,
    n.created_at as note_created_at,
    n.updated_at as note_updated_at,
    n.user_id,
    up.email as user_email,
    up.first_name as user_first_name,
    up.last_name as user_last_name,
    f.name as folder_name
  FROM public.notes n
  LEFT JOIN public.user_profiles up ON n.user_id = up.id
  LEFT JOIN public.folders f ON n.folder_id = f.id
  ORDER BY n.updated_at DESC;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

-- Function to get all users (admin only)
CREATE OR REPLACE FUNCTION public.get_all_users_admin()
RETURNS TABLE (
  user_id UUID,
  email TEXT,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  is_admin BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE,
  notes_count BIGINT
) AS $$
BEGIN
  -- Check if current user is admin
  IF NOT public.is_current_user_admin() THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  RETURN QUERY
  SELECT 
    up.id as user_id,
    up.email,
    up.first_name,
    up.last_name,
    up.avatar_url,
    up.is_admin,
    up.created_at,
    up.updated_at,
    COALESCE(note_counts.count, 0) as notes_count
  FROM public.user_profiles up
  LEFT JOIN (
    SELECT user_id, COUNT(*) as count 
    FROM public.notes 
    WHERE is_archived = FALSE 
    GROUP BY user_id
  ) note_counts ON up.id = note_counts.user_id
  ORDER BY up.created_at DESC;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

-- =====================================================
-- STEP 3: CREATE ADMIN RLS POLICIES
-- =====================================================

-- Admin can view all notes policy
CREATE POLICY "Admins can view all notes" ON public.notes
  FOR SELECT USING (
    public.is_current_user_admin()
  );

-- Admin can update all notes policy
CREATE POLICY "Admins can update all notes" ON public.notes
  FOR UPDATE USING (
    public.is_current_user_admin()
  );

-- Admin can delete all notes policy
CREATE POLICY "Admins can delete all notes" ON public.notes
  FOR DELETE USING (
    public.is_current_user_admin()
  );

-- Admin can view all user profiles policy
CREATE POLICY "Admins can view all profiles" ON public.user_profiles
  FOR SELECT USING (
    public.is_current_user_admin()
  );

-- Admin can view all folders policy
CREATE POLICY "Admins can view all folders" ON public.folders
  FOR SELECT USING (
    public.is_current_user_admin()
  );

-- =====================================================
-- STEP 4: CREATE ADMIN MANAGEMENT FUNCTIONS
-- =====================================================

-- Function to update note as admin
CREATE OR REPLACE FUNCTION public.admin_update_note(
  p_note_id UUID,
  p_title TEXT DEFAULT NULL,
  p_content JSONB DEFAULT NULL,
  p_content_text TEXT DEFAULT NULL,
  p_is_favorite BOOLEAN DEFAULT NULL,
  p_is_archived BOOLEAN DEFAULT NULL,
  p_folder_id UUID DEFAULT NULL,
  p_tags TEXT[] DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  update_query TEXT := 'UPDATE public.notes SET updated_at = NOW()';
  param_count INTEGER := 0;
BEGIN
  -- Check if current user is admin
  IF NOT public.is_current_user_admin() THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  -- Build dynamic update query
  IF p_title IS NOT NULL THEN
    update_query := update_query || ', title = $' || (param_count + 2);
    param_count := param_count + 1;
  END IF;

  IF p_content IS NOT NULL THEN
    update_query := update_query || ', content = $' || (param_count + 2);
    param_count := param_count + 1;
  END IF;

  IF p_content_text IS NOT NULL THEN
    update_query := update_query || ', content_text = $' || (param_count + 2);
    param_count := param_count + 1;
  END IF;

  IF p_is_favorite IS NOT NULL THEN
    update_query := update_query || ', is_favorite = $' || (param_count + 2);
    param_count := param_count + 1;
  END IF;

  IF p_is_archived IS NOT NULL THEN
    update_query := update_query || ', is_archived = $' || (param_count + 2);
    param_count := param_count + 1;
  END IF;

  IF p_folder_id IS NOT NULL THEN
    update_query := update_query || ', folder_id = $' || (param_count + 2);
    param_count := param_count + 1;
  END IF;

  IF p_tags IS NOT NULL THEN
    update_query := update_query || ', tags = $' || (param_count + 2);
    param_count := param_count + 1;
  END IF;

  update_query := update_query || ' WHERE id = $1 RETURNING id';

  -- Execute the update (simplified version - in practice you'd use EXECUTE)
  UPDATE public.notes 
  SET 
    title = COALESCE(p_title, title),
    content = COALESCE(p_content, content),
    content_text = COALESCE(p_content_text, content_text),
    is_favorite = COALESCE(p_is_favorite, is_favorite),
    is_archived = COALESCE(p_is_archived, is_archived),
    folder_id = COALESCE(p_folder_id, folder_id),
    tags = COALESCE(p_tags, tags),
    updated_at = NOW()
  WHERE id = p_note_id;

  RETURN FOUND;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

-- Function to delete note as admin
CREATE OR REPLACE FUNCTION public.admin_delete_note(p_note_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if current user is admin
  IF NOT public.is_current_user_admin() THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  DELETE FROM public.notes WHERE id = p_note_id;
  RETURN FOUND;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

-- =====================================================
-- STEP 5: GRANT PERMISSIONS
-- =====================================================

-- Grant execute permissions on admin functions to authenticated users
GRANT EXECUTE ON FUNCTION public.is_current_user_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_all_notes_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_all_users_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_update_note(UUID, TEXT, JSONB, TEXT, BOOLEAN, BOOLEAN, UUID, TEXT[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_delete_note(UUID) TO authenticated;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
-- Admin functionality has been added!
-- 
-- To create an admin user:
-- 1. Register a normal user account
-- 2. Run: UPDATE public.user_profiles SET is_admin = TRUE WHERE email = 'admin@example.com';
-- 
-- Admin features:
-- - View all notes from all users
-- - Edit any note
-- - Delete any note  
-- - View all users and their note counts
-- - Admin-only functions with security checks
