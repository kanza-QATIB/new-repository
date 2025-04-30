import 'package:app_st/ImpressionSoutenancePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:uuid/uuid.dart';
import '../soutenance.dart';
import '../databaseservice.dart';

class FormulaireSoutenance extends StatefulWidget {
  final Soutenance? soutenance;
  const FormulaireSoutenance({this.soutenance});

  @override
  State<FormulaireSoutenance> createState() => _FormulaireSoutenanceState();
}

class _FormulaireSoutenanceState extends State<FormulaireSoutenance> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();
  final _dbService = DatabaseService();

  String? _nomProf, _lieuSoutenance, _jury1, _jury2, _jury3, _email;
  DateTime? _dateSoutenance;

  @override
  void initState() {
    super.initState();
    if (widget.soutenance != null) {
      _nomProf = widget.soutenance!.nomProfesseur;
      _lieuSoutenance = widget.soutenance!.lieuSoutenance;
      _dateSoutenance = widget.soutenance!.dateSoutenance;
      _jury1 = widget.soutenance!.jury1;
      _jury2 = widget.soutenance!.jury2;
      _jury3 = widget.soutenance!.jury3;
      _email = widget.soutenance!.email;
    }
  }

  void _enregistrer() async {
    if (_formKey.currentState!.validate()) {
      if (_dateSoutenance == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Veuillez choisir une date')));
        return;
      }
      _formKey.currentState!.save();

      final id =
          widget.soutenance?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      final soutenance = Soutenance(
        id: id,
        nomProfesseur: _nomProf!,
        lieuSoutenance: _lieuSoutenance!,
        dateSoutenance: _dateSoutenance!,
        jury1: _jury1 ?? '',
        jury2: _jury2 ?? '',
        jury3: _jury3 ?? '',
        email: _email,
      );

      try {
        await _dbService.saveSoutenance(soutenance);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ImpressionSoutenancePage(soutenance: soutenance),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur de sauvegarde : $e')));
      }
    }
  }

  // Utilisation de flutter_datetime_picker pour choisir une date
  Future<void> _choisirDate() async {
    picker.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2024),
      maxTime: DateTime(2030),
      theme: picker.DatePickerTheme(
        backgroundColor: Colors.white,
        headerColor: Colors.purple,
        itemStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        cancelStyle: TextStyle(color: Colors.red, fontSize: 16),
        doneStyle: TextStyle(color: Colors.green, fontSize: 16),
      ),
      onConfirm: (date) {
        setState(() {
          _dateSoutenance = date;
        });
      },
      currentTime: _dateSoutenance ?? DateTime.now(),
      locale: picker.LocaleType.fr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF6C4AB6); // Violet inspiré de ton modèle

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            'Nouvelle soutenance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: primaryColor, // Violet pour le fond de la AppBar
        elevation: 4, // Ajout d'une légère ombre pour plus de style
        iconTheme: IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ), // Bords arrondis
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  "Nom du professeur",
                  (v) => _nomProf = v,
                  initialValue: _nomProf,
                ),
                _buildTextField(
                  "Lieu de soutenance",
                  (v) => _lieuSoutenance = v,
                  initialValue: _lieuSoutenance,
                ),
                _buildTextField(
                  "E-mail du professeur",
                  (v) => _email = v,
                  initialValue: _email,
                ),
                _buildTextField(
                  "Membre du jury 1",
                  (v) => _jury1 = v,
                  initialValue: _jury1,
                  required: false,
                ),
                _buildTextField(
                  "Membre du jury 2",
                  (v) => _jury2 = v,
                  initialValue: _jury2,
                  required: false,
                ),
                _buildTextField(
                  "Membre du jury 3",
                  (v) => _jury3 = v,
                  initialValue: _jury3,
                  required: false,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _choisirDate,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          _dateSoutenance == null
                              ? "Choisir la date"
                              : "${_dateSoutenance!.day}/${_dateSoutenance!.month}/${_dateSoutenance!.year}",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                _dateSoutenance == null
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _enregistrer,
                    child: Text(
                      widget.soutenance != null ? "Modifier" : "Enregistrer",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor, // Couleur du bouton
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(
                        0.3,
                      ), // Ombre autour du bouton
                      minimumSize: Size(
                        double.infinity,
                        55,
                      ), // Taille du bouton
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String?) onSaved, {
    String? initialValue,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) {
            return "Champ requis";
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }
}
