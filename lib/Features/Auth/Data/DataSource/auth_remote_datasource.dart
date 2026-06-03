import 'package:blog_app/Core/Errors/exceptions.dart';
import 'package:blog_app/Core/Secrets/app_secrets.dart';
import 'package:blog_app/Core/Services/resend_service.dart';
import 'package:blog_app/Features/Auth/Data/Modals/user_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract interface class AuthRemoteDatasource {
  Session? get currentUserSession;
  Future<UserModel?> getCurrentUserData();
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String bio,
  });
  Future<UserModel> logInWithEmailAndPassword({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDatasource {
  final SupabaseClient supabaseClient;
  final ResendService resendService;

  AuthRemoteDataSourceImpl(this.supabaseClient, this.resendService);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', currentUserSession!.user.id)
            .single();
        return UserModel.fromJson(userData)
            .copyWith(email: currentUserSession!.user.email);
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String bio,
  }) async {
    try {
      final AuthResponse res = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (res.user == null) throw ServerException('User is null!');

      final approvalToken = const Uuid().v4();

      // Give the trigger a moment to create the profile row, then update it
      await Future.delayed(const Duration(milliseconds: 500));
      await supabaseClient.from('profiles').update({
        'is_approved': false,
        'role': 'user',
        'approval_token': approvalToken,
        'bio': bio.trim().isEmpty ? null : bio.trim(),
      }).eq('id', res.user!.id);

      // Sign out immediately — user must wait for admin approval
      await supabaseClient.auth.signOut();

      final approvalLink =
          '${AppSecrets.supaBaseUrl}/functions/v1/approve-user'
          '?user_id=${res.user!.id}&token=$approvalToken';

      // Send approval email to admin (fire and forget — don't fail signup if email errors)
      resendService
          .sendAdminApprovalEmail(
            toEmail: AppSecrets.adminEmail,
            newUserName: name,
            newUserEmail: email,
            newUserBio: bio.trim(),
            approvalLink: approvalLink,
          )
          .catchError((_) {});

      return UserModel.fromJson(res.user!.toJson()).copyWith(
        name: name,
        isApproved: false,
        role: 'user',
      );
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse res = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) throw ServerException('User is null!');

      // Fetch profile to check approval status
      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', res.user!.id)
          .single();

      final isApproved = profileData['is_approved'] as bool? ?? false;
      final role = profileData['role'] as String? ?? 'user';

      if (!isApproved && role != 'admin' && email != AppSecrets.adminEmail) {
        await supabaseClient.auth.signOut();
        throw MyAuthException(
          'Your account is pending administrator approval. '
          'You will receive an email when your account is ready.',
        );
      }

      return UserModel.fromJson(profileData)
          .copyWith(email: res.user!.email ?? email);
    } on MyAuthException {
      rethrow;
    } on AuthException catch (e) {
      throw MyAuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
