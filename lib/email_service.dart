import 'dart:io';
import 'dart:typed_data';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  static const String _emailKey = 'sender_email';
  static const String _passwordKey = 'sender_password';

  static Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  }

  static Future<Map<String, String?>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_emailKey),
      'password': prefs.getString(_passwordKey),
    };
  }

  static Future<void> sendHabilitationDossierToRapporteur({
    required String rapporteurEmail,
    required String rapporteurName,
    required Map<String, dynamic> dossier,
  }) async {
    try {
      final credentials = await getCredentials();
      final senderEmail = credentials['email'];
      final senderPassword = credentials['password'];

      if (senderEmail == null || senderPassword == null) {
        throw Exception(
          'Veuillez configurer les informations d\'email dans les paramètres',
        );
      }

      final smtpServer = gmail(senderEmail, senderPassword);

      final message =
          Message()
            ..from = Address(senderEmail, 'Vice-Doyen de la Recherche')
            ..recipients.add(rapporteurEmail)
            ..subject =
                'Dossier d\'habilitation - ${dossier['nom']} ${dossier['prenom']}'
            ..text = '''
Cher(e) $rapporteurName,

Je vous prie de trouver ci-joint le dossier d'habilitation de ${dossier['nom']} ${dossier['prenom']}.

Informations du candidat :
- Nom : ${dossier['nom']}
- Prénom : ${dossier['prenom']}
- CIN : ${dossier['cin']}
- SOM : ${dossier['som']}
- Établissement : ${dossier['etablissement']}

Veuillez examiner ce dossier et nous faire part de votre évaluation.

Cordialement,
Le Vice-Doyen de la Recherche
''';

      final pieces = dossier['pieces'] as List;
      for (var piece in pieces) {
        if (piece['fichier'] != null &&
            piece['fichier'].toString().isNotEmpty) {
          final fileUrl = piece['fichier'].toString();
          final fileName = piece['filename']?.toString() ?? 'document.pdf';

          final response = await http.get(Uri.parse(fileUrl));
          if (response.statusCode == 200) {
            final tempDir = Directory.systemTemp;
            final tempFile = File(path.join(tempDir.path, fileName));
            await tempFile.writeAsBytes(response.bodyBytes);

            message.attachments.add(
              FileAttachment(tempFile)
                ..cid = '<$fileName>'
                ..location = Location.attachment
                ..contentType = _getContentType(fileName),
            );
          }
        }
      }

      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error sending email: $e');
      throw Exception('Erreur lors de l\'envoi de l\'email: $e');
    }
  }

  /// ✅ Ouvre Gmail Web dans le navigateur avec sujet et corps préremplis
  static Future<void> openGmailInBrowser({
    required String recipientEmail,
    required String subject,
    required String body,
  }) async {
    final gmailUrl =
        'https://mail.google.com/mail/?view=cm&fs=1&to=$recipientEmail&su=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    final Uri gmailUri = Uri.parse(gmailUrl);

    if (await canLaunchUrl(gmailUri)) {
      await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossible d\'ouvrir Gmail dans le navigateur');
    }
  }

  /// ✉️ Remplacé mailto par Gmail web
  static Future<void> sendEmailViaLauncher({
    required String recipientEmail,
    required String recipientName,
    required Map<String, dynamic> dossier,
  }) async {
    try {
      final StringBuffer emailBody = StringBuffer();
      emailBody.writeln('Cher(e) $recipientName,\n');
      emailBody.writeln(
        'Je vous prie de trouver ci-joint le dossier d\'habilitation de ${dossier['nom']} ${dossier['prenom']}.\n',
      );
      emailBody.writeln('Informations du candidat :');
      emailBody.writeln('- Nom : ${dossier['nom']}');
      emailBody.writeln('- Prénom : ${dossier['prenom']}');
      emailBody.writeln('- CIN : ${dossier['cin']}');
      emailBody.writeln('- SOM : ${dossier['som']}');
      emailBody.writeln('- Établissement : ${dossier['etablissement']}');
      emailBody.writeln('- Statut : ${dossier['statut']}\n');
      emailBody.writeln('Pièces jointes :');

      final pieces = dossier['piecesJointes'] as List;
      for (var piece in pieces) {
        if (piece['url'] != null && piece['url'].toString().isNotEmpty) {
          emailBody.writeln('- ${piece['titre']}: ${piece['url']}');
        }
      }

      emailBody.writeln(
        '\nVeuillez examiner ce dossier et nous faire part de votre évaluation.\n',
      );
      emailBody.writeln('Cordialement,\nLe Vice-Doyen de la Recherche');

      await openGmailInBrowser(
        recipientEmail: recipientEmail,
        subject:
            'Dossier d\'habilitation - ${dossier['nom']} ${dossier['prenom']}',
        body: emailBody.toString(),
      );
    } catch (e) {
      print('Error launching Gmail: $e');
      throw Exception('Erreur lors de l\'ouverture de Gmail: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getRapporteursForDossier(
    String dossierId,
  ) async {
    try {
      final response = await Supabase.instance.client
          .from('rapporteurs')
          .select()
          .eq('dossier_id', dossierId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des rapporteurs: $e');
      return [];
    }
  }

  static Future<void> sendEmailToRapporteurs(
    Map<String, dynamic> dossier,
  ) async {
    try {
      final rapporteurs = await getRapporteursForDossier(
        dossier['id'].toString(),
      );

      if (rapporteurs.isEmpty) {
        throw Exception('Aucun rapporteur trouvé pour ce dossier');
      }

      final recipients = rapporteurs
          .map((r) => r['email'].toString())
          .join(',');

      final StringBuffer emailBody = StringBuffer();
      emailBody.writeln('Cher(e)s Rapporteurs,\n');
      emailBody.writeln(
        'Je vous prie de trouver ci-joint le dossier d\'habilitation de ${dossier['nom']} ${dossier['prenom']}.\n',
      );
      emailBody.writeln('Informations du candidat :');
      emailBody.writeln('- Nom : ${dossier['nom']}');
      emailBody.writeln('- Prénom : ${dossier['prenom']}');
      emailBody.writeln('- CIN : ${dossier['cin']}');
      emailBody.writeln('- SOM : ${dossier['som']}');
      emailBody.writeln('- Établissement : ${dossier['etablissement']}');
      emailBody.writeln('- Statut : ${dossier['statut']}\n');
      emailBody.writeln('Pièces jointes :');

      final pieces = dossier['pieces'] as List;
      for (var piece in pieces) {
        if (piece['fichier'] != null &&
            piece['fichier'].toString().isNotEmpty) {
          emailBody.writeln('- ${piece['filename']}: ${piece['fichier']}');
        }
      }

      emailBody.writeln(
        '\nVeuillez examiner ce dossier et nous faire part de votre évaluation.\n',
      );
      emailBody.writeln('Cordialement,\nLe Vice-Doyen de la Recherche');

      await openGmailInBrowser(
        recipientEmail: recipients,
        subject:
            'Dossier d\'habilitation - ${dossier['nom']} ${dossier['prenom']}',
        body: emailBody.toString(),
      );
    } catch (e) {
      print('Error launching Gmail: $e');
      throw Exception('Erreur lors de l\'ouverture de Gmail: $e');
    }
  }
}

/// 🔍 Détecte le type MIME d’un fichier selon son extension
String _getContentType(String fileName) {
  final extension = fileName.split('.').last.toLowerCase();
  switch (extension) {
    case 'pdf':
      return 'application/pdf';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'doc':
      return 'application/msword';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'pptx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    case 'ppt':
      return 'application/vnd.ms-powerpoint';
    case 'txt':
      return 'text/plain';
    case 'zip':
      return 'application/zip';
    case 'rar':
      return 'application/x-rar-compressed';
    default:
      return 'application/octet-stream';
  }
}
