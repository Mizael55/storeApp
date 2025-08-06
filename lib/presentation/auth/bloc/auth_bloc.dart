import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:store_app/models/user.dart';
import 'package:store_app/presentation/auth/bloc/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository
  authRepository; // Repositorio para operaciones de autenticación

  // Constructor que inicializa el BLoC con el repositorio y define los manejadores de eventos
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Registra los manejadores para cada tipo de evento
    on<SignUpWithEmailAndPasswordRequested>(
      _onSignUpWithEmailAndPasswordRequested,
    );
    on<SignUpWithGoogleRequested>(_onSignUpWithGoogleRequested);
    on<LoginWithEmailAndPasswordRequested>(
      _onLoginWithEmailAndPasswordRequested,
    );
    on<LoginWithGoogleRequested>(_onLoginWithGoogleRequested);
  }

  // Manejador para registro con email y contraseña
  Future<void> _onSignUpWithEmailAndPasswordRequested(
    SignUpWithEmailAndPasswordRequested event, // Evento recibido
    Emitter<AuthState> emit, // Función para emitir nuevos estados
  ) async {
    emit(AuthLoading()); // Indica que la operación está en progreso
    try {
      // Intenta registrar al usuario a través del repositorio
      final user = await authRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        userType: event.userType,
      );

      emit(
        AuthSignUpSuccess(user),
      ); // Éxito: emite estado con datos del usuario
    } on FirebaseAuthException catch (e) {
      // Maneja errores específicos de Firebase Auth
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
      emit(AuthFailure(errorMessage)); // Emite estado de fallo con mensaje
    } catch (e) {
      // Maneja cualquier otro tipo de error
      emit(AuthFailure('Error inesperado: ${e.toString()}'));
    }
  }

  // Manejador para registro con Google
  Future<void> _onSignUpWithGoogleRequested(
    SignUpWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // Indica carga
    try {
      // Intenta registro con Google
      final user = await authRepository.signUpWithGoogle(
        userType: event.userType,
      );
      emit(AuthSignUpSuccess(user)); // Éxito
    } catch (e) {
      // Error en registro con Google
      emit(AuthFailure('Error al registrar con Google: ${e.toString()}'));
    }
  }

  // Manejador para inicio de sesión con email/contraseña
  Future<void> _onLoginWithEmailAndPasswordRequested(
    LoginWithEmailAndPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // Indica carga
    try {
      // Intenta autenticación
      final user = await authRepository.loginWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthLoginSuccess(user)); // Éxito
    } on FirebaseAuthException catch (e) {
      // Maneja errores de Firebase
      emit(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      // Maneja otros errores
      emit(AuthFailure('Error al iniciar sesión: ${e.toString()}'));
    }
  }

  // Manejador para inicio de sesión con Google
  Future<void> _onLoginWithGoogleRequested(
    LoginWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // Indica carga
    try {
      // Intenta autenticación con Google
      final user = await authRepository.loginWithGoogle();
      emit(AuthLoginSuccess(user)); // Éxito
    } catch (e) {
      // Error en autenticación con Google
      emit(AuthFailure('Error al iniciar con Google: ${e.toString()}'));
    }
  }

  // Método auxiliar para traducir códigos de error de Firebase
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
