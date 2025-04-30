import 'package:supabase_flutter/supabase_flutter.dart';
import '../soutenance.dart';

class DatabaseService {
  final _client = Supabase.instance.client;

  Future<void> saveSoutenance(Soutenance soutenance) async {
    try {
      await _client.from('soutenance').insert({
        'id': soutenance.id,
        'nom_prof': soutenance.nomProfesseur, // Renommé pour refléter la colonne 'nom_prof'
        'lieu_soutenance': soutenance.lieuSoutenance, // Correspond à 'lieu_soutenance'
        'date_soutenance': soutenance.dateSoutenance.toIso8601String().split('T').first, // Date adaptée au format
        'jury1': soutenance.jury1,
        'jury2': soutenance.jury2,
        'jury3': soutenance.jury3,
        'email': soutenance.email, // Ajout de l'attribut email
        'date_naissance': soutenance.dateNaissance?.toIso8601String()?.split('T').first, // Gestion optionnelle
      });
    } catch (e) {
      throw Exception('Erreur de sauvegarde : $e');
    }
  }
}
