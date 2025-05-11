import 'package:app_st/ajouter_dossier_screen.dart';
import 'package:app_st/liste_dossiers_screen.dart';
import 'package:flutter/material.dart';

class ViceDoyenProfileScreen extends StatelessWidget {
  final String nom = "Dr. Rachid El Ayachi";
  final String email = "vice.doyen@fstbm.ac.ma";
  final String telephone = "+212 6 12 34 56 78";
  final String poste = "Vice-Doyen chargé de la recherche";

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF6C4AB6);
    final gradientColors = [Color(0xFFE0D5F7), Color(0xFFD3E5FA)];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profil Vice-Doyen",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                currentAccountPicture: const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage("assets/images/vice_doyen.jpg"),
                ),
                accountName: Text(
                  nom,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(poste, style: const TextStyle(fontSize: 14)),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("Ajouter un Dossier d'Habilitation"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AjouterDossierScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text("Liste des Dossiers"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListeDossiersScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text("Voir les soutenances"),
                onTap: () {
                  Navigator.pushNamed(context, '/liste-soutenances');
                },
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text("Ajouter une Soutenance"),
                onTap: () {
                  Navigator.pushNamed(context, '/fs');
                },
              ),
            ],
          ),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/images/vice_doyen.jpg"),
              ),
              const SizedBox(height: 15),
              Text(
                nom,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                poste,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.1),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.email, color: primaryColor),
                          title: Text(
                            "Email",
                            style: TextStyle(color: primaryColor),
                          ),
                          subtitle: Text(email),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.phone, color: primaryColor),
                          title: Text(
                            "Téléphone",
                            style: TextStyle(color: primaryColor),
                          ),
                          subtitle: Text(telephone),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    "Ajouter un Dossier d'Habilitation",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AjouterDossierScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
