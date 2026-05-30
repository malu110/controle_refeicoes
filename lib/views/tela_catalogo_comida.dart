import 'package:flutter/material.dart';

import '../models/comida.dart';

class TelaCatalogoComida extends StatefulWidget {
  const TelaCatalogoComida({super.key});

  @override
  State<TelaCatalogoComida> createState() => _TelaCatalogoComidaState();
}

class _TelaCatalogoComidaState extends State<TelaCatalogoComida> {
  static final List<Comida> _foodItems = [
    Comida(
      id: '1',
      name: 'Arroz',
      caloriesPer100g: 130,
      proteinsPer100g: 2.7,
      carbsPer100g: 28,
      fatsPer100g: 0.3,
      emoji: 'A',
      category: 'Carboidratos',
    ),
    Comida(
      id: '2',
      name: 'Frango',
      caloriesPer100g: 165,
      proteinsPer100g: 31,
      carbsPer100g: 0,
      fatsPer100g: 3.6,
      emoji: 'F',
      category: 'Proteinas',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'Todos',
    'Proteinas',
    'Carboidratos',
    'Frutas',
    'Vegetais',
    'Laticinios',
  ];

  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  List<Comida> get _filteredItems {
    return _foodItems.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == 'Todos' || item.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F1),
      appBar: AppBar(
        title: const Text(
          'Catalogo de Alimentos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF2D6A4F),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar alimento...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white60),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${_filteredItems.length} alimento(s)',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'Nenhum alimento encontrado',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _FoodItemCard(item: item);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final Comida item;

  const _FoodItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE8F5E9),
              child: Text(item.emoji),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF52B788),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _NutriBadge(
                        label: 'P: ${item.proteinsPer100g}g',
                        color: const Color(0xFF4CAF50),
                      ),
                      _NutriBadge(
                        label: 'C: ${item.carbsPer100g}g',
                        color: const Color(0xFFFF9800),
                      ),
                      _NutriBadge(
                        label: 'G: ${item.fatsPer100g}g',
                        color: const Color(0xFFE91E63),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.caloriesPer100g}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF2D6A4F),
                  ),
                ),
                const Text(
                  'kcal/100g',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutriBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _NutriBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        fontSize: 10,
        color: color,
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide.none,
    );
  }
}
