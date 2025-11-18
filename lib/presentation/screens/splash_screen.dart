import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_basic_starter_kit/presentation/blocs/auth_bloc.dart';
import 'package:flutter_basic_starter_kit/presentation/blocs/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Optionally, you could check token here and emit events if needed
    // For example, if you implement an AppStarted event
    // context.read<AuthBloc>().add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is Unauthenticated || state is AuthError) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
