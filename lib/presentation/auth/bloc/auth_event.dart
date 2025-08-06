part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignUpWithEmailAndPasswordRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String userType;

  const SignUpWithEmailAndPasswordRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.userType,
  });

  @override
  List<Object> get props => [email, password, fullName, userType];
}

class SignUpWithGoogleRequested extends AuthEvent {
  final String userType; // 'user' o 'seller'

  const SignUpWithGoogleRequested({required this.userType});

  @override
  List<Object> get props => [userType];
}