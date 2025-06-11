import 'package:flutter/material.dart';
import '../soutenance.dart';
import 'avis_soutenance_pdf.dart';
import 'invitation_jury_pdf.dart';

class ImpressionSoutenancePage extends StatelessWidget {
  final Soutenance soutenance;

  const ImpressionSoutenancePage({required this.soutenance});

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [Color.fromARGB(255, 220, 207, 247), Color(0xFFB18BD6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 80),
                SizedBox(height: 20),
                Text(
                  'Soutenance enregistrée avec succès !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                _buildStyledButton(
                  context,
                  text: "Imprimer l'avis de soutenance",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                AvisSoutenancePdfPage(soutenance: soutenance),
                      ),
                    );
                  },
                  icon: Icons.picture_as_pdf,
                ),
                SizedBox(height: 20),
                _buildStyledButton(
                  context,
                  text: "Imprimer lettre d'invitation jury",
                  onTap: () {
                    _showJurySelectionDialog(context, soutenance);
                  },
                  icon: Icons.picture_as_pdf,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showJurySelectionDialog(BuildContext context, Soutenance soutenance) {
    final List<Map<String, String?>> juryMembers = [
      if (soutenance.jury1 != null && soutenance.jury1!.isNotEmpty)
        {
          'name': soutenance.jury1,
          'role': soutenance.roleJury1,
          'etablissement': soutenance.etablissementJury1,
        },
      if (soutenance.jury2 != null && soutenance.jury2!.isNotEmpty)
        {
          'name': soutenance.jury2,
          'role': soutenance.roleJury2,
          'etablissement': soutenance.etablissementJury2,
        },
      if (soutenance.jury3 != null && soutenance.jury3!.isNotEmpty)
        {
          'name': soutenance.jury3,
          'role': soutenance.roleJury3,
          'etablissement': soutenance.etablissementJury3,
        },
      if (soutenance.jury4 != null && soutenance.jury4!.isNotEmpty)
        {
          'name': soutenance.jury4,
          'role': soutenance.roleJury4,
          'etablissement': soutenance.etablissementJury4,
        },
    ];

    if (juryMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aucun membre du jury trouvé pour cette soutenance.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Sélectionner un membre du jury'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: juryMembers.length,
              itemBuilder: (BuildContext context, int index) {
                final juryMember = juryMembers[index];
                return ListTile(
                  title: Text(juryMember['name'] ?? 'N/A'),
                  subtitle: Text(juryMember['role'] ?? 'N/A'),
                  onTap: () {
                    Navigator.pop(dialogContext); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => InvitationJuryPdfPage(
                              juryName: juryMember['name']!,
                              juryRole: juryMember['role']!,
                              juryEtablissement: juryMember['etablissement']!,
                              professorName: soutenance.nomProfesseur,
                              defenseLocation: soutenance.lieuSoutenance,
                              defenseDate: soutenance.dateSoutenance,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close the dialog
              },
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStyledButton(
    BuildContext context, {
    required String text,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 127, 105, 196),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }
}
