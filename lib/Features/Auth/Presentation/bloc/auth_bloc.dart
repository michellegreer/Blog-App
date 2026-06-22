import 'package:blog_app/Core/Common/Cubits/AppUser/app_user_cubit.dart';
import 'package:blog_app/Core/UseCAses/usecase.dart';
import 'package:blog_app/Core/Common/Enteties/user_enteties.dart';
import 'package:blog_app/Features/Auth/Domain/UseCases/current_user.dart';
import 'package:blog_app/Features/Auth/Domain/UseCases/forgot_password.dart';
import 'package:blog_app/Features/Auth/Domain/UseCases/request_phone_otp.dart';
import 'package:blog_app/Features/Auth/Domain/UseCases/reset_password.dart';
import 'package:blog_app/Features/Auth/Domain/UseCases/user_login.dart';
import 'package:blog_app/Features/Auth/Domain/UseCases/user_signup.dart';
import 'package:blog_app/Features/Auth/Domain/UseCases/verify_phone_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignup _userSignup;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  final ForgotPassword _forgotPassword;
  final ResetPassword _resetPassword;
  final RequestPhoneOtp _requestPhoneOtp;
  final VerifyPhoneOtp _verifyPhoneOtp;

  AuthBloc({
    required UserSignup userSignup,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required ForgotPassword forgotPassword,
    required ResetPassword resetPassword,
    required RequestPhoneOtp requestPhoneOtp,
    required VerifyPhoneOtp verifyPhoneOtp,
  }) : _userSignup = userSignup,
       _userLogin = userLogin,
       _currentUser = currentUser,
       _appUserCubit = appUserCubit,
       _forgotPassword = forgotPassword,
       _resetPassword = resetPassword,
       _requestPhoneOtp = requestPhoneOtp,
       _verifyPhoneOtp = verifyPhoneOtp,
       super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<SignedUpButonPressed>(_onAuthSignUp);
    on<LogedInButonPressed>(_onAuthLogIn);
    on<AuthIsUserLoggedIn>(_onIsLoggedIn);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<ResetPasswordRequested>(_onResetPassword);
    on<PhoneOtpRequested>(_onPhoneOtpRequested);
    on<PhoneOtpVerified>(_onPhoneOtpVerified);
  }

  void _onAuthSignUp(
    SignedUpButonPressed event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userSignup(
      UserSignUpParams(event.email, event.name, event.password, event.bio),
    );
    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (user) {
        if (user == null) {
          emit(AuthEmailVerificationPending());
        } else {
          _emitAuthSucces(user, emit);
        }
      },
    );
  }

  void _onAuthLogIn(LogedInButonPressed event, Emitter<AuthState> emit) async {
    // print('auth block is called');
    // print('📧 Email: ${event.email}');
    // print('🔑 Password: ${event.password}');
    final res = await _userLogin(UserLoginParams(event.email, event.password));

    res.fold((l) {
      // print("🚨 Signup Failed: ${l.message}");
      emit(AuthFailure(l.message));
    }, (user) => _emitAuthSucces(user, emit));
  }

  void _onIsLoggedIn(AuthIsUserLoggedIn event, Emitter<AuthState> emit) async {
    final res = await _currentUser(NoParams());
    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) =>
      //so there is how we get the user id ,emial,and name from the supabase
      //database.the email is not in the profiles database but in the auth
      // database so we can get it from the auth database throug the copyWith
      //method in user model.
      // print('This is the current user id ${r.id}');
      // print('This is the current user name ${r.name}');
      // print('This is the current user email ${r.email}');
      _emitAuthSucces(r, emit),
    );
  }

  void _emitAuthSucces(UserEnteties user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }

  void _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _forgotPassword(
      email: event.email,
      redirectTo: event.redirectTo,
    );
    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (_) => emit(AuthPasswordResetEmailSent()),
    );
  }

  void _onResetPassword(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _resetPassword(newPassword: event.newPassword);
    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (_) => emit(AuthPasswordResetSuccess()),
    );
  }

  void _onPhoneOtpRequested(
    PhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _requestPhoneOtp(phone: event.phone);
    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (_) => emit(AuthPhoneOtpSent(event.phone)),
    );
  }

  void _onPhoneOtpVerified(
    PhoneOtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _verifyPhoneOtp(phone: event.phone, token: event.token);
    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (user) => _emitAuthSucces(user, emit),
    );
  }
}
