import 'dart:io';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: deprecated_member_use
import 'dart:html' as html; // important pour Web
import 'package:flutter/foundation.dart' show kIsWeb;

class AjouterDossierScreen extends StatefulWidget {
  @override
  _AjouterDossierScreenState createState() => _AjouterDossierScreenState();
}

class _AjouterDossierScreenState extends State<AjouterDossierScreen> {
  final _formKey = GlobalKey<FormState>();

  String nom = '';
  String prenom = '';
  String cin = '';
  String som = '';
  String etablissement = '';
  String statut = '';

  final List<Map<String, String>> piecesJointes = [
    {"type": "Demande manuscrite adressée au Doyen", "fichier": ""},
    {"type": "Autorisation du chef d’établissement d’origine", "fichier": ""},
    {
      "type":
          "Attestation de travail récente (mentionnant la date de recrutement et de titularisation)",
      "fichier": "",
    },
    {"type": "Photocopie légalisée de la CIN", "fichier": ""},
    {"type": "Extrait d’acte de naissance", "fichier": ""},
    {"type": "Photocopie légalisée du Baccalauréat", "fichier": ""},
    {"type": "Photocopie légalisée du dernier diplôme", "fichier": ""},
    {"type": "Photo d’identité", "fichier": ""},
    {
      "type": "Copie du mémoire de Thèse / PFE pour ingénieurs d’État",
      "fichier": "",
    },
    {"type": "CV détaillé", "fichier": ""},
    {"type": "Mémoire relatif à l’habilitation", "fichier": ""},
  ];
  Future<void> _importerFichier(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true, // utile pour accéder à bytes sur le Web
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;

      if (kIsWeb) {
        // Pour Web : on utilise le nom du fichier ou on génère une URL avec bytes
        final fileBytes = file.bytes;
        final fileName = file.name;

        if (fileBytes != null &&
            (fileName.endsWith('.jpg') ||
                fileName.endsWith('.jpeg') ||
                fileName.endsWith('.png'))) {
          final blob = html.Blob([fileBytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          setState(() {
            piecesJointes[index]['fichier'] = url; // prévisualisation image
          });
        } else {
          setState(() {
            piecesJointes[index]['fichier'] = fileName;
          });
        }
      } else {
        // Pour Mobile/Desktop
        setState(() {
          piecesJointes[index]['fichier'] = file.path!;
        });
      }
    }
  }

  Future<void> _soumettreFormulaire() async {
    if (_formKey.currentState!.validate()) {
      // Vérifier que tous les fichiers sont bien ajoutés
      bool allFilesUploaded = piecesJointes.every(
        (piece) => piece['fichier']!.isNotEmpty,
      );

      if (!allFilesUploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Veuillez importer tous les fichiers requis."),
          ),
        );
        return;
      }

      _formKey.currentState!.save();

      await Supabase.instance.client.from('dossiers').insert({
        'nom': nom,
        'prenom': prenom,
        'cin': cin,
        'som': som,
        'etablissement': etablissement,
        'statut': statut,
        'pieces': piecesJointes,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dossier ajouté à Supabase avec succès")),
      );
    }
  }

  Widget _buildFilePreview(String filePath) {
    if (filePath.toLowerCase().endsWith('.jpg') ||
        filePath.toLowerCase().endsWith('.jpeg') ||
        filePath.toLowerCase().endsWith('.png')) {
      return Container(
        margin: EdgeInsets.only(top: 8),
        width: 100,
        height: 100,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Image.file(File(filePath), fit: BoxFit.cover),
      );
    } else if (filePath.toLowerCase().endsWith('.pdf')) {
      return Row(
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red),
          SizedBox(width: 8),
          Expanded(child: Text(filePath.split('/').last)),
        ],
      );
    } else {
      return Text(filePath.split('/').last);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un Dossier"),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSectionCard(
                title: "Informations Professeur",
                children: [
                  _buildTextField("Nom", (val) => nom = val ?? ''),
                  _buildTextField("Prénom", (val) => prenom = val ?? ''),
                  _buildTextField("CIN", (val) => cin = val ?? ''),
                  _buildTextField("SOM", (val) => som = val ?? ''),
                  _buildTextField(
                    "Établissement",
                    (val) => etablissement = val ?? '',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "Informations Dossier",
                children: [
                  _buildTextField("Statut", (val) => statut = val ?? ''),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "Pièces Jointes",
                children:
                    piecesJointes.asMap().entries.map((entry) {
                      int index = entry.key;
                      String type = entry.value['type']!;
                      String path = entry.value['fichier']!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "• $type",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          if (path.isNotEmpty) _buildFilePreview(path),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _importerFichier(index),
                            icon: Icon(Icons.cloud_upload_outlined),
                            label: Text("Importer fichier"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade100,
                              foregroundColor: Colors.deepPurple.shade900,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const Divider(),
                        ],
                      );
                    }).toList(),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _soumettreFormulaire,
                icon: Icon(Icons.send),
                label: Text("Soumettre le Dossier"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onSaved: onSave,
        validator:
            (value) => value!.isEmpty ? 'Ce champ est obligatoire' : null,
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
