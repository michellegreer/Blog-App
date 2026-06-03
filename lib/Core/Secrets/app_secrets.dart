class AppSecrets {
  static const supaBaseUrl =
      String.fromEnvironment('SUPABASE_URL');

  static const supaBaseAnon =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const resendAPIKey =
      String.fromEnvironment('RESEND_API_KEY');

  static const adminEmail =
      String.fromEnvironment('ADMIN_EMAIL');
}
