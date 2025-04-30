import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../soutenance.dart';

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

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "faculté de science et technique béni mellel",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Avis de soutenance:",
                  style: pw.TextStyle(
                    fontSize: 18,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text("Nom du professeur : ${soutenance.nomProfesseur}"),
                pw.Text("Lieu de soutenance : ${soutenance.lieuSoutenance}"),
                pw.Text("Date : ${_formatDate(soutenance.dateSoutenance)}"),
                pw.SizedBox(height: 20),
                pw.Text("Jury :"),
                pw.Bullet(text: soutenance.jury1 ?? ""),
                pw.Bullet(text: soutenance.jury2 ?? ""),
                pw.Bullet(text: soutenance.jury3 ?? ""),
                pw.SizedBox(height: 40),
                pw.Text("Signature :", style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 30),
                pw.Text("Vice-Doyen de la Recherche"),
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
