import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../soutenance.dart';
import 'fs.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show Supabase, PostgrestException;
import 'package:google_fonts/google_fonts.dart';

class ListeSoutenances extends StatefulWidget {
  @override
  _ListeSoutenancesState createState() => _ListeSoutenancesState();
}

class _ListeSoutenancesState extends State<ListeSoutenances> {
  List<Soutenance> soutenances = [];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepte':
        return Colors.green;
      case 'refuse':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    String statusText;
    switch (status) {
      case 'accepte':
        statusText = 'Accepté';
        break;
      case 'refuse':
        statusText = 'Refusé';
        break;
      default:
        statusText = 'En attente';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

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
      builder:
          (context) => AlertDialog(
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

    try {
      final response =
          await Supabase.instance.client
              .from('soutenance')
              .delete()
              .eq('id', s.id)
              .execute();

      print('Supabase Delete Response: $response');
      print('Supabase Delete Response Data: ${response.data}');

      if (response.status != 204) {
        throw Exception(
          'Opération de suppression échouée. Statut: ${response.status}',
        );
      } else {
        setState(() {
          soutenances.removeWhere((x) => x.id == s.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Soutenance supprimée avec succès')),
        );
        await chargerSoutenances();
      }
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        print('Erreur de suppression: ${e.message}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erreur de suppression: $e');
      }
    }
  }

  void setStatut(Soutenance s, String status) async {
    try {
      final response =
          await Supabase.instance.client
              .from('soutenance')
              .update({'statut': status})
              .eq('id', s.id)
              .execute();

      if (response.status != 200 && response.status != 204) {
        throw Exception(
          'Opération de mise à jour du statut échouée. Statut: ${response.status}',
        );
      } else {
        setState(() {
          s.statut = status;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Statut changé en ${status == 'accepte' ? 'Accepté' : 'Refusé'}',
            ),
            backgroundColor: _getStatusColor(status),
          ),
        );

        if (kDebugMode) {
          print('Mise à jour réussie: ${response.data}');
        }
        await chargerSoutenances();
      }
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        print('Erreur de mise à jour du statut: ${e.message}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la mise à jour du statut: ${e.message}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erreur de mise à jour du statut: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du statut'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> chargerSoutenances() async {
    try {
      final response =
          await Supabase.instance.client.from('soutenance').select().execute();

      if (response.status != 200) {
        throw Exception(
          'Opération de chargement des soutenances échouée. Statut: ${response.status}',
        );
      }

      final data = response.data as List<dynamic>;

      setState(() {
        soutenances = data.map((row) => Soutenance.fromMap(row)).toList();
      });
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        print('Erreur de chargement: ${e.message}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du chargement des soutenances: ${e.message}',
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erreur de chargement: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du chargement des soutenances: ${e.toString()}',
          ),
        ),
      );
    }
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
                final now = DateTime.now();
                final isPast = s.dateSoutenance.isBefore(now);
                final status = s.statut ?? 'en_attente';
                final formattedDate =
                    "${s.dateSoutenance.day.toString().padLeft(2, '0')}-${s.dateSoutenance.month.toString().padLeft(2, '0')}-${s.dateSoutenance.year}";

                Widget badge;
                if (!isPast) {
                  badge = _buildStatusBadge('en_attente');
                } else {
                  badge = _buildStatusBadge(status);
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
                                    if (value == 'edit') {
                                      ajouterOuModifier(s);
                                    }
                                    if (value == 'delete') {
                                      supprimerSoutenance(s);
                                    }
                                    if (value == 'accepte') {
                                      setStatut(s, 'accepte');
                                    }
                                    if (value == 'refuse') {
                                      setStatut(s, 'refuse');
                                    }
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
}
