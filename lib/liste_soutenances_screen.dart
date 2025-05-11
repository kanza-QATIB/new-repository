// ignore_for_file: collection_methods_unrelated_type

import 'package:flutter/material.dart';
import '../soutenance.dart';
import 'fs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Soutenances",
          style: GoogleFonts.poppins(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF2D3142)),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF6C4AB6), size: 20),
                SizedBox(width: 8),
                Text(
                  "Liste des soutenances",
                  style: GoogleFonts.poppins(
                    color: Color(0xFF2D3142),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: soutenances.length,
              itemBuilder: (context, index) {
                final s = soutenances[index];
                final now = DateTime.now();
                final isPast = s.dateSoutenance.isBefore(now);
                final status = statusMap[s.id];
                final formattedDate =
                    "${s.dateSoutenance.day.toString().padLeft(2, '0')}-${s.dateSoutenance.month.toString().padLeft(2, '0')}-${s.dateSoutenance.year}";

                Widget badge;
                if (!isPast) {
                  badge = _buildBadge("⏳ À venir", Color(0xFFFFA726));
                } else if (status == "accepte") {
                  badge = _buildBadge("✔ Terminé", Color(0xFF66BB6A));
                } else if (status == "refuse") {
                  badge = _buildBadge("❌ Refusé", Color(0xFFEF5350));
                } else {
                  badge = _buildBadge("🕓 En attente", Color(0xFF78909C));
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => ajouterOuModifier(s),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    s.nomProfesseur,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Color(0xFF2D3142),
                                    ),
                                  ),
                                ),
                                PopupMenuButton(
                                  onSelected: (value) {
                                    if (value == 'edit') ajouterOuModifier(s);
                                    if (value == 'delete')
                                      supprimerSoutenance(s);
                                    if (value == 'accepte')
                                      setStatut(s, 'accepte');
                                    if (value == 'refuse')
                                      setStatut(s, 'refuse');
                                  },
                                  itemBuilder:
                                      (_) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: Color(0xFF6C4AB6),
                                              ),
                                              SizedBox(width: 8),
                                              Text("Modifier"),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text("Supprimer"),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'accepte',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 20,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 8),
                                              Text("Accepter"),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'refuse',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.cancel,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text("Refuser"),
                                            ],
                                          ),
                                        ),
                                      ],
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Color(0xFF6C4AB6),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Color(0xFF6C4AB6),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  s.lieuSoutenance,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Color(0xFF6C4AB6),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Color(0xFF6C4AB6),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Color(0xFF6C4AB6),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            badge,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF6C4AB6),
        child: Icon(Icons.add),
        onPressed: () => ajouterOuModifier(null),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: color,
          fontSize: 13,
        ),
      ),
    );
  }
}
