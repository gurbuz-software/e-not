# Database Migrations

This directory contains SQL migration files for the e-library notes application.

## Migration Files

### 1. `01_initial_schema.sql`
- **Purpose**: Creates the complete database schema for the notes application
- **Contains**: 
  - User profiles table
  - Folders table for organizing notes
  - Notes table with JSONB content support
  - Row Level Security (RLS) policies
  - Indexes for performance
  - Triggers for automatic timestamps and content text extraction
  - Functions for user profile auto-creation

### 2. `02_fix_rls_policies.sql`
- **Purpose**: Fixes Row Level Security policies for better authentication handling
- **Contains**: Enhanced RLS policies that properly check authentication state

### 3. `03_add_admin_functionality.sql`
- **Purpose**: Adds admin functionality to the application
- **Contains**:
  - Admin role column in user_profiles table
  - Admin-only functions for managing all notes and users
  - Enhanced RLS policies for admin access
  - Functions for admin note management (view, edit, delete)
  - User management functions for admin privileges

## How to Apply Migrations

1. **First Time Setup**: Run `01_initial_schema.sql` in your Supabase SQL Editor
2. **Fix Authentication Issues**: Run `02_fix_rls_policies.sql` if you encounter RLS related issues
3. **Add Admin Features**: Run `03_add_admin_functionality.sql` to enable admin panel
4. **Create Admin User**: 
   - First register a normal user account through the app
   - Then run this SQL to make them admin:
   ```sql
   UPDATE public.user_profiles 
   SET is_admin = TRUE 
   WHERE email = 'your-admin@email.com';
   ```

## Database Schema Overview

```
auth.users (Supabase built-in)
├── user_profiles (1:1 relationship)
├── folders (1:many relationship)
└── notes (1:many relationship)
    └── folder_id (many:1 with folders)
```

## Features Enabled

- ✅ Row Level Security on all tables
- ✅ Automatic user profile creation on signup
- ✅ Full-text search on notes content
- ✅ Automatic timestamp updates
- ✅ Hierarchical folder structure
- ✅ Note favoriting and archiving
- ✅ Tag system for notes
- ✅ JSONB content storage (Notion-style)
- ✅ Admin panel for managing all users and notes
- ✅ Admin role-based access control
- ✅ Admin functions with security checks

## Important Notes

- All migrations assume you're using Supabase
- User authentication is handled by Supabase Auth
- The content field uses JSONB for rich text storage
- The content_text field is automatically generated for search purposes
