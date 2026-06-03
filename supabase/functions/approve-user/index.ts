import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  const url = new URL(req.url)
  const userId = url.searchParams.get('user_id')
  const token = url.searchParams.get('token')

  if (!userId || !token) {
    return new Response('Missing user_id or token', { status: 400 })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  // Verify the token matches what was stored at signup
  const { data: profile, error: fetchError } = await supabase
    .from('profiles')
    .select('approval_token, is_approved, name, email')
    .eq('id', userId)
    .single()

  if (fetchError || !profile) {
    return new Response('User not found', { status: 404 })
  }

  if (profile.is_approved) {
    return html('Already approved', `<p>${profile.name}'s account was already approved.</p>`)
  }

  if (profile.approval_token !== token) {
    return new Response('Invalid token', { status: 403 })
  }

  const { error: updateError } = await supabase
    .from('profiles')
    .update({ is_approved: true, approval_token: null })
    .eq('id', userId)

  if (updateError) {
    return new Response('Failed to approve user', { status: 500 })
  }

  return html(
    'Account approved!',
    `<p><strong>${profile.name}</strong> (${profile.email}) can now sign in to Kittehs FTW.</p>`,
  )
})

function html(title: string, body: string): Response {
  return new Response(
    `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>${title} — Kittehs FTW</title>
  <style>
    body { font-family: sans-serif; max-width: 480px; margin: 80px auto; padding: 0 16px; color: #333; }
    h2 { color: #F88379; }
  </style>
</head>
<body>
  <h2>🐱 ${title}</h2>
  ${body}
</body>
</html>`,
    { headers: { 'Content-Type': 'text/html' }, status: 200 },
  )
}
