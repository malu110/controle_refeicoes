import 'package:flutter/material.dart';
import '../data/dados.dart';
import '../models/refeicao.dart';
import 'tela_detalhe_refeicao.dart';

class TelaDashboard extends StatelessWidget {
  const TelaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final todayMeals = Dados.meals
        .where((m) => m.dateTime.day == DateTime.now().day)
        .toList();

    final totalCalories =
        todayMeals.fold(0, (sum, m) => sum + m.calories);
    final totalProteins =
        todayMeals.fold(0.0, (sum, m) => sum + m.proteins);
    final goalCalories = Dados.dailyGoals['calories']!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F1),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF2D6A4F),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bom dia! 👋',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Seu painel nutricional',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card de calorias do dia
                  _CalorieSummaryCard(
                    consumed: totalCalories,
                    goal: goalCalories,
                    proteins: totalProteins,
                  ),
                  const SizedBox(height: 20),

                  // Cards de macros
                  Row(
                    children: [
                      _MacroCard(
                        label: 'Proteínas',
                        value: totalProteins.toStringAsFixed(0),
                        unit: 'g',
                        color: const Color(0xFF4CAF50),
                        emoji: '💪',
                      ),
                      const SizedBox(width: 12),
                      _MacroCard(
                        label: 'Carboidratos',
                        value: todayMeals
                            .fold(0.0, (s, m) => s + m.carbs)
                            .toStringAsFixed(0),
                        unit: 'g',
                        color: const Color(0xFFFF9800),
                        emoji: '🌾',
                      ),
                      const SizedBox(width: 12),
                      _MacroCard(
                        label: 'Gorduras',
                        value: todayMeals
                            .fold(0.0, (s, m) => s + m.fats)
                            .toStringAsFixed(0),
                        unit: 'g',
                        color: const Color(0xFFE91E63),
                        emoji: '🫙',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progresso semanal
                  _WeeklyProgressCard(),
                  const SizedBox(height: 20),

                  // Refeições de hoje
                  const Text(
                    'Refeições de Hoje',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ListView.builder das refeições do dia
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: todayMeals.isEmpty
                ? const SliverToBoxAdapter(
                    child: _EmptyMealsCard(),
                  )
                : SliverList.builder(
                    itemCount: todayMeals.length,
                    itemBuilder: (context, index) {
                      final meal = todayMeals[index];
                      return _MealTile(refeicao: meal);
                    },
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _CalorieSummaryCard extends StatelessWidget {
  final int consumed;
  final int goal;
  final double proteins;

  const _CalorieSummaryCard({
    required this.consumed,
    required this.goal,
    required this.proteins,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (consumed / goal).clamp(0.0, 1.0);
    final remaining = goal - consumed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🔥', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Calorias Hoje',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$consumed',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D6A4F),
                    ),
                  ),
                  const Text(
                    'consumidas',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${remaining > 0 ? remaining : 0}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: remaining > 0 ? Colors.orange : Colors.red,
                    ),
                  ),
                  Text(
                    remaining > 0 ? 'restantes' : 'excedidas',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFE8F5E9),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 1.0 ? Colors.red : const Color(0xFF2D6A4F),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Meta: $goal kcal',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final String emoji;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              '$value$unit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = Dados.weeklyProgress;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progresso Semanal 📊',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.map((d) {
                final ratio =
                    (d['calories'] as int) / (d['goal'] as int);
                final isToday = d['day'] == _todayLabel();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: (60 * ratio).clamp(10.0, 60.0),
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFF2D6A4F)
                            : const Color(0xFF74C69D),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d['day'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isToday
                            ? const Color(0xFF2D6A4F)
                            : Colors.grey,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _todayLabel() {
    const labels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return labels[DateTime.now().weekday % 7];
  }
}

class _MealTile extends StatelessWidget {
  final Refeicao refeicao;

  const _MealTile({required this.refeicao});

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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  refeicao.imageEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    refeicao.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    refeicao.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF52B788),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    refeicao.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${refeicao.calories}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2D6A4F),
                  ),
                ),
                const Text(
                  'kcal',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMealsCard extends StatelessWidget {
  const _EmptyMealsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Text('🍽️', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text(
            'Nenhuma refeição hoje',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Toque em Adicionar para registrar sua primeira refeição',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}