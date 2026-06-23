import 'package:supabase_flutter/supabase_flutter.dart';

class InviteRemoteDataSource {
  final SupabaseClient _supabase;
  InviteRemoteDataSource(this._supabase);

  Future<void> sendInvite({
    required String email,
    String? name,
    String? circleId,
  }) async {
    // Uri.base.origin gives the running app's origin (localhost in dev,
    // the Vercel URL in preview, kittiesftw.com in production) so the
    // invite link always lands back on the right environment.
    final appOrigin = Uri.base.origin;
    final response = await _supabase.functions.invoke(
      'send-invite',
      body: {
        'email': email,
        'redirectTo': '$appOrigin/complete-profile',
        if (name != null && name.isNotEmpty) 'name': name,
        if (circleId != null) 'circleId': circleId,
      },
    );
    if (response.status != 200) {
      final error = (response.data as Map?)?['error'] as String?
          ?? 'Failed to send invite';
      throw Exception(error);
    }
  }
}
