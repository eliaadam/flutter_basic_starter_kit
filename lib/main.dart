import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

// Local data sources + services
import 'package:flutter_basic_starter_kit/infrastructure/data_sources/local/sqldb/user_crud.dart';
import 'package:flutter_basic_starter_kit/infrastructure/data_sources/local/sqldb/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Screens
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/splash_screen.dart';

// Services
import 'infrastructure/services/token_storage_service.dart';
import 'application/services/auth_service.dart';
import 'application/services/user_service_api.dart';

// BLoCs
import 'presentation/blocs/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- SQLite FFI for Windows/Linux/Mac ---
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Ensure DB is ready
  await DatabaseHelper().database;

  // Initialize app services
  final tokenStorage = TokenStorageService();
  final authService = AuthService(tokenStorage);
  final userService = UserServiceAPI(authService);

  // Desktop window setup
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      const initialSize = Size(1000, 700);
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = "Basic Starter";
      appWindow.show();
    });
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TokenStorageService>.value(value: tokenStorage),
        RepositoryProvider<UserServiceAPI>.value(value: userService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => AuthBloc(userService)),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

/// ===================================================
/// MyApp (with theming, routing, and desktop chrome)
/// ===================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ThemeData appTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  );

  static final Map<String, WidgetBuilder> appRoutes = {
    '/home': (_) => const HomeScreen(),
    '/login': (_) => const LoginScreen(),
    '/register': (_) => const RegisterScreen(),
    '/splash': (_) => const SplashScreen(),
  };

  Future<int?> _getLoggedInUserId() async {
    return await DatabaseHelper().getLoggedInUserId();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _getLoggedInUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final apiId = snapshot.data;

        final coreApp = MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Basic Starter",
          theme: appTheme,
          home: apiId != null ? const HomeScreen() : const LoginScreen(),
          routes: appRoutes,
        );

        // Wrap with custom window chrome on desktop
        if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
          return coreApp; // mobile/web
        }

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: WindowTitleBarBox(
                  child: MoveWindow(
                    child: Row(
                      children: [
                        SizedBox(width: 16),
                        Text(
                          "Start Kit",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        Expanded(child: SizedBox()),
                        const WindowButtons(),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(child: coreApp),
            ],
          ),
        );
      },
    );
  }
}

/// ===================================================
/// Custom Window Buttons (desktop only)
/// ===================================================
class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttonColors = WindowButtonColors(
      iconNormal: theme.primaryColor,
      mouseOver: theme.colorScheme.secondary.withValues(alpha: 0.3),
      mouseDown: theme.primaryColor.withValues(alpha: 0.7),
      iconMouseOver: theme.primaryColor,
      iconMouseDown: theme.colorScheme.surface,
    );

    final closeColors = WindowButtonColors(
      mouseOver: theme.colorScheme.error,
      mouseDown: theme.colorScheme.onErrorContainer,
      iconNormal: theme.primaryColor,
      iconMouseOver: theme.colorScheme.surface,
    );

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeColors),
      ],
    );
  }
}
