-- Grant table-level privileges to Supabase roles for all circle tables.
-- These are required in addition to RLS policies — RLS is evaluated AFTER
-- the role's table privilege is checked. Without these, authenticated users
-- get 42501 before any policy runs.

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.family_circles             TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.family_circle_members      TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.extended_family_circles    TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.extended_family_circle_members TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.friends_circles            TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.friends_circle_members     TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.circle_invites             TO authenticated;

-- anon can only read public-facing data (RLS further restricts this to is_public rows)
GRANT SELECT ON TABLE public.family_circles             TO anon;
GRANT SELECT ON TABLE public.family_circle_members      TO anon;
GRANT SELECT ON TABLE public.extended_family_circles    TO anon;
GRANT SELECT ON TABLE public.extended_family_circle_members TO anon;
GRANT SELECT ON TABLE public.friends_circles            TO anon;
GRANT SELECT ON TABLE public.friends_circle_members     TO anon;
GRANT SELECT ON TABLE public.circle_invites             TO anon;
