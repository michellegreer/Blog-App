-- On a closed/invite-only platform, any authenticated user should be able
-- to search for any other user's profile (for circle management).
-- The previous policy blocked finding users not yet in a shared circle.

DROP POLICY IF EXISTS "profiles_select" ON public.profiles;

CREATE POLICY "profiles_select" ON public.profiles FOR SELECT USING (
  auth.uid() IS NOT NULL OR public.is_admin()
);
