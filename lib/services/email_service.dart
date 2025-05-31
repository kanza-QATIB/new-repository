import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  static Future<void> sendEmailToRapporteurs(
    Map<String, dynamic> dossier,
  ) async {
    print('Dossier reçu: $dossier'); // Debug log

    // Récupérer les rapporteurs du dossier
    final response = await Supabase.instance.client
        .from('rapporteurs')
        .select()
        .eq('dossier_id', dossier['id']);

    print('Rapporteurs trouvés: $response'); // Debug log

    if (response == null || response.isEmpty) {
      throw Exception('Aucun rapporteur assigné à ce dossier');
    }

    // S'assurer que tous les champs sont des String
    final numero = dossier['numero']?.toString() ?? 'Non spécifié';
    final dateDepot = dossier['date_depot']?.toString() ?? 'Non spécifiée';
    final statut = dossier['statut']?.toString() ?? 'Non spécifié';

    // Construire le sujet de l'email
    final subject = 'Dossier Habilitation - $numero';

    // Construire le corps de l'email
    final body = '''
Bonjour,

Vous trouverez ci-joint le dossier d'habilitation numéro $numero.

Détails du dossier :
- Numéro : $numero
- Date de dépôt : $dateDepot
- Statut : $statut

Cordialement,
''';

    // Construire la liste des destinataires
    final recipients = response
        .map((r) => r['email']?.toString() ?? '')
        .where((email) => email.isNotEmpty)
        .join(',');

    print('Recipients: $recipients'); // Debug log

    if (recipients.isEmpty) {
      throw Exception(
        'Aucune adresse email valide trouvée pour les rapporteurs',
      );
    }

    // Construire l'URL mailto
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: recipients,
      queryParameters: {'subject': subject, 'body': body},
    );

    print('Mailto URL: $emailUri'); // Debug log

    // Lancer l'application email
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossible d\'ouvrir l\'application email');
    }
  }
}
