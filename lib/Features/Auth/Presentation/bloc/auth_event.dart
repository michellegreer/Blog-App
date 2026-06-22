part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class SignedUpButonPressed extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String bio;
  SignedUpButonPressed({
    required this.name,
    required this.email,
    required this.password,
    required this.bio,
  });
}

final class LogedInButonPressed extends AuthEvent {
  final String email;
  final String password;
  LogedInButonPressed({required this.email, required this.password});
}

final class AuthIsUserLoggedIn extends AuthEvent {}

final class ForgotPasswordRequested extends AuthEvent {
  final String email;
  final String redirectTo;
  ForgotPasswordRequested({required this.email, required this.redirectTo});
}

final class ResetPasswordRequested extends AuthEvent {
  final String newPassword;
  ResetPasswordRequested({required this.newPassword});
}

final class PhoneOtpRequested extends AuthEvent {
  final String phone;
  PhoneOtpRequested({required this.phone});
}

final class PhoneOtpVerified extends AuthEvent {
  final String phone;
  final String token;
  PhoneOtpVerified({required this.phone, required this.token});
}
