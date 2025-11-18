import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_basic_starter_kit/presentation/blocs/auth_bloc.dart';
import 'package:flutter_basic_starter_kit/presentation/blocs/auth_event.dart';
import 'package:flutter_basic_starter_kit/presentation/blocs/auth_state.dart';

void logout(BuildContext context) {
  final authBloc = context.read<AuthBloc>();

  // Trigger logout first
  authBloc.add(LogoutEvent());
  // Wait for the next frame to ensure the context is still valid
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Declare subscription first so it can be referenced inside the callback
    late StreamSubscription<AuthState> subscription;
    // Listen temporarily to the state
    subscription = authBloc.stream.listen((state) {
      if (state is Unauthenticated) {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (Route<dynamic> route) => false,
          );
        }
        subscription.cancel(); // stop listening after navigation
      }
    });
  });
}
