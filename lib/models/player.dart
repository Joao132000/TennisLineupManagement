class Player {
  String id;
  final String name;
  final String email;
  final String teamId;
  final double position;
  final bool challenge;

  Player({
    this.id = '',
    required this.name,
    required this.email,
    required this.teamId,
    required this.position,
    required this.challenge,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'teamId': teamId,
        'position': position,
        'challenge': challenge,
      };

  static Player fromJson(Map<String, dynamic> json) => Player(
        id: (json['id'] ?? '').toString(),
        challenge: (json['challenge'] ?? false),
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        teamId: (json['teamId'] ?? '').toString(),
        position: double.parse(json['position'].toString()),
      );
}
