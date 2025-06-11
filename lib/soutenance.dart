class Soutenance {
  String id;
  String nomProfesseur; // Correspond à la colonne 'nom_prof'
  String lieuSoutenance; // Correspond à la colonne 'lieu_soutenance'
  DateTime dateSoutenance; // Correspond à la colonne 'date_soutenance'
  String jury1;
  String jury2;
  String jury3;
  String jury4;
  String roleJury1; // Added role fields
  String roleJury2;
  String roleJury3;
  String roleJury4;
  String etablissementJury1; // Added establishment fields
  String etablissementJury2;
  String etablissementJury3;
  String etablissementJury4;
  String? email; // Colonne facultative
  String? statut; // nullable si parfois vide

  Soutenance({
    required this.id,
    required this.nomProfesseur,
    required this.lieuSoutenance,
    required this.dateSoutenance,
    required this.jury1,
    required this.jury2,
    required this.jury3,
    required this.jury4,
    required this.roleJury1, // Added role parameters
    required this.roleJury2,
    required this.roleJury3,
    required this.roleJury4,
    required this.etablissementJury1, // Added to constructor
    required this.etablissementJury2,
    required this.etablissementJury3,
    required this.etablissementJury4,
    this.email,
    this.statut,
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
      'jury4': jury4,
      'role_jury1': roleJury1, // Added role fields to map
      'role_jury2': roleJury2,
      'role_jury3': roleJury3,
      'role_jury4': roleJury4,
      'etablissement_jury1': etablissementJury1, // Added to map
      'etablissement_jury2': etablissementJury2,
      'etablissement_jury3': etablissementJury3,
      'etablissement_jury4': etablissementJury4,
      'email': email,
      'statut': statut,
    };
  }

  // Méthode pour créer un objet Soutenance à partir d'un Map
  factory Soutenance.fromMap(Map<String, dynamic> map) {
    // Debug prints to identify null values
    map.forEach((key, value) {
      if (value == null) {
        print('DEBUG: Null value found for key: $key');
      }
    });

    return Soutenance(
      id: map['id']?.toString() ?? '',
      nomProfesseur: map['nom_prof'] ?? '',
      lieuSoutenance: map['lieu_soutenance'] ?? '',
      dateSoutenance:
          map['date_soutenance'] != null
              ? DateTime.parse(map['date_soutenance'])
              : DateTime.now(),
      jury1: map['jury1'] ?? '',
      jury2: map['jury2'] ?? '',
      jury3: map['jury3'] ?? '',
      jury4: map['jury4'] ?? '',
      roleJury1: map['role_jury1'] ?? 'Rapporteur',
      roleJury2: map['role_jury2'] ?? 'Rapporteur',
      roleJury3: map['role_jury3'] ?? 'Rapporteur',
      roleJury4: map['role_jury4'] ?? 'Rapporteur',
      etablissementJury1: map['etablissement_jury1'] ?? '',
      etablissementJury2: map['etablissement_jury2'] ?? '',
      etablissementJury3: map['etablissement_jury3'] ?? '',
      etablissementJury4: map['etablissement_jury4'] ?? '',
      email: map['email'],
      statut: map['statut'],
    );
  }

  String? get nomProf => null;

  get map => null;
  Soutenance copyWith({required String statut}) {
    throw UnimplementedError('Fonction copyWith non implémentée.');
  }
}
