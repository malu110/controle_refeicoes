import 'package:flutter/material.dart';
import '../models/refeicao.dart';

class TelaDetalheRefeicao extends StatelessWidget {
  final Refeicao refeicao;

  const TelaDetalheRefeicao({super.key, required this.refeicao});

  String _formatDateTime(DateTime dt) {
    final weekDays = [
      'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
    ];
    final day = weekDays[dt.weekday - 1];
    return '$day, ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F1),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF2D6A4F),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B4332), Color(0xFF52B788)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(refeicao.imageEmoji, style: const TextStyle(fontSize: 80)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoria e Data
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D6A4F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          refeicao.category,
                          style: const TextStyle(
                            color: Color(0xFF2D6A4F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatDateTime(refeicao.dateTime),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Nome do Prato
                  Text(
                    refeicao.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Descrição
                  Text(
                    refeicao.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // EXIBIÇÃO DO LOCAL (Nova Seção)
                  if (refeicao.local != null && refeicao.local!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Consumido em: ${refeicao.local}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1B4332),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // EXIBIÇÃO DA AVALIAÇÃO (Nova Seção)
                  if (refeicao.avaliacao != null)
                    Row(
                      children: [
                        const Text(
                          'Sua nota: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...List.generate(5, (index) {
                          return Icon(
                            index < (refeicao.avaliacao ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${refeicao.avaliacao}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),
                  const Text(
                    'Informações Nutricionais',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Cards Nutricionais
                  _NutriCard(
                    title: 'Calorias',
                    value: refeicao.calories.toDouble(),
                    unit: ' kcal',
                    description: 'Energia total do prato',
                    color: const Color(0xFF2D6A4F),
                    emoji: '🔥',
                  ),
                  const SizedBox(height: 12),
                  _NutriCard(
                    title: 'Proteínas',
                    value: refeicao.proteins,
                    unit: 'g',
                    description: 'Construção muscular',
                    color: const Color(0xFF4CAF50),
                    emoji: '🍗',
                  ),
                  const SizedBox(height: 12),
                  _NutriCard(
                    title: 'Carboidratos',
                    value: refeicao.carbs,
                    unit: 'g',
                    description: 'Energia rápida',
                    color: const Color(0xFFFF9800),
                    emoji: '🍚',
                  ),
                  const SizedBox(height: 12),
                  _NutriCard(
                    title: 'Gorduras',
                    value: refeicao.fats,
                    unit: 'g',
                    description: 'Saúde hormonal',
                    color: const Color(0xFFE91E63),
                    emoji: '🥑',
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutriCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final String description;
  final Color color;
  final String emoji;

  const _NutriCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1B4332),
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}