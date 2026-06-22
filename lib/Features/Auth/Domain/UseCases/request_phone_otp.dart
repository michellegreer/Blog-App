import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Features/Auth/Domain/Repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class RequestPhoneOtp {
  final AuthRepository authRepository;
  RequestPhoneOtp(this.authRepository);

  Future<Either<Failure, void>> call({required String phone}) =>
      authRepository.sendPhoneOtp(phone: phone);
}
