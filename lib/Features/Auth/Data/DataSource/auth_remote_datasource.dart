import 'package:blog_app/Core/Errors/exceptions.dart';
import 'package:blog_app/Core/Secrets/app_secrets.dart';
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

  AuthRemoteDataSourceImpl(this.supabaseClient);

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
      final approvalToken = const Uuid().v4();

      final AuthResponse res = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'approval_token': approvalToken,
          'bio': bio.trim().isEmpty ? null : bio.trim(),
        },
      );

      if (res.user == null) throw ServerException('User is null!');

      // Notify admin before signing out (session required for invoke)
      await supabaseClient.functions.invoke(
        'notify-admin',
        body: {
          'userName': name,
          'userEmail': email,
          'userBio': bio.trim(),
          'userId': res.user!.id,
          'approvalToken': approvalToken,
        },
      ).catchError((_) => FunctionResponse(data: null, status: 0));

      // Sign out immediately — user must wait for admin approval
      await supabaseClient.auth.signOut();

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
