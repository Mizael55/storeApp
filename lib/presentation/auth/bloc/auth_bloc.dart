import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:store_app/models/user.dart';
import 'package:store_app/presentation/auth/bloc/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignUpWithEmailAndPasswordRequested>(
      _onSignUpWithEmailAndPasswordRequested,
    );
    on<SignUpWithGoogleRequested>(_onSignUpWithGoogleRequested);
    on<LoginWithEmailAndPasswordRequested>(
      _onLoginWithEmailAndPasswordRequested,
    );
    on<LoginWithGoogleRequested>(_onLoginWithGoogleRequested);
  }

  Future<void> _onSignUpWithEmailAndPasswordRequested(
    SignUpWithEmailAndPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        userType: event.userType,
      );

      emit(AuthSignUpSuccess(user));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'El correo ya está registrado. ¿Quieres iniciar sesión?';
          break;
        case 'invalid-email':
          errorMessage = 'El formato del correo es inválido';
          break;
        case 'weak-password':
          errorMessage = 'La contraseña debe tener al menos 6 caracteres';
          break;
        default:
          errorMessage = 'Error desconocido: ${e.message}';
      }
      emit(AuthFailure(errorMessage));
    } catch (e) {
      emit(AuthFailure('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onSignUpWithGoogleRequested(
    SignUpWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUpWithGoogle(
        userType: event.userType,
      );
      emit(AuthSignUpSuccess(user));
    } catch (e) {
      emit(AuthFailure('Error al registrar con Google: ${e.toString()}'));
    }
  }

  Future<void> _onLoginWithEmailAndPasswordRequested(
    LoginWithEmailAndPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.loginWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthLoginSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthFailure('Error al iniciar sesión: ${e.toString()}'));
    }
  }

  Future<void> _onLoginWithGoogleRequested(
    LoginWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.loginWithGoogle();
      emit(AuthLoginSuccess(user));
    } catch (e) {
      emit(AuthFailure('Error al iniciar con Google: ${e.toString()}'));
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'El correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'Contraseña demasiado débil';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
