import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;

class AjouterRapporteursScreen extends StatefulWidget {
  final Map<String, dynamic> dossier;

  AjouterRapporteursScreen({required this.dossier});

  @override
  _AjouterRapporteursScreenState createState() =>
      _AjouterRapporteursScreenState();
}

class _AjouterRapporteursScreenState extends State<AjouterRapporteursScreen> {
  final primaryColor = Color(0xFF6C4AB6);
  final gradientColors = [Color(0xFFE0D5F7), Color(0xFFD3E5FA)];

  List<Map<String, dynamic>> selectedRapporteurs = [];

  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();

  void _ajouterRapporteurTemporaire() {
    if (selectedRapporteurs.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous avez déjà sélectionné 3 rapporteurs')),
      );
      return;
    }

    final rapporteur = {
      'id': DateTime.now().millisecondsSinceEpoch, // ID temporaire
      'nom': nomController.text.trim(),
      'prenom': prenomController.text.trim(),
      'email': emailController.text.trim(),
    };

    setState(() {
      selectedRapporteurs.add(rapporteur);
      nomController.clear();
      prenomController.clear();
      emailController.clear();
    });
  }

  Future<void> _sauvegarderRapporteurs() async {
    if (selectedRapporteurs.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner exactement trois rapporteurs'),
        ),
      );
      return;
    }

    try {
      // Insérer chaque rapporteur dans la table
      for (var rapporteur in selectedRapporteurs) {
        await Supabase.instance.client.from('rapporteurs').insert({
          'nom': rapporteur['nom'],
          'prenom': rapporteur['prenom'],
          'email': rapporteur['email'],
          'dossier_id': widget.dossier['id'],
        });
      }

      // Mise à jour du dossier
      await Supabase.instance.client
          .from('dossiers')
          .update({'statut': 'en_cours_evaluation'})
          .eq('id', widget.dossier['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rapporteurs ajoutés avec succès')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout des rapporteurs: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ajouter des Rapporteurs",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Entrez les informations de 3 rapporteurs pour ${widget.dossier['nom']} ${widget.dossier['prenom']}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    controller: nomController,
                    decoration: InputDecoration(labelText: 'Nom'),
                  ),
                  TextField(
                    controller: prenomController,
                    decoration: InputDecoration(labelText: 'Prénom'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _ajouterRapporteurTemporaire,
                    child: Text('Ajouter Rapporteur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: selectedRapporteurs.length,
                itemBuilder: (context, index) {
                  final rapporteur = selectedRapporteurs[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        "${rapporteur['nom']} ${rapporteur['prenom']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      subtitle: Text(rapporteur['email']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.print, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => InvitationPreviewPage(
                                        rapporteurName:
                                            "${rapporteur['nom']} ${rapporteur['prenom']}",
                                        candidateName:
                                            "${widget.dossier['nom']} ${widget.dossier['prenom']}",
                                        date: '02 Juin 2025',
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                selectedRapporteurs.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => InvitationPreviewPage(
                                  rapporteurName:
                                      "${rapporteur['nom']} ${rapporteur['prenom']}",
                                  candidateName:
                                      "${widget.dossier['nom']} ${widget.dossier['prenom']}",
                                  date: '02 Juin 2025',
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _sauvegarderRapporteurs,
                child: Text('Sauvegarder les Rapporteurs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InvitationPreviewPage extends StatelessWidget {
  final String rapporteurName;
  final String candidateName;
  final String date;

  const InvitationPreviewPage({
    Key? key,
    required this.rapporteurName,
    required this.candidateName,
    required this.date,
  }) : super(key: key);

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    // Charger le logo
    final logoBytes = await rootBundle.load('assets/images/logo fst.jpg');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo et en-tête
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logo, width: 100),
                  pw.Text(
                    'Béni Mellal, le $date',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 16),
              // Corps de l'invitation
              pw.Text(
                'Le Doyen',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'À\nMonsieur le Professeur $rapporteurName\nFaculté des Sciences et Techniques\nUniversité Sultan Moulay Slimane\nBéni Mellal',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Cher collègue,', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 12),
              pw.Text(
                "Je vous remercie d'avoir accepté d'évaluer l'Habilitation Universitaire de Madame $candidateName. À cet effet, je vous transmets le manuscrit et vous demande de bien vouloir me transmettre votre rapport dans un délai de 30 jours.\n\n"
                "Pour conserver le caractère de confidentialité de votre rapport, je vous prie de bien vouloir l'adresser au Doyenat de la Faculté des Sciences et Techniques.\n\n"
                "En vous remerciant pour votre collaboration, veuillez agréer, cher collègue, l'expression de mes sentiments les meilleurs.",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Le Doyen',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Ahmed BARAKAT',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
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
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Invitation Preview')),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
        canChangePageFormat: false,
        canChangeOrientation: false,
        pdfFileName: 'invitation_${rapporteurName.replaceAll(' ', '_')}.pdf',
      ),
    );
  }
}
