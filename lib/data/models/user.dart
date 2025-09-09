class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['uid'] ?? '', // Aseguramos que 'uid' se mapea correctamente
      name:
          map['name'] ??
          map['displayName'] ??
          'Sin nombre', // Fallback a 'displayName'
      email: map['email'] ?? 'Sin correo', // Fallback si no hay correo
    );
  }

  factory User.fromMapFlutter(Map<String, dynamic> json) => User(
    id: json['id'] ?? json['uid'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
  );

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email};

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? json['uid'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
