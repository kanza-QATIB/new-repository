import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../soutenance.dart';

class FormulaireSoutenance extends StatefulWidget {
  final Soutenance? soutenance;
  const FormulaireSoutenance({this.soutenance});

  @override
  State<FormulaireSoutenance> createState() => _FormulaireSoutenanceState();
}

class _FormulaireSoutenanceState extends State<FormulaireSoutenance> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();

  String? _professeur, _email, _lieu;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    if (widget.soutenance != null) {
      _professeur = widget.soutenance!.professeur;
      _email = widget.soutenance!.email;
      _lieu = widget.soutenance!.lieu;
      _date = widget.soutenance!.date;
    }
  }

  void _enregistrer() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final soutenance = Soutenance(
        id: widget.soutenance?.id ?? _uuid.v4(),
        professeur: _professeur!,
        email: _email!,
        lieu: _lieu!,
        date: _date!,
      );
      Navigator.pop(context, soutenance);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.soutenance != null ? "Modifier" : "Ajouter")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _professeur,
                decoration: InputDecoration(labelText: "Nom du professeur"),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => _professeur = v,
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: "E-mail"),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => _email = v,
              ),
              TextFormField(
                initialValue: _lieu,
                decoration: InputDecoration(labelText: "Lieu de soutenance"),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => _lieu = v,
              ),
              ElevatedButton(
                child: Text(_date == null ? "Choisir une date" : "📅 ${_date!.day}/${_date!.month}/${_date!.year}"),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _date = date);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text("Enregistrer"),
                onPressed: _enregistrer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
