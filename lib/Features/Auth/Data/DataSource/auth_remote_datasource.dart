import 'package:blog_app/Core/Errors/exceptions.dart';
import 'package:blog_app/Features/Auth/Data/Modals/user_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  Future<void> sendPasswordResetEmail({required String email, required String redirectTo});
  Future<void> updatePassword({required String newPassword});
  Future<void> sendPhoneOtp({required String phone});
  Future<UserModel> verifyPhoneOtp({required String phone, required String token});
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
      final AuthResponse res = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'bio': bio.trim().isEmpty ? null : bio.trim(),
        },
      );

      if (res.user == null) throw ServerException('User is null!');

      await supabaseClient.from('profiles').upsert({
        'id': res.user!.id,
        'name': name,
        'bio': bio.trim().isEmpty ? null : bio.trim(),
      });

      return UserModel(
        id: res.user!.id,
        email: email,
        name: name,
        bio: bio.trim().isEmpty ? null : bio.trim(),
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

      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', res.user!.id)
          .single();

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

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    required String redirectTo,
  }) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendPhoneOtp({required String phone}) async {
    try {
      await supabaseClient.auth.signInWithOtp(phone: phone);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final res = await supabaseClient.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );

      if (res.session == null || res.user == null) {
        throw ServerException('Verification failed');
      }

      try {
        final profileData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', res.user!.id)
            .single();
        return UserModel.fromJson(profileData)
            .copyWith(email: res.user!.email);
      } catch (_) {
        // Profile doesn't exist yet (new user via invite phone flow)
        return UserModel(
          id: res.user!.id,
          email: res.user!.email ?? '',
          name: phone,
          phone: phone,
        );
      }
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
