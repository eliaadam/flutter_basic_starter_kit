import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_basic_starter_kit/application/services/user_service_api.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserServiceAPI userService;

  AuthBloc(this.userService) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await userService.login(event.email, event.password);

      final success = result['success'] == true;
      final message = result['message'] ?? 'Unknown login error';

      if (success) {
        emit(Authenticated(message: message));
      } else {
        emit(AuthError(message));
      }
    } on DioException catch (e) {
      emit(AuthError(_handleDioError(e)));
    } catch (e) {
      emit(AuthError("Unexpected error."));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await userService.register(
        event.name,
        event.email,
        event.password,
      );

      final success = result['success'] == true;
      final message = result['message'] ?? 'Unknown registration error';

      if (success) {
        emit(Authenticated(message: message));
      } else {
        emit(AuthError(message));
      }
    } on DioException catch (e) {
      emit(AuthError(_handleDioError(e)));
    } catch (e) {
      emit(AuthError("Unexpected error."));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await userService.logout();
      emit(Unauthenticated(message: result['message']));
    } on DioException catch (e) {
      emit(AuthError(_handleDioError(e)));
    } catch (e) {
      emit(AuthError("Unexpected error."));
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? "Server error occurred";
    }
    return "Network request failed: ${e.message}";
  }
}
