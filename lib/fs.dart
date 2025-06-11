import 'package:app_st/ImpressionSoutenancePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import '../soutenance.dart';
import '../databaseservice.dart';

class FormulaireSoutenance extends StatefulWidget {
  final Soutenance? soutenance;
  const FormulaireSoutenance({this.soutenance});

  @override
  State<FormulaireSoutenance> createState() => _FormulaireSoutenanceState();
}

class _FormulaireSoutenanceState extends State<FormulaireSoutenance>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DatabaseService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? _nomProf, _lieuSoutenance, _jury1, _jury2, _jury3, _jury4;
  String? _email;
  String _etablissementJury1 = '';
  String _etablissementJury2 = '';
  String _etablissementJury3 = '';
  String _etablissementJury4 = '';
  bool _isJury1Rapporteur = true;
  bool _isJury1President = false;
  bool _isJury2Rapporteur = true;
  bool _isJury2President = false;
  bool _isJury3Rapporteur = true;
  bool _isJury3President = false;
  bool _isJury4Rapporteur = true;
  bool _isJury4President = false;
  DateTime? _dateSoutenance;
  TimeOfDay? _heureSoutenance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    if (widget.soutenance != null) {
      _nomProf = widget.soutenance!.nomProfesseur;
      _lieuSoutenance = widget.soutenance!.lieuSoutenance;
      _dateSoutenance = widget.soutenance!.dateSoutenance;
      _heureSoutenance = TimeOfDay.fromDateTime(
        widget.soutenance!.dateSoutenance,
      );
      _jury1 = widget.soutenance!.jury1;
      _jury2 = widget.soutenance!.jury2;
      _jury3 = widget.soutenance!.jury3;
      _jury4 = widget.soutenance!.jury4;
      _etablissementJury1 = widget.soutenance!.etablissementJury1;
      _etablissementJury2 = widget.soutenance!.etablissementJury2;
      _etablissementJury3 = widget.soutenance!.etablissementJury3;
      _etablissementJury4 = widget.soutenance!.etablissementJury4;
      _isJury1Rapporteur = widget.soutenance!.roleJury1.contains('Rapporteur');
      _isJury1President = widget.soutenance!.roleJury1.contains('Président');
      _isJury2Rapporteur = widget.soutenance!.roleJury2.contains('Rapporteur');
      _isJury2President = widget.soutenance!.roleJury2.contains('Président');
      _isJury3Rapporteur = widget.soutenance!.roleJury3.contains('Rapporteur');
      _isJury3President = widget.soutenance!.roleJury3.contains('Président');
      _isJury4Rapporteur = widget.soutenance!.roleJury4.contains('Rapporteur');
      _isJury4President = widget.soutenance!.roleJury4.contains('Président');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _enregistrer() async {
    if (_formKey.currentState!.validate()) {
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
        jury4: _jury4 ?? '',
        roleJury1: _getJuryRole(_isJury1Rapporteur, _isJury1President),
        roleJury2: _getJuryRole(_isJury2Rapporteur, _isJury2President),
        roleJury3: _getJuryRole(_isJury3Rapporteur, _isJury3President),
        roleJury4: _getJuryRole(_isJury4Rapporteur, _isJury4President),
        etablissementJury1: _etablissementJury1,
        etablissementJury2: _etablissementJury2,
        etablissementJury3: _etablissementJury3,
        etablissementJury4: _etablissementJury4,
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

  Future<void> _choisirDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _dateSoutenance ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.purple.shade700,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _dateSoutenance = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _getJuryRole(bool isRapporteur, bool isPresident) {
    if (isRapporteur && isPresident) return 'Président / Rapporteur';
    if (isRapporteur) return 'Rapporteur';
    if (isPresident) return 'Président';
    return ''; // Return empty string if no role is selected
  }

  Widget _buildTextField(
    String label,
    Function(String?) onSaved, {
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    IconData icon = Icons.edit,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.purple.shade300),
          ),
          prefixIcon: Icon(icon, color: Colors.purple.shade300),
        ),
        validator:
            validator ??
            (v) {
              if (v == null || v.trim().isEmpty) {
                return "Champ requis";
              }
              return null;
            },
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildJuryField({
    required String label,
    required String? initialValue,
    required Function(String?) onSaved,
    required String etablissementValue,
    required Function(String) onEtablissementChanged,
    required bool isRapporteur,
    required bool isPresident,
    required Function(bool) onRapporteurChanged,
    required Function(bool) onPresidentChanged,
    String? Function(String?)? nameValidator,
    bool isNameOptional = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            initialValue: initialValue,
            decoration: InputDecoration(
              labelText: 'Nom',
              labelStyle: TextStyle(color: Colors.grey.shade700),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple.shade300),
              ),
              prefixIcon: Icon(Icons.person, color: Colors.purple.shade300),
            ),
            validator:
                nameValidator ??
                (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Champ requis";
                  }
                  return null;
                },
            onSaved: onSaved,
          ),
          SizedBox(height: 12),
          TextFormField(
            initialValue: etablissementValue,
            decoration: InputDecoration(
              labelText: 'Établissement',
              labelStyle: TextStyle(color: Colors.grey.shade700),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple.shade300),
              ),
              prefixIcon: Icon(Icons.business, color: Colors.purple.shade300),
            ),
            onChanged: onEtablissementChanged,
            validator: (v) {
              if (!isNameOptional ||
                  (initialValue != null && initialValue.isNotEmpty)) {
                if (v == null || v.trim().isEmpty) {
                  return "Champ requis";
                }
              }
              return null;
            },
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRoleCheckbox(
                  'Rapporteur',
                  isRapporteur,
                  onRapporteurChanged,
                  Colors.purple,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildRoleCheckbox(
                  'Président',
                  isPresident,
                  onPresidentChanged,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCheckbox(
    String label,
    bool value,
    Function(bool) onChanged,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? color : Colors.grey.shade200),
      ),
      child: CheckboxListTile(
        title: Text(
          label,
          style: TextStyle(
            color: value ? color : Colors.grey.shade700,
            fontWeight: value ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        value: value,
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        activeColor: color,
        checkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FormField<DateTime>(
        initialValue: _dateSoutenance,
        validator: (value) {
          if (value == null) {
            return 'Veuillez choisir une date et une heure';
          }
          return null;
        },
        builder: (FormFieldState<DateTime> state) {
          return InkWell(
            onTap: _choisirDate,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: state.hasError ? Colors.red : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.purple.shade300),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dateSoutenance != null
                          ? '${_dateSoutenance!.day}/${_dateSoutenance!.month}/${_dateSoutenance!.year} à ${TimeOfDay.fromDateTime(_dateSoutenance!).format(context)}'
                          : 'Choisir la date et l\'heure de soutenance',
                      style: TextStyle(
                        color:
                            _dateSoutenance != null
                                ? Colors.grey.shade800
                                : Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (_dateSoutenance != null)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.purple.shade300),
                      onPressed: () {
                        setState(() {
                          _dateSoutenance = null;
                          state.didChange(null);
                        });
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.purple.shade700,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 16),
                    Text(
                      widget.soutenance == null
                          ? 'Nouvelle soutenance'
                          : 'Modifier la soutenance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            "Nom du professeur",
                            (v) => _nomProf = v,
                            initialValue: _nomProf,
                          ),
                          _buildTextField(
                            "Email",
                            (v) => _email = v,
                            initialValue: _email,
                            keyboardType: TextInputType.emailAddress,
                            icon: Icons.email,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "Champ requis";
                              }
                              final emailRegex = RegExp(r'^.+@.+\..+ ?');
                              if (!emailRegex.hasMatch(v.trim())) {
                                return "Email invalide";
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            "Lieu de soutenance",
                            (v) => _lieuSoutenance = v,
                            initialValue: _lieuSoutenance,
                          ),
                          _buildDateField(),
                          _buildJuryField(
                            label: "Membre du jury 1",
                            initialValue: _jury1,
                            onSaved: (v) => _jury1 = v,
                            etablissementValue: _etablissementJury1,
                            onEtablissementChanged:
                                (v) => setState(() => _etablissementJury1 = v),
                            isRapporteur: _isJury1Rapporteur,
                            isPresident: _isJury1President,
                            onRapporteurChanged:
                                (v) => setState(() => _isJury1Rapporteur = v),
                            onPresidentChanged:
                                (v) => setState(() => _isJury1President = v),
                          ),
                          _buildJuryField(
                            label: "Membre du jury 2",
                            initialValue: _jury2,
                            onSaved: (v) => _jury2 = v,
                            etablissementValue: _etablissementJury2,
                            onEtablissementChanged:
                                (v) => setState(() => _etablissementJury2 = v),
                            isRapporteur: _isJury2Rapporteur,
                            isPresident: _isJury2President,
                            onRapporteurChanged:
                                (v) => setState(() => _isJury2Rapporteur = v),
                            onPresidentChanged:
                                (v) => setState(() => _isJury2President = v),
                          ),
                          _buildJuryField(
                            label: "Membre du jury 3",
                            initialValue: _jury3,
                            onSaved: (v) => _jury3 = v,
                            etablissementValue: _etablissementJury3,
                            onEtablissementChanged:
                                (v) => setState(() => _etablissementJury3 = v),
                            isRapporteur: _isJury3Rapporteur,
                            isPresident: _isJury3President,
                            onRapporteurChanged:
                                (v) => setState(() => _isJury3Rapporteur = v),
                            onPresidentChanged:
                                (v) => setState(() => _isJury3President = v),
                          ),
                          _buildJuryField(
                            label: "Membre du jury 4",
                            initialValue: _jury4,
                            onSaved: (v) => _jury4 = v,
                            etablissementValue: _etablissementJury4,
                            onEtablissementChanged:
                                (v) => setState(() => _etablissementJury4 = v),
                            isRapporteur: _isJury4Rapporteur,
                            isPresident: _isJury4President,
                            onRapporteurChanged:
                                (v) => setState(() => _isJury4Rapporteur = v),
                            onPresidentChanged:
                                (v) => setState(() => _isJury4President = v),
                            nameValidator: (v) => null,
                            isNameOptional: true,
                          ),
                          SizedBox(height: 24),
                          Container(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _enregistrer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text(
                                    'Enregistrer',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
