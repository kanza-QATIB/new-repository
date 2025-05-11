import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dossier_details_screen.dart';

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
                  ElevatedButton.icon(
                    onPressed: () => _showDossierDetails(dossier),
                    icon: Icon(Icons.visibility, size: 18),
                    label: Text("Voir détails"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
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
}
