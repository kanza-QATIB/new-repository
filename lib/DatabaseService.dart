import 'package:supabase_flutter/supabase_flutter.dart';
import '../soutenance.dart';

class DatabaseService {
  final _client = Supabase.instance.client;

  Future<void> saveSoutenance(Soutenance soutenance) async {
    try {
      await _client.from('soutenance').insert({
        'id': soutenance.id,
        'nom_prof':
            soutenance
                .nomProfesseur, // Renommé pour refléter la colonne 'nom_prof'
        'lieu_soutenance':
            soutenance.lieuSoutenance, // Correspond à 'lieu_soutenance'
        'date_soutenance':
            soutenance.dateSoutenance
                .toIso8601String()
                .split('T')
                .first, // Date adaptée au format
        'jury1': soutenance.jury1,
        'jury2': soutenance.jury2,
        'jury3': soutenance.jury3,
        'jury4': soutenance.jury4,
        'role_jury1': soutenance.roleJury1,
        'role_jury2': soutenance.roleJury2,
        'role_jury3': soutenance.roleJury3,
        'role_jury4': soutenance.roleJury4,
        'etablisement_jury1': soutenance.etablissementJury1,
        'etablisement_jury2': soutenance.etablissementJury2,
        'etablisement_jury3': soutenance.etablissementJury3,
        'etablisement_jury4': soutenance.etablissementJury4,
        'email': soutenance.email, // Ajout de l'attribut email
      });
    } catch (e) {
      throw Exception('Erreur de sauvegarde : $e');
    }
  }
}
