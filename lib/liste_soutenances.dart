import 'package:flutter/material.dart';
import '../soutenance.dart';
import 'fs.dart';
import '../pdf_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final primaryColor = Color(0xFF6C4AB6);
    final gradientColors = [Color(0xFFE0D5F7), Color(0xFFD3E5FA)];

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
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                Icon(Icons.school, color: primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  "Liste des soutenances",
                  style: GoogleFonts.poppins(
                    color: Color(0xFF2D3142),
                    fontSize: 18,
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
                final formattedDate =
                    "${s.dateSoutenance.day.toString().padLeft(2, '0')}-${s.dateSoutenance.month.toString().padLeft(2, '0')}-${s.dateSoutenance.year}";

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
                                    if (value == 'pdf')
                                      generateAvisSoutenancePdf(context, s);
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
                                                color: primaryColor,
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
                                          value: 'pdf',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.picture_as_pdf,
                                                size: 20,
                                                color: primaryColor,
                                              ),
                                              SizedBox(width: 8),
                                              Text("Générer PDF"),
                                            ],
                                          ),
                                        ),
                                      ],
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: primaryColor,
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
                                  color: primaryColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  s.lieuSoutenance,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: primaryColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    index % 2 == 0
                                        ? Color(0xFF66BB6A).withOpacity(0.1)
                                        : primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      index % 2 == 0
                                          ? Color(0xFF66BB6A).withOpacity(0.3)
                                          : primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                index % 2 == 0
                                    ? "✔ Terminé"
                                    : "📅 Début : $formattedDate",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      index % 2 == 0
                                          ? Color(0xFF66BB6A)
                                          : primaryColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
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
        backgroundColor: primaryColor,
        child: Icon(Icons.add),
        onPressed: () => ajouterOuModifier(null),
      ),
    );
  }
}
