import 'package:flutter/material.dart';
import '../soutenance.dart';
import 'fs.dart';
import '../pdf_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Soutenances")),
      body: ListView.builder(
        itemCount: soutenances.length,
        itemBuilder: (context, index) {
          final s = soutenances[index];
          return Card(
            child: ListTile(
              title: Text(s.professeur),
              subtitle: Text("📅 ${s.date.toLocal()} - 📍 ${s.lieu}"),
              trailing: PopupMenuButton(
                onSelected: (value) {
                  if (value == 'edit') ajouterOuModifier(s);
                  if (value == 'delete') supprimerSoutenance(s);
                  if (value == 'pdf') generateAvisSoutenancePdf(context, s);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text("Modifier")),
                  PopupMenuItem(value: 'delete', child: Text("Supprimer")),
                  PopupMenuItem(value: 'pdf', child: Text("PDF")),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => ajouterOuModifier(null),
      ),
    );
  }
}
