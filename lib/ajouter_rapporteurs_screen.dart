import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            selectedRapporteurs.removeAt(index);
                          });
                        },
                      ),
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
