class User {
  final String id;
  final String name;
  final String email;
  final String token;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  /// Converts this User to a Map (e.g., for SQLite or JSON).
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'token': token,
  };

  /// Creates a User from a Map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
    );
  }

  /// Allows copying with updated fields.
  User copyWith({String? id, String? name, String? email, String? token}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          token == other.token;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ email.hashCode ^ token.hashCode;

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, token: $token)';
}
