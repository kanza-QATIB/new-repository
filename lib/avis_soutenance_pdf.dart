import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../soutenance.dart';
import 'package:flutter/services.dart';

class AvisSoutenancePdfPage extends StatelessWidget {
  final Soutenance soutenance;

  const AvisSoutenancePdfPage({required this.soutenance});

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
          "Avis de Soutenance",
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
              Icon(Icons.picture_as_pdf, size: 80, color: primaryColor),
              SizedBox(height: 16),
              Text(
                "Prévisualisation de l'avis de soutenance",
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
                    filename: 'avis_soutenance.pdf',
                  );
                },
                icon: Icon(Icons.share, color: Colors.white),
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

    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    final logoBytes = await rootBundle.load('assets/images/logo fst.jpg');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logo, width: 90),
                  pw.Text(
                    'Béni Mellal, le ${_formatDate(soutenance.dateSoutenance)}',
                    style: pw.TextStyle(font: fontRegular, fontSize: 13),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  "Avis de soutenance d'une Habilitation Universitaire",
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 18,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                "Le Doyen de la Faculté des Sciences et Techniques de Béni-Mellal porte à la connaissance du grand public que Monsieur ${soutenance.nomProfesseur} présentera son Habilitation Universitaire le ${_formatDate(soutenance.dateSoutenance)} à ${soutenance.lieuSoutenance} de la Faculté des Sciences et Techniques de Béni Mellal devant le jury composé de :",
                style: pw.TextStyle(font: fontRegular, fontSize: 14),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 16),
              ..._juryWidgets(fontRegular, fontBold),
              pw.SizedBox(height: 32),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end),
                ],
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  "Centre des Etudes Doctorales « Sciences et Techniques » Faculté des Sciences et Techniques\nBP 523, 23000 Béni Mellal - Tél : 0523485112/22/82   Fax :0523 48 52 01",
                  style: pw.TextStyle(font: fontRegular, fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  List<pw.Widget> _juryWidgets(pw.Font fontRegular, pw.Font fontBold) {
    final jury = [
      {
        'nom': soutenance.jury1,
        'etab': soutenance.etablissementJury1,
        'role': soutenance.roleJury1,
      },
      {
        'nom': soutenance.jury2,
        'etab': soutenance.etablissementJury2,
        'role': soutenance.roleJury2,
      },
      {
        'nom': soutenance.jury3,
        'etab': soutenance.etablissementJury3,
        'role': soutenance.roleJury3,
      },
      if (soutenance.jury4 != null && soutenance.jury4!.isNotEmpty)
        {
          'nom': soutenance.jury4,
          'etab': soutenance.etablissementJury4,
          'role': soutenance.roleJury4,
        },
    ];

    List<pw.Widget> widgets = [];

    for (final membre in jury) {
      final nom = membre['nom'] ?? '';
      final etab = membre['etab'] ?? '';
      final role = membre['role'] ?? '';
      String roleAffiche =
          role.toLowerCase().contains('président') &&
                  role.toLowerCase().contains('rapporteur')
              ? 'Président / Rapporteur'
              : role;

      widgets.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '•',
              style: pw.TextStyle(
                font: fontRegular,
                fontFallback: [fontRegular],
                fontSize: 14,
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Monsieur ',
                          style: pw.TextStyle(font: fontRegular, fontSize: 14),
                        ),
                        pw.TextSpan(
                          text: nom,
                          style: pw.TextStyle(font: fontBold, fontSize: 14),
                        ),
                        pw.TextSpan(
                          text: ' :',
                          style: pw.TextStyle(font: fontRegular, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 15),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Professeur, $etab, ',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 14,
                            ),
                          ),
                          pw.TextSpan(
                            text: roleAffiche,
                            style: pw.TextStyle(font: fontBold, fontSize: 14),
                          ),
                          pw.TextSpan(
                            text: ' ;',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      widgets.add(pw.SizedBox(height: 8));
    }

    return widgets;
  }

  String _formatDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à $hour:$minute";
  }
}
