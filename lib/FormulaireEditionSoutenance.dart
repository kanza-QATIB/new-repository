import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../soutenance.dart';

class FormulaireEditionSoutenance extends StatefulWidget {
  final Soutenance soutenance;

  const FormulaireEditionSoutenance({required this.soutenance, super.key});

  @override
  State<FormulaireEditionSoutenance> createState() => _FormulaireEditionSoutenanceState();
}

class _FormulaireEditionSoutenanceState extends State<FormulaireEditionSoutenance> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _lieuController;
  late TextEditingController _jury1Controller;
  late TextEditingController _jury2Controller;
  late TextEditingController _jury3Controller;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.soutenance.nomProfesseur);
    _lieuController = TextEditingController(text: widget.soutenance.lieuSoutenance);
    _jury1Controller = TextEditingController(text: widget.soutenance.jury1);
    _jury2Controller = TextEditingController(text: widget.soutenance.jury2);
    _jury3Controller = TextEditingController(text: widget.soutenance.jury3);
    _date = widget.soutenance.dateSoutenance;
  }

  Future<void> _enregistrerModifications() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedSoutenance = {
      'nomProfesseur': _nomController.text,
      'lieuSoutenance': _lieuController.text,
      'jury1': _jury1Controller.text,
      'jury2': _jury2Controller.text,
      'jury3': _jury3Controller.text,
      'dateSoutenance': _date.toIso8601String(),
    };

    final response = await Supabase.instance.client
        .from('soutenance')
        .update(updatedSoutenance)
        .eq('id', widget.soutenance.id)
        .execute();

    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${response.error!.message}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Soutenance modifiée avec succès')),
      );
      Navigator.pop(context, Soutenance.fromMap({
        ...updatedSoutenance,
        'id': widget.soutenance.id,
        'statut': widget.soutenance.statut,
      }));
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _date = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier la soutenance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nomController, decoration: InputDecoration(labelText: 'Professeur')),
              TextFormField(controller: _lieuController, decoration: InputDecoration(labelText: 'Lieu')),
              TextFormField(controller: _jury1Controller, decoration: InputDecoration(labelText: 'Membre jury 1')),
              TextFormField(controller: _jury2Controller, decoration: InputDecoration(labelText: 'Membre jury 2')),
              TextFormField(controller: _jury3Controller, decoration: InputDecoration(labelText: 'Membre jury 3')),
              SizedBox(height: 10),
              ListTile(
                title: Text('Date: ${_date.day}/${_date.month}/${_date.year}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enregistrerModifications,
                child: Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on PostgrestResponse {
  get error => null;
}
