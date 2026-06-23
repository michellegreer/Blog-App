import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'No authorization header' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const siteUrl = Deno.env.get('SITE_URL') ?? 'https://kittiesftw.com'

    const adminClient = createClient(supabaseUrl, serviceRoleKey)
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    })

    // Verify caller identity
    const { data: { user }, error: userError } = await userClient.auth.getUser()
    if (userError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Allow admins OR circle registrants/co-registrants to invite
    const [{ data: profile }, { data: registrantOf }] = await Promise.all([
      adminClient.from('profiles').select('is_admin').eq('id', user.id).single(),
      adminClient
        .from('family_circles')
        .select('id')
        .or(`registrant_id.eq.${user.id},co_registrant_id.eq.${user.id}`)
        .limit(1),
    ])

    const canInvite = profile?.is_admin || (registrantOf && registrantOf.length > 0)
    if (!canInvite) {
      return new Response(JSON.stringify({ error: 'Only circle managers can invite people' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const { email, name, redirectTo } = await req.json()
    if (!email || typeof email !== 'string') {
      return new Response(JSON.stringify({ error: 'Email is required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Use the redirect URL passed by the client (it knows its own origin),
    // falling back to SITE_URL for any non-web callers.
    const inviteRedirectTo = (typeof redirectTo === 'string' && redirectTo.startsWith('http'))
      ? redirectTo
      : `${siteUrl}/complete-profile`

    const { error: inviteError } = await adminClient.auth.admin.inviteUserByEmail(email, {
      data: { name: name ?? '' },
      redirectTo: inviteRedirectTo,
    })

    if (inviteError && !inviteError.message.toLowerCase().includes('already been registered')) {
      throw inviteError
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Unknown error'
    console.error('send-invite error:', message)
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
