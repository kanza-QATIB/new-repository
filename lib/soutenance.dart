class Soutenance {
  String id;
  String nomProfesseur; // Correspond à la colonne 'nom_prof'
  String lieuSoutenance; // Correspond à la colonne 'lieu_soutenance'
  DateTime dateSoutenance; // Correspond à la colonne 'date_soutenance'
  String jury1;
  String jury2;
  String jury3;
  String? email; // Colonne facultative
  DateTime? dateNaissance; // Colonne facultative

  Soutenance({
    required this.id,
    required this.nomProfesseur,
    required this.lieuSoutenance,
    required this.dateSoutenance,
    required this.jury1,
    required this.jury2,
    required this.jury3,
    this.email,
    this.dateNaissance,
  });

  // Méthode pour convertir un objet Soutenance en un Map pour insertion dans Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom_prof': nomProfesseur,
      'lieu_soutenance': lieuSoutenance,
      'date_soutenance': dateSoutenance.toIso8601String(),
      'jury1': jury1,
      'jury2': jury2,
      'jury3': jury3,
      'email': email,
      'date_naissance': dateNaissance?.toIso8601String(),
    };
  }

  // Méthode pour créer un objet Soutenance à partir d'un Map
  factory Soutenance.fromMap(Map<String, dynamic> map) {
    return Soutenance(
      id: map['id'].toString(),
      nomProfesseur: map['nom_prof'],
      lieuSoutenance: map['lieu_soutenance'],
      dateSoutenance: DateTime.parse(map['date_soutenance']),
      jury1: map['jury1'],
      jury2: map['jury2'],
      jury3: map['jury3'],
      email: map['email'],
      dateNaissance: map['date_naissance'] != null
          ? DateTime.parse(map['date_naissance'])
          : null,
    );
  }

  String? get nomProf => null;
}
