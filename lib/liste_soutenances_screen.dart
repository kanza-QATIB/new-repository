// ignore_for_file: collection_methods_unrelated_type

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
  Map<int, String> statusMap = {}; // id : 'accepte' / 'refuse'

  void ajouterOuModifier(Soutenance? s) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormulaireSoutenance(soutenance: s)),
    );
    if (result != null) {
      setState(() {
        if (s != null) {
          final index = soutenances.indexWhere((x) => x.id == s.id);
          soutenances[index] = result;
        } else {
          soutenances.add(result);
        }
      });
    }
  }

  void supprimerSoutenance(Soutenance s) {
    setState(() {
      soutenances.removeWhere((x) => x.id == s.id);
      statusMap.remove(s.id);
    });
  }

  void setStatut(Soutenance s, String status) {
    setState(() {
      // ignore: collection_methods_unrelated_type
      var s2 = s;
  Map<String, String> statusMap = {};

    });
  }

  Future<void> chargerSoutenances() async {
    final response = await Supabase.instance.client.from('soutenance').select();
    final data = response as List<dynamic>;
    setState(() {
      soutenances = data.map((row) => Soutenance.fromMap(row)).toList();
    });
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
          final status = statusMap[s.id];
          final formattedDate = "${s.dateSoutenance.day.toString().padLeft(2, '0')}-${s.dateSoutenance.month.toString().padLeft(2, '0')}-${s.dateSoutenance.year}";

          // Badge dynamique
          Widget badge;
          if (!isPast) {
            badge = _buildBadge("⏳ Pas encore passé", Colors.orange);
          } else if (status == "accepte") {
            badge = _buildBadge("✔ Terminé", Colors.green);
          } else if (status == "refuse") {
            badge = _buildBadge("❌ Refusé", Colors.red);
          } else {
            badge = _buildBadge("🕓 En attente", Colors.grey);
          }

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                          PopupMenuItem(value: 'edit', child: Text("Modifier")),
                          PopupMenuItem(value: 'delete', child: Text("Supprimer")),
                          PopupMenuItem(value: 'accepte', child: Text("Accepter")),
                          PopupMenuItem(value: 'refuse', child: Text("Refuser")),
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
