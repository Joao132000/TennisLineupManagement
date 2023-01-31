class Doubles {
  String id;
  final String teamId;
  final String player1name;
  final String player2name;
  final int position;

  Doubles({
    this.id = '',
    required this.teamId,
    required this.player1name,
    required this.player2name,
    required this.position,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'teamId': teamId,
        'player1name': player1name,
        'player2name': player2name,
        'position': position,
      };
  static Doubles fromJson(Map<String, dynamic> json) => Doubles(
        id: (json['id'] ?? '').toString(),
        teamId: (json['teamId'] ?? '').toString(),
        player2name: (json['player2name'] ?? '').toString(),
        player1name: (json['player1name'] ?? '').toString(),
        position: int.parse(json['position'].toString()),
      );
}
