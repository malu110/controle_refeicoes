import 'package:flutter/material.dart';
import '../data/dados.dart';
import '../models/refeicao.dart';
import 'tela_detalhe_refeicao.dart';

class TelaListaRefeicoes extends StatefulWidget {
  const TelaListaRefeicoes({super.key});

  @override
  State<TelaListaRefeicoes> createState() => _TelaListaRefeicoesState();
}

class _TelaListaRefeicoesState extends State<TelaListaRefeicoes>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = [
    'Todas',
    'Café da Manhã',
    'Almoço',
    'Lanche',
    'Jantar',
  ];
  int _selectedCategory = 0;

  List<Refeicao> get _filteredMeals {
    if (_selectedCategory == 0) return Dados.meals;
    final cat = _categories[_selectedCategory];
    return Dados.meals.where((m) => m.category == cat).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedCategory = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F1),
      appBar: AppBar(
        title: const Text(
          'Minhas Refeições',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: _categories
              .map((c) => Tab(text: c))
              .toList(),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredMeals.length} refeição(ões) encontrada(s)',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Total: ${_filteredMeals.fold(0, (s, m) => s + m.calories)} kcal',
                  style: const TextStyle(
                    color: Color(0xFF2D6A4F),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _filteredMeals.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🍽️', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          'Nenhuma refeição nessa categoria',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: _filteredMeals.length,
                    itemBuilder: (context, index) {
                      final meal = _filteredMeals[index];
                      return _MealCard(refeicao: meal);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Refeicao refeicao;

  const _MealCard({super.key, required this.refeicao});

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TelaDetalheRefeicao(refeicao: refeicao),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header colorido
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2D6A4F).withOpacity(0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Text(refeicao.imageEmoji,
                      style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          refeicao.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1B4332),
                          ),
                        ),
                        Text(
                          '${refeicao.category} · ${_formatTime(refeicao.dateTime)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF52B788),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D6A4F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${refeicao.calories} kcal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Macros row
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroInfo(
                      label: 'Proteínas',
                      value: '${refeicao.proteins.toStringAsFixed(1)}g',
                      color: const Color(0xFF4CAF50)),
                  _MacroInfo(
                      label: 'Carboidratos',
                      value: '${refeicao.carbs.toStringAsFixed(1)}g',
                      color: const Color(0xFFFF9800)),
                  _MacroInfo(
                      label: 'Gorduras',
                      value: '${refeicao.fats.toStringAsFixed(1)}g',
                      color: const Color(0xFFE91E63)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}