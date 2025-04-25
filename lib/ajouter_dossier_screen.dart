import 'package:flutter/material.dart';

class AjouterDossierScreen extends StatefulWidget {
  @override
  _AjouterDossierScreenState createState() => _AjouterDossierScreenState();
}

class _AjouterDossierScreenState extends State<AjouterDossierScreen> {
  final _formKey = GlobalKey<FormState>();

  // Champs professeur
  String nom = '';
  String prenom = '';
  String cin = '';
  String som = '';
  String etablissement = '';

  // Champs dossier
  String statut = '';
  List<Map<String, String>> piecesJointes = [];

  void _ajouterPieceJointe() {
    setState(() {
      piecesJointes.add({"type": "", "fichier": ""});
    });
  }

  void _soumettreFormulaire() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // TODO: Enregistrer le professeur, le dossier et les pièces jointes en base

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Dossier ajouté avec succès")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un Dossier"),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Informations Professeur",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom'),
                onSaved: (value) => nom = value ?? '',
                validator:
                    (value) =>
                        value!.isEmpty ? 'Ce champ est obligatoire' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Prénom'),
                onSaved: (value) => prenom = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'CIN'),
                onSaved: (value) => cin = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'SOM'),
                onSaved: (value) => som = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Établissement'),
                onSaved: (value) => etablissement = value ?? '',
              ),
              const SizedBox(height: 20),
              const Text(
                "Informations Dossier",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Statut'),
                onSaved: (value) => statut = value ?? '',
              ),
              const SizedBox(height: 20),
              const Text(
                "Pièces Jointes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...piecesJointes.asMap().entries.map((entry) {
                int index = entry.key;
                return Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Type de pièce jointe',
                      ),
                      onChanged: (val) => piecesJointes[index]['type'] = val,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Nom du fichier'),
                      onChanged: (val) => piecesJointes[index]['fichier'] = val,
                    ),
                    const Divider(),
                  ],
                );
              }).toList(),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text("Ajouter une pièce jointe"),
                onPressed: _ajouterPieceJointe,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _soumettreFormulaire,
                child: const Text("Soumettre le Dossier"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
