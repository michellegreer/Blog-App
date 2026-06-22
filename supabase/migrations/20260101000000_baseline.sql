-- Recreates the original schema that predates CLI migration history.
-- This exists in production already; needed for fresh environments like staging.

CREATE TABLE IF NOT EXISTS public.profiles (
  id             uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name           text,
  role           text NOT NULL DEFAULT 'user',
  is_approved    boolean NOT NULL DEFAULT false,
  approval_token text,
  avatar_url     text,
  bio            text
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.video_posts (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title             text NOT NULL,
  youtube_url       text NOT NULL,
  commentary        text,
  posted_by_name    text,
  posted_by_id      uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  poster_avatar_url text,
  created_at        timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.video_posts ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.comments (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  video_post_id   uuid NOT NULL REFERENCES public.video_posts(id) ON DELETE CASCADE,
  user_id         uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  user_name       text NOT NULL,
  user_avatar_url text,
  content         text NOT NULL,
  created_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.blogs (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  poster_id   uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  title       text,
  description text,
  image_url   text,
  topic       text[] NOT NULL DEFAULT '{}',
  updated_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.blogs ENABLE ROW LEVEL SECURITY;
