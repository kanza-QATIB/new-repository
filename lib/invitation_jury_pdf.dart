import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../soutenance.dart';

class InvitationJuryPdfPage extends StatelessWidget {
  final Soutenance soutenance;

  const InvitationJuryPdfPage({required this.soutenance});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF6C4AB6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        centerTitle: true,
        title: Text(
          "Lettre d'invitation au jury",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.mail_outline_rounded, size: 80, color: primaryColor),
              SizedBox(height: 16),
              Text(
                "Prévisualisation de la lettre d'invitation",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PdfPreview(
                    build: (format) => _generatePdf(format),
                    padding: EdgeInsets.all(16),
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    canDebug: false,
                    allowPrinting: true,
                    allowSharing: true,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  Printing.sharePdf(
                    bytes: await _generatePdf(PdfPageFormat.a4),
                    filename: 'invitation_jury.pdf',
                  );
                },
                icon: Icon(Icons.download_rounded, color: Colors.white),
                label: Text(
                  "Partager / Télécharger",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final date = _formatDate(soutenance.dateSoutenance);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("faculté de science et technique béni mellal",
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text("Lettre d'invitation au jury",
                    style: pw.TextStyle(
                      fontSize: 18,
                      decoration: pw.TextDecoration.underline,
                    )),
                pw.SizedBox(height: 30),
                pw.Text("À : ${soutenance.jury1 ?? ''}"),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Monsieur/Madame,\n\n"
                  "Par la présente, nous avons le plaisir de vous inviter à faire partie du jury de la soutenance prévue comme suit :\n\n"
                  "- Nom du professeur : ${soutenance.nomProfesseur}\n"
                  "- Lieu : ${soutenance.lieuSoutenance}\n"
                  "- Date : $date\n\n"
                  "Votre expertise dans le domaine est hautement appréciée pour évaluer cette soutenance.\n\n"
                  "Nous restons à votre disposition pour tout complément d’information.\n\n"
                  "Cordialement,\n\n"
                  "Le Vice-Doyen de la Recherche",
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
