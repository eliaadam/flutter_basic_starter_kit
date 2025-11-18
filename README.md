# **Credits**

This architecture pattern and documentation are crafted and refined by **MaishaSoft**.
Visit **[maishasoft.com](https://maishasoft.com)** for more software insights, engineering patterns, and professional solutions.


# **Flutter Application Architecture — PIDCA**

This document describes the clean, layered architecture used in this Flutter application.
The pattern is designed for clarity, scalability, and maintainability, especially for enterprise-grade apps.
It separates concerns into five major layers:

* **presentation**
* **application**
* **domain**
* **infrastructure**
* **core**

Every feature flows through these layers in a predictable and testable way.

---

## **1. Directory Structure Overview**

```
main.dart
application/
  commands/
    change_theme_command.dart
  services/
    auth_service.dart
  usecases/
    fetch_user_profile.dart
    update_settings.dart

core/
  constants/
    app_constants.dart
  error/
    exceptions.dart
    failure.dart
  extensions/
    string_extensions.dart
  logging/
    logger.dart
  utils/
    date_utils.dart

domain/
  entities/
    user.dart
  repositories/
    user_repository.dart
  services/
    user_domain_service.dart
  value_objects/
    email_address.dart

infrastructure/
  data_sources/
    local/
      user_local_storage.dart
    remote/
      user_api.dart
  repositories/
    user_repository_impl.dart
  services/
    api_client.dart
    token_storage_service.dart

presentation/
  blocs/
    auth_bloc.dart
    auth_event.dart
    auth_state.dart
  components/
  screens/
    auth/
      login_screen.dart
      register_screen.dart
    home/
      home_screen.dart
  themes/
    app_theme.dart
  viewmodels/
    home_viewmodel.dart
    settings_viewmodel.dart
  widgets/
```

Each folder has a precise responsibility, and no layer is allowed to skip over another.
This encourages readable code, strong separation of concerns, and easy testing.

---

# **2. Layer-by-Layer Explanation**

## **Presentation Layer**

The outermost layer.
It contains:

* Flutter widgets
* Screens
* Blocs / ViewModels
* Themes
* Stateless UI components

It never touches business rules or infrastructure directly.
Its job is to react to user input and display state.

---

## **Application Layer**

The orchestrator.

This layer contains:

* **Use cases** — the app’s actions expressed as verbs (“FetchProfile”, “UpdateSettings”)
* **Commands** — UI-triggered operations
* **Application services** — thin coordination logic

Use cases call domain repositories.
They do not know how data is stored or retrieved.

---

## **Domain Layer**

The heart of the system.

It defines:

* **Entities** (User, Order, Project…)
* **Value objects** (EmailAddress, PhoneNumber…)
* **Domain services**
* **Repository interfaces**

This layer contains pure business rules with no dependency on Flutter, JSON, or APIs.

---

## **Infrastructure Layer**

The machinery.

Contains:

* API clients
* Local storage (SQLite, Hive, SharedPreferences)
* Remote data sources
* Repository implementations
* DTOs and mapping logic

This is the only layer allowed to touch the outside world.
It fulfills the contracts defined in the domain layer.

---

## **Core Layer**

Shared utilities and abstractions:

* Logging utilities
* Global constants
* Error and failure systems
* General extensions
* Helper utilities

This layer is intentionally framework-agnostic and safe to use everywhere.

---

# **3. Example: Feature Flow Through All Layers**

### **Feature: Fetch User Profile**

A simple action—loading the current user’s profile—illustrates how data travels through the system.

---

## **Step 1 — Presentation Layer**

User taps “Load Profile”.
The UI dispatches an event:

```dart
context.read<AuthBloc>().add(FetchUserProfileEvent());
```

`AuthBloc` responds:

```dart
on<FetchUserProfileEvent>((event, emit) async {
  emit(ProfileLoadingState());

  final result = await fetchUserProfileUseCase();

  result.fold(
    (failure) => emit(ProfileErrorState(failure.message)),
    (user)     => emit(ProfileLoadedState(user)),
  );
});
```

The Bloc performs zero business logic.
It simply delegates to the **use case**.

---

## **Step 2 — Application Layer**

Use case coordinates the operation:

```dart
class FetchUserProfile {
  final UserRepository repository;

  FetchUserProfile(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.fetchUser();
  }
}
```

It speaks only to the domain contract.
Not JSON, not HTTP, not SQLite—just the repository interface.

---

## **Step 3 — Domain Layer**

The domain declares what “fetching a user” means:

```dart
abstract class UserRepository {
  Future<User> fetchUser();
}
```

And defines the **User** entity itself:

```dart
class User {
  final String id;
  final EmailAddress email;
  final String name;

  User({required this.id, required this.email, required this.name});
}
```

Pure, framework-independent business rules.

---

## **Step 4 — Infrastructure Layer**

The repository implementation performs the real work:

```dart
class UserRepositoryImpl implements UserRepository {
  final UserApi api;
  final UserLocalStorage local;

  UserRepositoryImpl({required this.api, required this.local});

  @override
  Future<User> fetchUser() async {
    final dto = await api.getProfile();
    final user = UserMapper.fromDto(dto);

    await local.saveUser(user);

    return user;
  }
}
```

Remote data source:

```dart
class UserApi {
  final ApiClient client;

  Future<UserDto> getProfile() async {
    final response = await client.get('/user/profile');
    return UserDto.fromJson(response.data);
  }
}
```

Local data source:

```dart
class UserLocalStorage {
  final SharedPreferences prefs;

  Future<void> saveUser(User user) async {
    await prefs.setString('user', jsonEncode(user.toJson()));
  }
}
```

---

## **Step 5 — Back to Presentation**

The user entity flows upward:

API → Repository → Use Case → Bloc → UI

The UI rebuilds:

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is ProfileLoadingState) return CircularProgressIndicator();
    if (state is ProfileLoadedState)  return Text("Welcome, ${state.user.name}");
    if (state is ProfileErrorState)   return Text(state.message);
    return SizedBox.shrink();
  },
);
```

The feature completes its journey.

---

# **4. Benefits of This Architecture**

* Easy to test (every layer is isolated)
* Predictable flow of data
* Clean dependency rules
* Scales well for large teams and enterprise apps
* Infrastructure can change without touching business rules
* UI can be replaced without rewriting logic

This pattern is especially powerful for apps that expect to grow in complexity over time.

---

# **Credits**

This architecture pattern and documentation are crafted and refined by **MaishaSoft**.
Visit **[maishasoft.com](https://maishasoft.com)** for more software insights, engineering patterns, and professional solutions.

---
