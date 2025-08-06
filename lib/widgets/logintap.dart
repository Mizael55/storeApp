import 'package:flutter/material.dart';
import 'package:store_app/theme/app_colors.dart';
import '../utils/utils.dart';


class LoginTab extends StatefulWidget {
  const LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CustomTextInput(
              label: 'Correo Electrónico',
              prefixIcon: Icons.email,
              inputType: CustomInputType.email,
            ),
            const SizedBox(height: 15),
            const CustomTextInput(
              label: 'Contraseña',
              prefixIcon: Icons.lock,
              inputType: CustomInputType.password,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                    // Procesar registro
                  }
                },
                child: const Text(
                  'INICIAR SESIÓN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'O inicia sesión con',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 15),
            // Botón de Google
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
                      'Continuar con Google',
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
  }
}
