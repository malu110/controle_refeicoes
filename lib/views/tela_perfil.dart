import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  // Controllers para o perfil do usuário
  final _nameController = TextEditingController(text: 'João Silva');
  final _ageController = TextEditingController(text: '28');
  final _weightController = TextEditingController(text: '75');
  final _heightController = TextEditingController(text: '178');
  final _goalCaloriesController = TextEditingController(text: '2000');
  final _goalProteinsController = TextEditingController(text: '150');

  String _selectedGender = 'Masculino';
  String _selectedGoal = 'Manter peso';
  String _selectedActivity = 'Moderado';
  bool _isEditing = false;

  final List<String> _goals = ['Perder peso', 'Manter peso', 'Ganhar massa'];
  final List<String> _activities = [
    'Sedentário',
    'Leve',
    'Moderado',
    'Intenso',
    'Muito intenso',
  ];

  double get _bmi {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = (double.tryParse(_heightController.text) ?? 0) / 100;
    if (height == 0) return 0;
    return weight / (height * height);
  }

  String get _bmiLabel {
    final bmi = _bmi;
    if (bmi < 18.5) return 'Abaixo do peso';
    if (bmi < 25) return 'Peso normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidade';
  }

  Color get _bmiColor {
    final bmi = _bmi;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return const Color(0xFF2D6A4F);
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _goalCaloriesController.dispose();
    _goalProteinsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F1),
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
              if (!_isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Perfil atualizado!'),
                    backgroundColor: const Color(0xFF2D6A4F),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D6A4F),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D6A4F).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('👤', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _nameController.text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4332),
                  ),
                ),
                Text(
                  _selectedGoal,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF52B788),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Card IMC
          _BmiCard(bmi: _bmi, label: _bmiLabel, color: _bmiColor),
          const SizedBox(height: 20),

          // Dados pessoais
          _SectionCard(
            title: 'Dados Pessoais',
            children: [
              _ProfileField(
                controller: _nameController,
                label: 'Nome',
                icon: Icons.person,
                enabled: _isEditing,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ProfileField(
                      controller: _ageController,
                      label: 'Idade',
                      icon: Icons.cake,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      suffixText: 'anos',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gênero',
                        prefixIcon: const Icon(Icons.wc),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      items: ['Masculino', 'Feminino', 'Outro']
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: _isEditing
                          ? (v) => setState(() => _selectedGender = v!)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ProfileField(
                      controller: _weightController,
                      label: 'Peso',
                      icon: Icons.monitor_weight,
                      enabled: _isEditing,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      suffixText: 'kg',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileField(
                      controller: _heightController,
                      label: 'Altura',
                      icon: Icons.height,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      suffixText: 'cm',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Objetivos
          _SectionCard(
            title: 'Objetivos',
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedGoal,
                decoration: InputDecoration(
                  labelText: 'Meta',
                  prefixIcon: const Icon(Icons.flag),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                items: _goals
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: _isEditing
                    ? (v) => setState(() => _selectedGoal = v!)
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedActivity,
                decoration: InputDecoration(
                  labelText: 'Nível de atividade',
                  prefixIcon: const Icon(Icons.directions_run),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                items: _activities
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: _isEditing
                    ? (v) => setState(() => _selectedActivity = v!)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metas nutricionais
          _SectionCard(
            title: 'Metas Diárias',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ProfileField(
                      controller: _goalCaloriesController,
                      label: 'Calorias',
                      icon: Icons.local_fire_department,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      suffixText: 'kcal',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileField(
                      controller: _goalProteinsController,
                      label: 'Proteínas',
                      icon: Icons.fitness_center,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      suffixText: 'g',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.keyboardType,
    this.suffixText,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D6A4F)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _BmiCard extends StatelessWidget {
  final double bmi;
  final String label;
  final Color color;

  const _BmiCard({required this.bmi, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Índice de Massa Corporal',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
