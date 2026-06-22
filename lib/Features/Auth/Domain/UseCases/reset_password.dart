import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Features/Auth/Domain/Repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ResetPassword {
  final AuthRepository authRepository;
  ResetPassword(this.authRepository);

  Future<Either<Failure, void>> call({required String newPassword}) =>
      authRepository.updatePassword(newPassword: newPassword);
}
