import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AjouterDossierScreen extends StatefulWidget {
  @override
  _AjouterDossierScreenState createState() => _AjouterDossierScreenState();
}

class _AjouterDossierScreenState extends State<AjouterDossierScreen> {
  final _formKey = GlobalKey<FormState>();
  final primaryColor = Color(0xFF6C4AB6);
  final gradientColors = [Color(0xFFE0D5F7), Color(0xFFD3E5FA)];
  String nom = '';
  String prenom = '';
  String cin = '';
  String som = '';
  String etablissement = '';
  String statut = '';
  final TextEditingController titreController = TextEditingController();

  final List<Map<String, String>> piecesJointes = [
    {"type": "Demande manuscrite adressée au Doyen", "fichier": ""},
    {"type": "Autorisation du chef d'établissement d'origine", "fichier": ""},
    {
      "type":
          "Attestation de travail récente (mentionnant la date de recrutement et de titularisation)",
      "fichier": "",
    },
    {"type": "Photocopie légalisée de la CIN", "fichier": ""},
    {"type": "Extrait d'acte de naissance", "fichier": ""},
    {"type": "Photocopie légalisée du Baccalauréat", "fichier": ""},
    {"type": "Photocopie légalisée du dernier diplôme", "fichier": ""},
    {"type": "Photo d'identité", "fichier": ""},
    {
      "type": "Copie du mémoire de Thèse / PFE pour ingénieurs d'État",
      "fichier": "",
    },
    {"type": "CV détaillé", "fichier": ""},
    {"type": "Mémoire relatif à l'habilitation", "fichier": ""},
  ];

  bool allFilesUploaded() {
    return piecesJointes.every((piece) => piece['fichier']!.isNotEmpty);
  }

  Future<void> _pickFile(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true, // très important pour Web
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      final fileExt = file.extension?.toLowerCase() ?? '';
      final isAllowed = ['jpg', 'jpeg', 'png', 'pdf'].contains(fileExt);

      if (!isAllowed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seuls les fichiers PDF ou images sont autorisés.'),
          ),
        );
        return;
      }

      try {
        final storageFileName =
            '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final storagePath = 'pieces-jointes/$storageFileName';

        await Supabase.instance.client.storage
            .from('pieces-jointes')
            .uploadBinary(
              storagePath,
              file.bytes!, // on utilise les bytes ici
              fileOptions: FileOptions(contentType: _getMimeType(fileExt)),
            );

        final fileUrl = Supabase.instance.client.storage
            .from('pieces-jointes')
            .getPublicUrl(storagePath);

        setState(() {
          piecesJointes[index]['fichier'] = fileUrl;
          piecesJointes[index]['filename'] = file.name;
        });
      } catch (e) {
        print('Erreur lors du téléchargement du fichier: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement du fichier')),
        );
      }
    }
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  void _submitDossier() async {
    if (!allFilesUploaded()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez importer tous les fichiers requis.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires.'),
        ),
      );
      return;
    }

    _formKey.currentState!.save();

    try {
      final dossierData = {
        'nom': nom,
        'prenom': prenom,
        'cin': cin,
        'som': som,
        'etablissement': etablissement,
        'statut': statut,
        'pieces':
            piecesJointes
                .map(
                  (piece) => {
                    'type': piece['type'],
                    'fichier': piece['fichier'],
                    'filename': piece['filename'],
                  },
                )
                .toList(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await Supabase.instance.client
              .from('dossiers')
              .insert(dossierData)
              .select();

      if (response != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Dossier ajouté avec succès !')));
        Navigator.pop(context, true);
      } else {
        throw Exception('Erreur lors de l\'ajout du dossier');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout du dossier: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du dossier: $e')),
      );
    }
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Widget that displays a preview of a file to be uploaded.
  ///
  /// The preview shows the file name and a file icon.
  ///
  /// The [path] parameter is the full path of the file.
  ///
  /// Returns a [Container] widget with the preview.
  /*******  fbdcb0d0-60d0-4930-8520-df57b35f0764  *******/
  Widget _buildFilePreview(String path) {
    final fileName = path.split('/').last;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName,
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un Dossier"),
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
        child: SingleChildScrollView(
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
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (path.isNotEmpty) _buildFilePreview(path),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _pickFile(index),
                                icon: Icon(Icons.cloud_upload_outlined),
                                label: Text("Importer fichier"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryColor,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            Divider(color: Colors.grey.shade300),
                          ],
                        );
                      }).toList(),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, Color(0xFF8A6ED5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _submitDossier,
                    icon: Icon(Icons.send),
                    label: Text(
                      "Soumettre le Dossier",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
          labelStyle: TextStyle(color: Colors.grey.shade700),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
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
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
