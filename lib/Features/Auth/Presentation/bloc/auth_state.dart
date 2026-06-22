part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final UserEnteties user;
  const AuthSuccess(this.user);
}

final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}

final class AuthPasswordResetEmailSent extends AuthState {}

final class AuthPasswordResetSuccess extends AuthState {}

final class AuthEmailVerificationPending extends AuthState {}

final class AuthPhoneOtpSent extends AuthState {
  final String phone;
  const AuthPhoneOtpSent(this.phone);
}

