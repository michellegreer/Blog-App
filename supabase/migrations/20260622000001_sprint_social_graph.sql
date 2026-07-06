-- ─────────────────────────────────────────────────────────────────────────────
-- Sprint: Social Graph & Access Control
-- Target: dev branch only (qvthsggxhwztqmqtjnri)
-- RLS strategy: all cross-table lookups inside policies go through
--               SECURITY DEFINER functions — zero recursive policy calls.
-- ─────────────────────────────────────────────────────────────────────────────


-- ── 1. Enums ──────────────────────────────────────────────────────────────────

CREATE TYPE public.circle_type   AS ENUM ('family', 'extended_family', 'friends');
CREATE TYPE public.invite_status AS ENUM ('pending', 'accepted', 'expired');


-- ── 2. Extend profiles ────────────────────────────────────────────────────────

ALTER TABLE public.profiles
  ADD COLUMN username   text UNIQUE,
  ADD COLUMN phone      text,
  ADD COLUMN is_admin   boolean NOT NULL DEFAULT false,
  ADD COLUMN created_at timestamptz NOT NULL DEFAULT now();

-- email stored on profile for invite lookup (Path B). Nullable; unique where set.
ALTER TABLE public.profiles ADD COLUMN email text;
CREATE UNIQUE INDEX profiles_email_unique
  ON public.profiles (email) WHERE email IS NOT NULL;

ALTER TABLE public.profiles
  DROP COLUMN IF EXISTS role,
  DROP COLUMN IF EXISTS is_approved,
  DROP COLUMN IF EXISTS approval_token;


-- ── 3. New tables ─────────────────────────────────────────────────────────────

CREATE TABLE public.family_circles (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name             text NOT NULL,
  registrant_id    uuid NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  co_registrant_id uuid           REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at       timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.family_circles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.family_circle_members (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_circle_id   uuid NOT NULL REFERENCES public.family_circles(id) ON DELETE CASCADE,
  profile_id         uuid NOT NULL REFERENCES public.profiles(id)      ON DELETE CASCADE,
  membership_type    text NOT NULL CHECK (membership_type IN ('adult','child')),
  can_post_to_family boolean NOT NULL DEFAULT false,
  created_at         timestamptz NOT NULL DEFAULT now(),
  UNIQUE (family_circle_id, profile_id)
);
ALTER TABLE public.family_circle_members ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.extended_family_circles (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_circle_id uuid NOT NULL UNIQUE REFERENCES public.family_circles(id) ON DELETE CASCADE,
  created_at       timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.extended_family_circles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.extended_family_circle_members (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  extended_family_circle_id uuid NOT NULL REFERENCES public.extended_family_circles(id) ON DELETE CASCADE,
  profile_id                uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  relationship_label        text,
  created_at                timestamptz NOT NULL DEFAULT now(),
  UNIQUE (extended_family_circle_id, profile_id)
);
ALTER TABLE public.extended_family_circle_members ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.friends_circles (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_circle_id uuid NOT NULL UNIQUE REFERENCES public.family_circles(id) ON DELETE CASCADE,
  created_at       timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.friends_circles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.friends_circle_members (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  friends_circle_id uuid NOT NULL REFERENCES public.friends_circles(id) ON DELETE CASCADE,
  profile_id        uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  added_by          uuid           REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE (friends_circle_id, profile_id)
);
ALTER TABLE public.friends_circle_members ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.circle_invites (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invited_by         uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  invitee_email      text NOT NULL,
  invite_token       text NOT NULL UNIQUE DEFAULT replace(gen_random_uuid()::text, '-', ''),
  target_circle_type public.circle_type NOT NULL,
  target_circle_id   uuid NOT NULL,
  status             public.invite_status NOT NULL DEFAULT 'pending',
  expires_at         timestamptz NOT NULL DEFAULT (now() + interval '72 hours'),
  created_at         timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.circle_invites ENABLE ROW LEVEL SECURITY;


-- ── 4. Extend video_posts ─────────────────────────────────────────────────────

ALTER TABLE public.video_posts
  ADD COLUMN visibility_circle_type public.circle_type,
  ADD COLUMN visibility_circle_id   uuid,
  ADD COLUMN is_public              boolean NOT NULL DEFAULT false;


-- ── 5. SECURITY DEFINER helper functions ──────────────────────────────────────

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT COALESCE((SELECT is_admin FROM profiles WHERE id = auth.uid()), false)
$$;

CREATE OR REPLACE FUNCTION public.my_family_circle_ids()
RETURNS SETOF uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT id FROM family_circles
    WHERE registrant_id = auth.uid() OR co_registrant_id = auth.uid()
  UNION
  SELECT family_circle_id FROM family_circle_members WHERE profile_id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.my_extended_family_circle_ids()
RETURNS SETOF uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT extended_family_circle_id
  FROM extended_family_circle_members
  WHERE profile_id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.my_friends_circle_ids()
RETURNS SETOF uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT friends_circle_id
  FROM friends_circle_members
  WHERE profile_id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.is_circle_manager(fc_id uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM family_circles
    WHERE id = fc_id
      AND (registrant_id = auth.uid() OR co_registrant_id = auth.uid())
  )
$$;


-- ── 6. RLS policies ───────────────────────────────────────────────────────────

-- profiles ────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "profiles_select" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update" ON public.profiles;
DROP POLICY IF EXISTS "profiles_delete" ON public.profiles;

CREATE POLICY "profiles_select" ON public.profiles FOR SELECT USING (
  id = auth.uid()
  OR public.is_admin()
  OR EXISTS (
    SELECT 1 FROM public.family_circle_members m
    WHERE m.profile_id = profiles.id
      AND m.family_circle_id IN (SELECT public.my_family_circle_ids())
  )
  OR EXISTS (
    SELECT 1 FROM public.extended_family_circle_members m
    WHERE m.profile_id = profiles.id
      AND m.extended_family_circle_id IN (SELECT public.my_extended_family_circle_ids())
  )
  OR EXISTS (
    SELECT 1 FROM public.friends_circle_members m
    WHERE m.profile_id = profiles.id
      AND m.friends_circle_id IN (SELECT public.my_friends_circle_ids())
  )
);

CREATE POLICY "profiles_insert" ON public.profiles FOR INSERT WITH CHECK (
  auth.uid() = id OR auth.role() = 'service_role'
);

CREATE POLICY "profiles_update" ON public.profiles FOR UPDATE USING (
  id = auth.uid() OR public.is_admin()
);

-- video_posts ─────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "video_posts_select" ON public.video_posts;
DROP POLICY IF EXISTS "video_posts_insert" ON public.video_posts;
DROP POLICY IF EXISTS "video_posts_update" ON public.video_posts;
DROP POLICY IF EXISTS "video_posts_delete" ON public.video_posts;

CREATE POLICY "video_posts_select" ON public.video_posts FOR SELECT USING (
  is_public = true
  OR (auth.uid() IS NOT NULL AND (
    public.is_admin()
    OR posted_by_id = auth.uid()
    OR (visibility_circle_type = 'family'
        AND visibility_circle_id IN (SELECT public.my_family_circle_ids()))
    OR (visibility_circle_type = 'extended_family' AND (
        visibility_circle_id IN (SELECT public.my_extended_family_circle_ids())
        OR EXISTS (
          SELECT 1 FROM public.extended_family_circles efc
          WHERE efc.id = video_posts.visibility_circle_id
            AND efc.family_circle_id IN (SELECT public.my_family_circle_ids())
        )
    ))
    OR (visibility_circle_type = 'friends' AND (
        visibility_circle_id IN (SELECT public.my_friends_circle_ids())
        OR EXISTS (
          SELECT 1 FROM public.friends_circles fc
          WHERE fc.id = video_posts.visibility_circle_id
            AND fc.family_circle_id IN (SELECT public.my_family_circle_ids())
        )
    ))
  ))
);

CREATE POLICY "video_posts_insert" ON public.video_posts FOR INSERT WITH CHECK (
  auth.uid() IS NOT NULL AND posted_by_id = auth.uid()
);

CREATE POLICY "video_posts_update" ON public.video_posts FOR UPDATE USING (
  posted_by_id = auth.uid() OR public.is_admin()
);

CREATE POLICY "video_posts_delete" ON public.video_posts FOR DELETE USING (
  posted_by_id = auth.uid() OR public.is_admin()
);

-- comments ────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "comments_select" ON public.comments;
DROP POLICY IF EXISTS "comments_insert" ON public.comments;
DROP POLICY IF EXISTS "comments_delete" ON public.comments;

-- Comments inherit parent post visibility; require auth (no comments for logged-out)
CREATE POLICY "comments_select" ON public.comments FOR SELECT USING (
  auth.uid() IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM public.video_posts vp WHERE vp.id = comments.video_post_id
  )
);

CREATE POLICY "comments_insert" ON public.comments FOR INSERT WITH CHECK (
  auth.uid() IS NOT NULL AND user_id = auth.uid()
);

CREATE POLICY "comments_delete" ON public.comments FOR DELETE USING (
  user_id = auth.uid() OR public.is_admin()
);

-- family_circles ──────────────────────────────────────────────────────────────
CREATE POLICY "family_circles_select" ON public.family_circles FOR SELECT USING (
  id IN (SELECT public.my_family_circle_ids()) OR public.is_admin()
);
CREATE POLICY "family_circles_insert" ON public.family_circles FOR INSERT WITH CHECK (
  auth.uid() IS NOT NULL AND registrant_id = auth.uid()
);
CREATE POLICY "family_circles_update" ON public.family_circles FOR UPDATE USING (
  public.is_circle_manager(id) OR public.is_admin()
);
CREATE POLICY "family_circles_delete" ON public.family_circles FOR DELETE USING (
  public.is_admin()
);

-- family_circle_members ───────────────────────────────────────────────────────
CREATE POLICY "fcm_select" ON public.family_circle_members FOR SELECT USING (
  family_circle_id IN (SELECT public.my_family_circle_ids()) OR public.is_admin()
);
CREATE POLICY "fcm_insert" ON public.family_circle_members FOR INSERT WITH CHECK (
  public.is_circle_manager(family_circle_id) OR public.is_admin()
);
CREATE POLICY "fcm_delete" ON public.family_circle_members FOR DELETE USING (
  public.is_circle_manager(family_circle_id) OR public.is_admin()
);

-- extended_family_circles ─────────────────────────────────────────────────────
CREATE POLICY "efc_select" ON public.extended_family_circles FOR SELECT USING (
  family_circle_id IN (SELECT public.my_family_circle_ids())
  OR id IN (SELECT public.my_extended_family_circle_ids())
  OR public.is_admin()
);
CREATE POLICY "efc_insert" ON public.extended_family_circles FOR INSERT WITH CHECK (
  public.is_circle_manager(family_circle_id) OR public.is_admin()
);

-- extended_family_circle_members ──────────────────────────────────────────────
CREATE POLICY "efcm_select" ON public.extended_family_circle_members FOR SELECT USING (
  extended_family_circle_id IN (SELECT public.my_extended_family_circle_ids())
  OR EXISTS (
    SELECT 1 FROM public.extended_family_circles efc
    WHERE efc.id = extended_family_circle_id
      AND efc.family_circle_id IN (SELECT public.my_family_circle_ids())
  )
  OR public.is_admin()
);
CREATE POLICY "efcm_insert" ON public.extended_family_circle_members FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.extended_family_circles efc
    WHERE efc.id = extended_family_circle_id
      AND public.is_circle_manager(efc.family_circle_id)
  ) OR public.is_admin()
);
CREATE POLICY "efcm_delete" ON public.extended_family_circle_members FOR DELETE USING (
  EXISTS (
    SELECT 1 FROM public.extended_family_circles efc
    WHERE efc.id = extended_family_circle_id
      AND public.is_circle_manager(efc.family_circle_id)
  ) OR public.is_admin()
);

-- friends_circles ─────────────────────────────────────────────────────────────
CREATE POLICY "fc_select" ON public.friends_circles FOR SELECT USING (
  family_circle_id IN (SELECT public.my_family_circle_ids())
  OR id IN (SELECT public.my_friends_circle_ids())
  OR public.is_admin()
);
CREATE POLICY "fc_insert" ON public.friends_circles FOR INSERT WITH CHECK (
  public.is_circle_manager(family_circle_id) OR public.is_admin()
);

-- friends_circle_members ──────────────────────────────────────────────────────
CREATE POLICY "fcm2_select" ON public.friends_circle_members FOR SELECT USING (
  friends_circle_id IN (SELECT public.my_friends_circle_ids())
  OR EXISTS (
    SELECT 1 FROM public.friends_circles fc
    WHERE fc.id = friends_circle_id
      AND fc.family_circle_id IN (SELECT public.my_family_circle_ids())
  )
  OR public.is_admin()
);
CREATE POLICY "fcm2_insert" ON public.friends_circle_members FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.friends_circles fc
    WHERE fc.id = friends_circle_id
      AND (
        public.is_circle_manager(fc.family_circle_id)
        OR fc.family_circle_id IN (SELECT public.my_family_circle_ids())
      )
  ) OR public.is_admin()
);
CREATE POLICY "fcm2_delete" ON public.friends_circle_members FOR DELETE USING (
  EXISTS (
    SELECT 1 FROM public.friends_circles fc
    WHERE fc.id = friends_circle_id
      AND public.is_circle_manager(fc.family_circle_id)
  ) OR public.is_admin()
);

-- circle_invites ──────────────────────────────────────────────────────────────
CREATE POLICY "invites_select" ON public.circle_invites FOR SELECT USING (
  invited_by = auth.uid() OR public.is_admin()
);
CREATE POLICY "invites_insert" ON public.circle_invites FOR INSERT WITH CHECK (
  auth.uid() IS NOT NULL AND invited_by = auth.uid()
);
CREATE POLICY "invites_update" ON public.circle_invites FOR UPDATE USING (
  invited_by = auth.uid() OR public.is_admin()
);


-- ── 7. handle_new_user trigger ────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ── 8. Data migration ─────────────────────────────────────────────────────────

-- Backfill email on existing profiles from auth.users
UPDATE public.profiles p
SET email = au.email
FROM auth.users au
WHERE p.id = au.id AND p.email IS NULL;

-- Set is_admin for Michelle
UPDATE public.profiles p
SET is_admin = true
FROM auth.users au
WHERE p.id = au.id AND au.email = 'michelle@michellegreer.com';

-- Create The Family circle with Michelle as registrant
WITH new_circle AS (
  INSERT INTO public.family_circles (name, registrant_id)
  SELECT 'The Family', p.id
  FROM public.profiles p
  WHERE p.email = 'michelle@michellegreer.com'
  RETURNING id, registrant_id
),
_member AS (
  INSERT INTO public.family_circle_members
    (family_circle_id, profile_id, membership_type, can_post_to_family)
  SELECT nc.id, nc.registrant_id, 'adult', true FROM new_circle nc
),
_efc AS (
  INSERT INTO public.extended_family_circles (family_circle_id)
  SELECT id FROM new_circle
)
INSERT INTO public.friends_circles (family_circle_id)
SELECT id FROM new_circle;

-- Point all existing video_posts at The Family circle
UPDATE public.video_posts
SET visibility_circle_type = 'family',
    visibility_circle_id   = (SELECT id FROM public.family_circles LIMIT 1)
WHERE visibility_circle_id IS NULL;
