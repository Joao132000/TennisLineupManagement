class Coach {
  String id;
  final String name;
  final String email;

  Coach({
    this.id = '',
    required this.name,
    required this.email,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
  static Coach fromJson(Map<String, dynamic> json) => Coach(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
      );
}
