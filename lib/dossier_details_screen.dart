import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'email_service.dart';

class DossierDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> dossier;

  DossierDetailsScreen({required this.dossier});

  Future<void> _viewDocument(String url, BuildContext context) async {
    try {
      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Le document n\'a pas de lien valide')),
        );
        return;
      }

      // Check if the URL is a valid Supabase storage URL
      if (!url.startsWith('http')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le format du lien du document n\'est pas valide'),
          ),
        );
        return;
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impossible d\'ouvrir le document. Vérifiez votre connexion internet.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l\'ouverture du document: ${e.toString()}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF6C4AB6);
    final gradientColors = [Color(0xFFE0D5F7), Color(0xFFD3E5FA)];

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Détails du Dossier",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection("Informations Personnelles", [
                    _buildDetailItem("Nom", dossier['nom']),
                    _buildDetailItem("Prénom", dossier['prenom']),
                    _buildDetailItem("CIN", dossier['cin']),
                    _buildDetailItem("SOM", dossier['som']),
                    _buildDetailItem("Établissement", dossier['etablissement']),
                    _buildDetailItem(
                      "Statut",
                      dossier['statut'] ?? 'En attente',
                    ),
                  ]),
                  SizedBox(height: 24),
                  _buildDetailSection(
                    "Pièces Jointes",
                    (dossier['pieces'] as List).map((piece) {
                      final fileUrl = piece['fichier']?.toString() ?? '';
                      final type = piece['type']?.toString() ?? 'Document';
                      final fileName =
                          piece['filename']?.toString() ?? 'Document sans nom';

                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(Icons.attach_file, color: primaryColor),
                          title: Text(fileName),
                          subtitle: Text(type),
                          trailing: IconButton(
                            icon: Icon(Icons.visibility, color: primaryColor),
                            onPressed:
                                fileUrl.isNotEmpty
                                    ? () => _viewDocument(fileUrl, context)
                                    : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    final primaryColor = Color(0xFF6C4AB6);

    return Column(
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
        SizedBox(height: 8),
        Card(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}
