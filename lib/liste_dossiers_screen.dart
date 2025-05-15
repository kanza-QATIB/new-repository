import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dossier_details_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ListeDossiersScreen extends StatefulWidget {
  @override
  _ListeDossiersScreenState createState() => _ListeDossiersScreenState();
}

class _ListeDossiersScreenState extends State<ListeDossiersScreen> {
  final primaryColor = Color(0xFF6C4AB6);
  final gradientColors = [Color(0xFFE0D5F7), Color(0xFFD3E5FA)];
  List<Map<String, dynamic>> dossiers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _chargerDossiers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rafraîchir la liste quand on revient de l'écran d'ajout
    final result = ModalRoute.of(context)?.settings.arguments;
    if (result == true) {
      _chargerDossiers();
    }
  }

  Future<void> _chargerDossiers() async {
    try {
      print('Chargement des dossiers...');
      final response = await Supabase.instance.client
          .from('dossiers')
          .select()
          .order('created_at', ascending: false);

      print('Réponse reçue: $response');

      if (response != null) {
        setState(() {
          dossiers = List<Map<String, dynamic>>.from(response);
          isLoading = false;
          errorMessage = null;
        });
        print('Nombre de dossiers chargés: ${dossiers.length}');
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Aucune donnée reçue';
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des dossiers: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur lors du chargement des dossiers: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Liste des Dossiers",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _chargerDossiers,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                )
                : errorMessage != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _chargerDossiers,
                        child: Text("Réessayer"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                : dossiers.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 80,
                        color: primaryColor.withAlpha(128),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Aucun dossier trouvé",
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _chargerDossiers,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: dossiers.length,
                    itemBuilder: (context, index) {
                      final dossier = dossiers[index];
                      return _buildDossierCard(dossier);
                    },
                  ),
                ),
      ),
    );
  }

  Widget _buildDossierCard(Map<String, dynamic> dossier) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${dossier['nom']} ${dossier['prenom']}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withAlpha(26), // 0.1 opacity = 26/255
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dossier['statut'] ?? 'En attente',
                      style: TextStyle(
                        color: primaryColor.withAlpha(
                          77,
                        ), // 0.3 opacity = 77/255
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildInfoRow(Icons.credit_card, "CIN: ${dossier['cin']}"),
              _buildInfoRow(Icons.school, "SOM: ${dossier['som']}"),
              _buildInfoRow(
                Icons.business,
                "Établissement: ${dossier['etablissement']}",
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pièces jointes: ${(dossier['pieces'] as List).length}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: primaryColor),
                    onSelected: (value) {
                      switch (value) {
                        case 'voir_details':
                          _showDossierDetails(dossier);
                          break;
                        case 'modifier':
                          _modifierDossier(dossier);
                          break;
                        case 'supprimer':
                          _supprimerDossier(dossier);
                          break;
                      }
                    },
                    itemBuilder:
                        (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'voir_details',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, color: primaryColor),
                                SizedBox(width: 8),
                                Text('Voir détails'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'modifier',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: primaryColor),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'supprimer',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Supprimer'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showDossierDetails(Map<String, dynamic> dossier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: DossierDetailsScreen(dossier: dossier),
          ),
    );
  }

  void _modifierDossier(Map<String, dynamic> dossier) {
    final TextEditingController nomController = TextEditingController(
      text: dossier['nom'],
    );
    final TextEditingController prenomController = TextEditingController(
      text: dossier['prenom'],
    );
    final TextEditingController cinController = TextEditingController(
      text: dossier['cin'],
    );
    final TextEditingController somController = TextEditingController(
      text: dossier['som'],
    );
    final TextEditingController etablissementController = TextEditingController(
      text: dossier['etablissement'],
    );
    final TextEditingController statutController = TextEditingController(
      text: dossier['statut'],
    );

    // Copier la liste des pièces jointes pour la modification
    List<Map<String, dynamic>> piecesJointes = List<Map<String, dynamic>>.from(
      dossier['pieces'],
    );

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Modifier le dossier'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nomController,
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: prenomController,
                          decoration: InputDecoration(
                            labelText: 'Prénom',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: cinController,
                          decoration: InputDecoration(
                            labelText: 'CIN',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: somController,
                          decoration: InputDecoration(
                            labelText: 'SOM',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: etablissementController,
                          decoration: InputDecoration(
                            labelText: 'Établissement',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: statutController,
                          decoration: InputDecoration(
                            labelText: 'Statut',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Pièces Jointes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        ...piecesJointes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final piece = entry.value;
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    piece['type'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  if (piece['fichier'] != null &&
                                      piece['fichier'].toString().isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.attach_file,
                                          size: 16,
                                          color: primaryColor,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            piece['filename'] ?? 'Document',
                                            style: TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.visibility,
                                            size: 20,
                                            color: primaryColor,
                                          ),
                                          onPressed:
                                              () => _viewDocument(
                                                piece['fichier'],
                                                context,
                                              ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: primaryColor,
                                          ),
                                          onPressed: () async {
                                            final result =
                                                await FilePicker.platform
                                                    .pickFiles();
                                            if (result != null &&
                                                result.files.single.path !=
                                                    null) {
                                              try {
                                                final file = File(
                                                  result.files.single.path!,
                                                );
                                                final fileExt =
                                                    result.files.single.name
                                                        .split('.')
                                                        .last;
                                                final fileName =
                                                    '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
                                                final filePath =
                                                    'pieces_jointes/$fileName';

                                                // Supprimer l'ancien fichier si existe
                                                if (piece['fichier'] != null &&
                                                    piece['fichier']
                                                        .toString()
                                                        .isNotEmpty) {
                                                  final oldPath =
                                                      piece['fichier']
                                                          .toString()
                                                          .split('/')
                                                          .last;
                                                  await Supabase
                                                      .instance
                                                      .client
                                                      .storage
                                                      .from('dossiers')
                                                      .remove([
                                                        'pieces_jointes/$oldPath',
                                                      ]);
                                                }

                                                // Télécharger le nouveau fichier
                                                await Supabase
                                                    .instance
                                                    .client
                                                    .storage
                                                    .from('dossiers')
                                                    .uploadBinary(
                                                      filePath,
                                                      await file.readAsBytes(),
                                                      fileOptions: FileOptions(
                                                        contentType:
                                                            'application/octet-stream',
                                                      ),
                                                    );

                                                final fileUrl = Supabase
                                                    .instance
                                                    .client
                                                    .storage
                                                    .from('dossiers')
                                                    .getPublicUrl(filePath);

                                                setState(() {
                                                  piecesJointes[index] = {
                                                    ...piece,
                                                    'fichier': fileUrl,
                                                    'filename':
                                                        result
                                                            .files
                                                            .single
                                                            .name,
                                                  };
                                                });
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Erreur lors du téléchargement du fichier',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  else
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final result =
                                            await FilePicker.platform
                                                .pickFiles();
                                        if (result != null &&
                                            result.files.single.path != null) {
                                          try {
                                            final file = File(
                                              result.files.single.path!,
                                            );
                                            final fileExt =
                                                result.files.single.name
                                                    .split('.')
                                                    .last;
                                            final fileName =
                                                '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
                                            final filePath =
                                                'pieces_jointes/$fileName';

                                            await Supabase
                                                .instance
                                                .client
                                                .storage
                                                .from('dossiers')
                                                .uploadBinary(
                                                  filePath,
                                                  await file.readAsBytes(),
                                                  fileOptions: FileOptions(
                                                    contentType:
                                                        'application/octet-stream',
                                                  ),
                                                );

                                            final fileUrl = Supabase
                                                .instance
                                                .client
                                                .storage
                                                .from('dossiers')
                                                .getPublicUrl(filePath);

                                            setState(() {
                                              piecesJointes[index] = {
                                                ...piece,
                                                'fichier': fileUrl,
                                                'filename':
                                                    result.files.single.name,
                                              };
                                            });
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Erreur lors du téléchargement du fichier',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: Icon(Icons.upload_file),
                                      label: Text('Ajouter un fichier'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // Mettre à jour les données dans Supabase
                          await Supabase.instance.client
                              .from('dossiers')
                              .update({
                                'nom': nomController.text,
                                'prenom': prenomController.text,
                                'cin': cinController.text,
                                'som': somController.text,
                                'etablissement': etablissementController.text,
                                'statut': statutController.text,
                                'pieces': piecesJointes,
                              })
                              .eq('id', dossier['id']);

                          // Mettre à jour la liste locale
                          setState(() {
                            final index = dossiers.indexWhere(
                              (d) => d['id'] == dossier['id'],
                            );
                            if (index != -1) {
                              dossiers[index] = {
                                ...dossiers[index],
                                'nom': nomController.text,
                                'prenom': prenomController.text,
                                'cin': cinController.text,
                                'som': somController.text,
                                'etablissement': etablissementController.text,
                                'statut': statutController.text,
                                'pieces': piecesJointes,
                              };
                            }
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dossier modifié avec succès'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erreur lors de la modification du dossier: $e',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Enregistrer'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _supprimerDossier(Map<String, dynamic> dossier) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmer la suppression'),
            content: Text('Êtes-vous sûr de vouloir supprimer ce dossier ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client
            .from('dossiers')
            .delete()
            .eq('id', dossier['id']);

        setState(() {
          dossiers.removeWhere((d) => d['id'] == dossier['id']);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Dossier supprimé avec succès')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression du dossier')),
        );
      }
    }
  }

  Future<void> _viewDocument(String? url, BuildContext context) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Aucun fichier joint')));
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir le document')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ouverture du document')),
      );
    }
  }
}
