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
          pw.Text("Professeur : ${s.professeur}"),
          pw.Text("Lieu : ${s.lieu}"),
          pw.Text("Date : ${s.date.day}/${s.date.month}/${s.date.year}"),
        ],
      ),
    ),
  );

  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/avis_soutenance.pdf");
  await file.writeAsBytes(await pdf.save());

  final smtpServer = gmail('ton.email@gmail.com', 'motDePasseApplication');
  final message = Message()
    ..from = Address('ton.email@gmail.com', 'Vice-Doyen')
    ..recipients.add(s.email)
    ..subject = 'Avis de soutenance'
    ..text = 'Bonjour, veuillez trouver l’avis de soutenance en pièce jointe.'
    ..attachments = [FileAttachment(file)];

  await send(message, smtpServer);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("E-mail envoyé à ${s.email}")));
}
