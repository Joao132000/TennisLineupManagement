class Team {
  String id;
  final String type;
  final String university;
  final String league;
  final String coachId;

  Team(
      {this.id = '',
      required this.type,
      required this.university,
      required this.league,
      required this.coachId});
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'university': university,
        'league': league,
        'coachId': coachId,
      };

  static Team fromJson(Map<String, dynamic> json) => Team(
        id: (json['id'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        university: (json['university'] ?? '').toString(),
        league: (json['league'] ?? '').toString(),
        coachId: (json['coachId'] ?? '').toString(),
      );
}
