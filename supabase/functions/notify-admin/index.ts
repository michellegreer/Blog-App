const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('notify-admin: received request')

    const body = await req.json()
    console.log('notify-admin: body parsed', JSON.stringify(body))

    const { userName, userEmail, userBio, userId, approvalToken } = body

    if (!userId || !approvalToken) {
      console.log('notify-admin: missing fields')
      return new Response(JSON.stringify({ error: 'Missing required fields' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const resendKey = Deno.env.get('RESEND_API_KEY')
    const adminEmail = Deno.env.get('ADMIN_EMAIL')

    console.log('notify-admin: supabaseUrl set?', !!supabaseUrl)
    console.log('notify-admin: resendKey set?', !!resendKey)
    console.log('notify-admin: adminEmail set?', !!adminEmail)

    const approvalLink = `${supabaseUrl}/functions/v1/approve-user?user_id=${userId}&token=${approvalToken}`

    console.log('notify-admin: calling Resend')

    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Kitties FTW <noreply@admin.kittiesftw.com>',
        to: [adminEmail],
        subject: `New account request from ${userName}`,
        html: `
          <div style="font-family:sans-serif;max-width:480px;margin:0 auto;">
            <h2>New Account Request</h2>
            <p>Someone wants to post on Kitties FTW!</p>
            <p><strong>Name:</strong> ${userName}</p>
            <p><strong>Email:</strong> ${userEmail}</p>
            <p><strong>Bio:</strong> ${userBio || '(none provided)'}</p>
            <br/>
            <a href="${approvalLink}"
               style="background:#F88379;color:white;padding:12px 24px;
                      border-radius:6px;text-decoration:none;font-weight:bold;">
              Approve Account
            </a>
            <br/><br/>
            <p style="color:#999;font-size:12px;">
              If you did not expect this, ignore this email.
            </p>
          </div>
        `,
      }),
    })

    const resendBody = await response.text()
    console.log('notify-admin: Resend status', response.status, resendBody)

    if (!response.ok) {
      return new Response(JSON.stringify({ error: resendBody }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (e) {
    console.log('notify-admin: caught error', String(e))
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
