import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    const url = new URL(req.url)
    const userId = url.searchParams.get('user_id')
    const token = url.searchParams.get('token')

    if (!userId || !token) {
      return new Response('Missing user_id or token', { status: 400 })
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const resendKey = Deno.env.get('RESEND_API_KEY')!

    const supabase = createClient(supabaseUrl, serviceRoleKey)

    const { data: profile, error: fetchError } = await supabase
      .from('profiles')
      .select('approval_token, is_approved, name')
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

    // Get the user's email from auth
    const { data: userData } = await supabase.auth.admin.getUserById(userId)
    const userEmail = userData?.user?.email

    // Send approval email to the user
    if (userEmail) {
      await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${resendKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: 'Kitties FTW <noreply@admin.kittiesftw.com>',
          to: [userEmail],
          subject: 'Your Kitties FTW account is approved!',
          html: `
            <div style="font-family:sans-serif;max-width:480px;margin:0 auto;">
              <h2>You're in! 🐱</h2>
              <p>Hi ${profile.name},</p>
              <p>Your Kitties FTW account has been approved. You can now sign in and start posting.</p>
              <br/>
              <a href="https://kittiesftw.com"
                 style="background:#F88379;color:white;padding:12px 24px;
                        border-radius:6px;text-decoration:none;font-weight:bold;">
                Go to Kitties FTW
              </a>
            </div>
          `,
        }),
      })
    }

    return html(
      'Account approved!',
      `<p><strong>${profile.name}</strong> can now sign in to Kitties FTW.</p>`,
    )
  } catch (e) {
    return new Response(`Error: ${String(e)}`, { status: 500 })
  }
})

function html(title: string, body: string): Response {
  return new Response(
    `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>${title} — Kitties FTW</title>
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
