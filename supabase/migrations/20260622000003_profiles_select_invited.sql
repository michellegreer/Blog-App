-- Extend profiles_select so circle managers can see profiles of people
-- they've already invited (who exist in auth.users but aren't in any circle yet).
-- Without this, "Add existing" can't find invited-but-not-yet-member users.

DROP POLICY IF EXISTS "profiles_select" ON public.profiles;

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
  OR EXISTS (
    SELECT 1 FROM public.circle_invites ci
    WHERE ci.invited_by = auth.uid()
      AND ci.invitee_email = profiles.email
  )
);
