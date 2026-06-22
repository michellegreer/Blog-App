class AppSecrets {
  // ── Local dev → Supabase dev branch ───────────────────────────────────────
  // Replace these with your dev branch credentials from:
  // Supabase dashboard → production project → Branches → dev → API settings
  //
  // ── Production → Vercel env vars (never edit here) ────────────────────────
  // SUPABASE_URL and SUPABASE_ANON_KEY are set in Vercel dashboard.
  // The defaultValues below are ONLY used for local flutter run.

  static const supaBaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ldurlirpcnssqhlzvqau.supabase.co',
  );

  static const supaBaseAnon = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxkdXJsaXJwY25zc3FobHp2cWF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxNTMwOTcsImV4cCI6MjA5NzcyOTA5N30.Jp0A4NEzlJ-8sIZdCS6i8Hv2zE-xhpDXeSAWjXZeyl8',
  );

  static const resendAPIKey = String.fromEnvironment(
    'RESEND_API_KEY',
    defaultValue: 're_WqAGt7SR_CbkBNztTiePTGL5g3ti1tRe9',
  );

  static const adminEmail = String.fromEnvironment(
    'ADMIN_EMAIL',
    defaultValue: 'michelle@michellegreer.com',
  );
}
