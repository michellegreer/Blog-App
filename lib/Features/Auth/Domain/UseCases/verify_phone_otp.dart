import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Core/Common/Enteties/user_enteties.dart';
import 'package:blog_app/Features/Auth/Domain/Repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class VerifyPhoneOtp {
  final AuthRepository authRepository;
  VerifyPhoneOtp(this.authRepository);

  Future<Either<Failure, UserEnteties>> call({
    required String phone,
    required String token,
  }) =>
      authRepository.verifyPhoneOtp(phone: phone, token: token);
}
