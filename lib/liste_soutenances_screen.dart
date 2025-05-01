import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../soutenance.dart';
import 'fs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListeSoutenances extends StatefulWidget {
  @override
  _ListeSoutenancesState createState() => _ListeSoutenancesState();
}
 
class _ListeSoutenancesState extends State<ListeSoutenances> {
  List<Soutenance> soutenances = [];

  void ajouterOuModifier(Soutenance? s) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormulaireSoutenance(soutenance: s)),
    );
    if (result != null) {
      setState(() {
        if (s != null) {
          final index = soutenances.indexWhere((x) => x.id == s.id);
          if (index != -1) {
            soutenances[index] = result;
          }
        } else {
          soutenances.add(result);
        }
      });
    }
  }

  void supprimerSoutenance(Soutenance s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmation"),
        content: Text("Voulez-vous vraiment supprimer cette soutenance ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await Supabase.instance.client
        .from('soutenance')
        .delete()
        .eq('id', s.id)
        .execute();

    if (response.data != null) {
      setState(() {
        soutenances.removeWhere((x) => x.id == s.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Soutenance supprimée avec succès')),
      );
    } else {
      if (kDebugMode) {
        print('Erreur de suppression: ${response.error?.message}');
      }
    }
  }

  void setStatut(Soutenance s, String status) async {
    final response = await Supabase.instance.client
        .from('soutenance')
        .update({'statut': status})
        .eq('id', s.id)
        .execute();

    if (response.data != null) {
      setState(() {
        s.statut = status;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Statut changé en ${status == 'accepte' ? 'Accepté' : 'Refusé'}',
          ),
        ),
      );
    } else {
      print("Erreur de mise à jour du statut: ${response.error?.message}");
    }
  }

  Future<void> chargerSoutenances() async {
    final response =
        await Supabase.instance.client.from('soutenance').select().execute();

    if (response.data != null) {
      final data = response.data as List<dynamic>;
      setState(() {
        soutenances = data.map((row) => Soutenance.fromMap(row)).toList();
      });
    } else {
      print("Erreur de chargement: ${response.error?.message}");
    }
  }

  @override
  void initState() {
    super.initState();
    chargerSoutenances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F5FA),
      appBar: AppBar(
        title: Text("Soutenances"),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: soutenances.length,
        itemBuilder: (context, index) {
          final s = soutenances[index];
          final now = DateTime.now();
          final isPast = s.dateSoutenance.isBefore(now);
          final status = s.statut;
          final formattedDate =
              "${s.dateSoutenance.day.toString().padLeft(2, '0')}-${s.dateSoutenance.month.toString().padLeft(2, '0')}-${s.dateSoutenance.year}";

          Widget badge;
          if (!isPast) {
            badge = _buildBadge("⏳ Pas encore passé", Colors.orange);
          } else if (status == "accepte") {
            badge = _buildBadge("✔ Accepté", Colors.green);
          } else if (status == "refuse") {
            badge = _buildBadge("❌ Refusé", Colors.red);
          } else {
            badge = _buildBadge("🕓 En attente", Colors.grey);
          }

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.nomProfesseur,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "${s.lieuSoutenance} — 📅 $formattedDate",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      badge,
                      PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') ajouterOuModifier(s);
                          if (value == 'delete') supprimerSoutenance(s);
                          if (value == 'accepte') setStatut(s, 'accepte');
                          if (value == 'refuse') setStatut(s, 'refuse');
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text("Modifier"),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text("Supprimer"),
                          ),
                          PopupMenuItem(
                            value: 'accepte',
                            child: Text("Accepter"),
                          ),
                          PopupMenuItem(
                            value: 'refuse',
                            child: Text("Refuser"),
                          ),
                        ],
                        icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
        onPressed: () => ajouterOuModifier(null),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 13,
        ),
      ),
    );
  }
}

extension on PostgrestResponse {
  get error => null;
}
