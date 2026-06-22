import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Features/Auth/Domain/Repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ForgotPassword {
  final AuthRepository authRepository;
  ForgotPassword(this.authRepository);

  Future<Either<Failure, void>> call({
    required String email,
    required String redirectTo,
  }) =>
      authRepository.sendPasswordResetEmail(
        email: email,
        redirectTo: redirectTo,
      );
}
