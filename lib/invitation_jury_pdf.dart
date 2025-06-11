import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../soutenance.dart';
import 'package:flutter/services.dart';

class InvitationJuryPdfPage extends StatelessWidget {
  final String juryName;
  final String juryRole;
  final String juryEtablissement;
  final String professorName;
  final String defenseLocation;
  final DateTime defenseDate;

  const InvitationJuryPdfPage({
    required this.juryName,
    required this.juryRole,
    required this.juryEtablissement,
    required this.professorName,
    required this.defenseLocation,
    required this.defenseDate,
  });

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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
    final date = _formatDate(defenseDate);

    final logoBytes = await rootBundle.load('assets/images/logo fst.jpg');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    String invitationPhrase;
    if (juryRole.toLowerCase().contains('président')) {
      invitationPhrase = 'présider la soutenance';
    } else {
      invitationPhrase = 'prendre part au jury de soutenance';
    }

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(logo, width: 90),
                    pw.Text(
                      'Béni Mellal, le $date',
                      style: pw.TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Lettre d'invitation au jury",
                  style: pw.TextStyle(
                    fontSize: 18,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('Le Doyen', style: pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 5),
                      pw.Text('À', style: pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Monsieur le Professeur $juryName',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.Text(
                        'Faculté des Sciences et Techniques',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.Text(
                        '${juryEtablissement.split(',').length > 1 ? juryEtablissement.split(',')[0].trim() : juryEtablissement}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      if (juryEtablissement.split(',').length > 1)
                        pw.Text(
                          juryEtablissement.split(',')[1].trim(),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontStyle: pw.FontStyle.italic,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: 'Objet : ',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                      pw.TextSpan(
                        text:
                            '''Soutenance d'une Habilitation Universitaire de Monsieur $professorName''',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text('Cher collègue,', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 12),
                pw.Text(
                  "J'ai l'honneur de vous inviter à $invitationPhrase d'une Habilitation Universitaire de Monsieur $professorName.\n\n"
                  "Cette soutenance publique aura lieu le $date à $defenseLocation de la Faculté des Sciences et Techniques de Béni Mellal.\n\n"
                  "En attendant, je vous prie de recevoir, cher collègue, l'expression de mes sincères salutations.",
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.Text(
                  "Centre des Etudes Doctorales « Sciences et Techniques » Faculté des Sciences et Techniques\nBP 523, 23000 Béni Mellal - Tél : 0523485112/22/82   Fax :0523 48 52 01",
                  style: pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
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
