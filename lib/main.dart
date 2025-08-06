import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store_app/firebase_options.dart';
import 'package:store_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:store_app/presentation/auth/bloc/repositories/auth_repository.dart';
import 'presentation/screen/screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create:
            (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            ),

        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'APP Tiendas',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
