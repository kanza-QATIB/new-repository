import 'package:flutter/material.dart';

class ViceDoyenProfileScreen extends StatelessWidget {
  final String nom = "Dr. Rachid El Ayachi";
  final String email = "vice.doyen@fstbm.ac.ma";
  final String telephone = "+212 6 12 34 56 78";
  final String poste = "Vice-Doyen chargé de la recherche";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profil Vice-Doyen"),
        centerTitle: true,
        backgroundColor: Colors.indigo[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Photo + nom
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/images/vice_doyen.jpg"),
            ),
            const SizedBox(height: 15),
            Text(
              nom,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              poste,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),

            const SizedBox(height: 20),
            // Card infos
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text("Email"),
                      subtitle: Text(email),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text("Téléphone"),
                      subtitle: Text(telephone),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Button ajouter dossier
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
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
                  Navigator.pushNamed(context, '/ajouter-dossier');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
