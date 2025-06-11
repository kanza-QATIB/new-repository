import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dossier_details_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'ajouter_rapporteurs_screen.dart';
import 'email_service.dart';

class ListeDossiersScreen extends StatefulWidget {
  @override
  _ListeDossiersScreenState createState() => _ListeDossiersScreenState();
}

class _ListeDossiersScreenState extends State<ListeDossiersScreen> {
  final primaryColor = Color(0xFF6C4AB6);
  final gradientColors = [Color(0xFFE0D5F7), Color(0xFFD3E5FA)];
  List<Map<String, dynamic>> dossiers = [];
  List<Map<String, dynamic>> filteredDossiers = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedStatus = 'Tous';
  final List<String> statusOptions = [
    'Tous',
    'En attente',
    'Accepté',
    'Refusé',
  ];

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

  void _filterDossiers() {
    setState(() {
      if (selectedStatus == 'Tous') {
        filteredDossiers = List.from(dossiers);
      } else {
        filteredDossiers =
            dossiers
                .where((dossier) => dossier['statut'] == selectedStatus)
                .toList();
      }
    });
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
          _filterDossiers();
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: selectedStatus,
              dropdownColor: primaryColor,
              underline: SizedBox(),
              style: TextStyle(color: Colors.white),
              items:
                  statusOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue!;
                  _filterDossiers();
                });
              },
            ),
          ),
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
                    itemCount: filteredDossiers.length,
                    itemBuilder: (context, index) {
                      final dossier = filteredDossiers[index];
                      return _buildDossierCard(dossier);
                    },
                  ),
                ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepté':
        return Colors.green;
      case 'Refusé':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _updateDossierStatus(
    Map<String, dynamic> dossier,
    String newStatus,
  ) async {
    try {
      await Supabase.instance.client
          .from('dossiers')
          .update({'statut': newStatus})
          .eq('id', dossier['id']);

      setState(() {
        final index = dossiers.indexWhere((d) => d['id'] == dossier['id']);
        if (index != -1) {
          dossiers[index]['statut'] = newStatus;
          _filterDossiers();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut mis à jour avec succès'),
          backgroundColor: _getStatusColor(newStatus),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du statut'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
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
                  _buildStatusBadge(dossier['statut'] ?? 'En attente'),
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
                        case 'voir_rapporteurs':
                          _showRapporteursDialog(dossier);
                          break;
                        case 'envoyer_aux_rapporteurs':
                          _envoyerAuxRapporteurs(dossier);
                          break;
                        case 'modifier':
                          _modifierDossier(dossier);
                          break;
                        case 'ajouter_rapporteurs':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AjouterRapporteursScreen(
                                    dossier: dossier,
                                  ),
                            ),
                          );
                          break;
                        case 'accepter':
                          _updateDossierStatus(dossier, 'Accepté');
                          break;
                        case 'refuser':
                          _updateDossierStatus(dossier, 'Refusé');
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
                            value: 'voir_rapporteurs',
                            child: Row(
                              children: [
                                Icon(Icons.people, color: primaryColor),
                                SizedBox(width: 8),
                                Text('Voir Rapporteurs'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'envoyer_aux_rapporteurs',
                            child: Row(
                              children: [
                                Icon(Icons.send, color: primaryColor),
                                SizedBox(width: 8),
                                Text('Envoyer aux Rapporteurs'),
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
                            value: 'ajouter_rapporteurs',
                            child: Row(
                              children: [
                                Icon(Icons.person_add, color: primaryColor),
                                SizedBox(width: 8),
                                Text('Ajouter des Rapporteurs'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'accepter',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Accepter'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'refuser',
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Refuser'),
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

  Future<void> _pickFile(
    int index,
    Map<String, dynamic> piece,
    StateSetter setState,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions:
          index == 0 ? ['jpg', 'jpeg', 'png'] : ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      final fileExt = file.extension?.toLowerCase() ?? '';
      final isAllowed =
          index == 0
              ? ['jpg', 'jpeg', 'png'].contains(fileExt)
              : ['jpg', 'jpeg', 'png', 'pdf'].contains(fileExt);

      if (!isAllowed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              index == 0
                  ? 'Seuls les fichiers images (JPG, PNG) sont autorisés pour la photo professionnelle.'
                  : 'Seuls les fichiers PDF ou images sont autorisés.',
            ),
          ),
        );
        return;
      }

      try {
        final storageFileName =
            '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final storagePath = 'pieces-jointes/$storageFileName';

        // Supprimer l'ancien fichier si existe
        if (piece['fichier'] != null &&
            piece['fichier'].toString().isNotEmpty) {
          final oldPath = piece['fichier'].toString().split('/').last;
          await Supabase.instance.client.storage.from('dossiers').remove([
            'pieces-jointes/$oldPath',
          ]);
        }

        await Supabase.instance.client.storage
            .from('dossiers')
            .uploadBinary(
              storagePath,
              file.bytes!,
              fileOptions: FileOptions(contentType: _getMimeType(fileExt)),
            );

        final fileUrl = Supabase.instance.client.storage
            .from('dossiers')
            .getPublicUrl(storagePath);

        setState(() {
          piece['fichier'] = fileUrl;
          piece['filename'] = file.name;
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

  Widget _buildFilePreview(String path, int index) {
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
          index == 0
              ? Icon(Icons.photo, color: primaryColor)
              : Icon(Icons.insert_drive_file, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName,
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (index ==
              0) // Afficher la prévisualisation pour la photo professionnelle
            Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
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
    String selectedStatus = dossier['statut'] ?? 'En attente';
    final List<String> statusOptions = ['En attente', 'Accepté', 'Refusé'];

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
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Statut',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items:
                              statusOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedStatus = newValue!;
                            });
                          },
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
                                        Expanded(
                                          child: _buildFilePreview(
                                            piece['fichier'],
                                            index,
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
                                          onPressed:
                                              () => _pickFile(
                                                index,
                                                piece,
                                                setState,
                                              ),
                                        ),
                                      ],
                                    )
                                  else
                                    ElevatedButton.icon(
                                      onPressed:
                                          () =>
                                              _pickFile(index, piece, setState),
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
                                'statut': selectedStatus,
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
                                'statut': selectedStatus,
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

  void _showRapporteursDialog(Map<String, dynamic> dossier) async {
    try {
      final response = await Supabase.instance.client
          .from('rapporteurs')
          .select()
          .eq('dossier_id', dossier['id']);

      if (response == null || response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucun rapporteur assigné à ce dossier')),
        );
        return;
      }

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Rapporteurs assignés'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      response.map<Widget>((rapporteur) {
                        return ListTile(
                          title: Text(
                            '${rapporteur['nom']} ${rapporteur['prenom']}',
                          ),
                          subtitle: Text(rapporteur['email'] ?? ''),
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fermer'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des rapporteurs: $e'),
        ),
      );
    }
  }

  Future<void> _envoyerAuxRapporteurs(Map<String, dynamic> dossier) async {
    try {
      await EmailService.sendEmailToRapporteurs(dossier);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email préparé pour les rapporteurs')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }
}
