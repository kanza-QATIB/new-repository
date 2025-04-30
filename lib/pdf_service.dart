import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../soutenance.dart';

Future<void> generateAvisSoutenancePdf(BuildContext context, Soutenance s) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("Faculté des Sciences et Techniques - Beni Mellal", style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 20),
          pw.Text("Avis de soutenance"),
          pw.Text("Nom du professeur : ${s.nomProfesseur}"), // Aligné avec 'nom_prof'
          pw.Text("Lieu de soutenance : ${s.lieuSoutenance}"), // Aligné avec 'lieu_soutenance'
          pw.Text("Date de soutenance : ${s.dateSoutenance.day}/${s.dateSoutenance.month}/${s.dateSoutenance.year}"), // Aligné avec 'date_soutenance'
        ],
      ),
    ),
  );

  // Créer le fichier PDF
  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/avis_soutenance.pdf");
  await file.writeAsBytes(await pdf.save());

  // Configurer le serveur SMTP
  final smtpServer = gmail('ton.email@gmail.com', 'motDePasseApplication');
  final message = Message()
    ..from = Address('ton.email@gmail.com', 'Vice-Doyen')
    ..recipients.add(s.email) // Utilisation de la colonne 'email'
    ..subject = 'Avis de soutenance'
    ..text = 'Bonjour, veuillez trouver l’avis de soutenance en pièce jointe.'
    ..attachments = [FileAttachment(file)];

  // Envoyer l'e-mail
  await send(message, smtpServer);

  // Afficher un message de confirmation
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("E-mail envoyé à ${s.email}")),
  );
}
