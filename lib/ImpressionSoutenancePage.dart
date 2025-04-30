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
                        builder: (_) => AvisSoutenancePdfPage(soutenance: soutenance),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvitationJuryPdfPage(soutenance: soutenance),
                      ),
                    );
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

  Widget _buildStyledButton(BuildContext context,
      {required String text, required VoidCallback onTap, required IconData icon}) {
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
