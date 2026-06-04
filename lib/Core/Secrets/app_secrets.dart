class AppSecrets {
  static const supaBaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://irroysbfmvchllwgvnrn.supabase.co',
  );

  static const supaBaseAnon = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlycm95c2JmbXZjaGxsd2d2bnJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA0MTE0MjQsImV4cCI6MjA5NTk4NzQyNH0.xKjYGJAZAiNdA9eRA4-RPFQS3e2rWZQT6BfIuppioRY',
  );

  static const resendAPIKey = String.fromEnvironment(
    'RESEND_API_KEY',
    defaultValue: 're_WqAGt7SR_CbkBNztTiePTGL5g3ti1tRe9',
  );

  static const adminEmail = String.fromEnvironment(
    'ADMIN_EMAIL',
    defaultValue: 'michelle@michellesblog.net',
  );
}
