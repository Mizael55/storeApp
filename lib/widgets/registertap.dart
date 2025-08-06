import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:store_app/theme/app_colors.dart';
import '../utils/utils.dart';

class SignupTab extends StatefulWidget {
  const SignupTab({super.key});

  @override
  State<SignupTab> createState() => _SignupTabState();
}

class _SignupTabState extends State<SignupTab> {
  String? userType; // 'user' o 'seller'
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  @override
  void dispose() {
    // No olvides limpiar los controladores cuando el widget se destruya
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSignUpSuccess) {
          showDialog(
            context: context,
            builder:
                (context) => CustomAlert(
                  title: 'Registro exitoso',
                  message: 'Bienvenido/a ${state.user.fullName}',
                  type: AlertType.success,
                  onClose: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(
                      context,
                      state.user.userType == 'seller'
                          ? '/seller-home'
                          : '/user-home',
                    );
                  },
                ),
          );
        } else if (state is AuthFailure) {
          showDialog(
            context: context,
            builder:
                (context) => CustomAlert(
                  title: 'Error',
                  message: state.error,
                  type: AlertType.error,
                ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                CustomTextInput(
                  label: 'Nombre Completo',
                  prefixIcon: Icons.person,
                  controller: _fullNameController, // Añade esto
                ),
                const SizedBox(height: 15),
                CustomTextInput(
                  label: 'Correo Electrónico',
                  prefixIcon: Icons.email,
                  inputType: CustomInputType.email,
                  controller: _emailController, // Añade esto
                ),
                const SizedBox(height: 15),
                CustomTextInput(
                  label: 'Contraseña',
                  prefixIcon: Icons.lock,
                  inputType: CustomInputType.password,
                  controller: _passwordController, // Añade esto
                ),
                const SizedBox(height: 15),

                // Selector de tipo de usuario
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo de cuenta',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'Usuario',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              value: 'user',
                              groupValue: userType,
                              onChanged: (value) {
                                setState(() {
                                  userType = value;
                                });
                              },
                              activeColor: AppColors.secondary,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'Venta',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              value: 'seller',
                              groupValue: userType,
                              onChanged: (value) {
                                setState(() {
                                  userType = value;
                                });
                              },
                              activeColor: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.buttonText,
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (userType != null) {
                          context.read<AuthBloc>().add(
                            SignUpWithEmailAndPasswordRequested(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              fullName: _fullNameController.text.trim(),
                              userType: userType!,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecciona un tipo de usuario'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'REGISTRARSE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // Botón de Google en registro también
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.cardBackground,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                    ),
                    onPressed: () {
                      // Lógica para inicio con Google
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/google.png', width: 24, height: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Registrate con Google',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
