import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Core/Common/Enteties/user_enteties.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEnteties>> signUpWithEmailAndPasssword({
    required String name,
    required String email,
    required String password,
    required String bio,
  });
  Future<Either<Failure, UserEnteties>> logInWithEmailAndPasssword({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEnteties>> currentUser();
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email, required String redirectTo});
  Future<Either<Failure, void>> updatePassword({required String newPassword});
  Future<Either<Failure, void>> sendPhoneOtp({required String phone});
  Future<Either<Failure, UserEnteties>> verifyPhoneOtp({required String phone, required String token});
}
