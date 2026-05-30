import 'package:flutter/material.dart';

import '../controllers/refeicao_controller.dart';
import 'tela_adicionar_refeicao.dart';
import 'tela_catalogo_comida.dart';
import 'tela_dashboard.dart';
import 'tela_lista_refeicoes.dart';
import 'tela_perfil.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final PageController _pageController = PageController();

  late final RefeicaoController _refeicaoController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _refeicaoController = RefeicaoController();
    _refeicaoController.carregarRefeicoes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _refeicaoController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  void _voltarParaDashboard() {
    if (!mounted) return;
    _onNavTap(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          TelaDashboard(
            controller: _refeicaoController,
            onAbrirLista: () => _onNavTap(1),
          ),
          TelaListaRefeicoes(
            controller: _refeicaoController,
            onRefeicaoSalva: _voltarParaDashboard,
          ),
          const TelaCatalogoComida(),
          const TelaPerfil(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2D6A4F),
        onPressed: () async {
          final salvou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TelaAdicionarRefeicao(controller: _refeicaoController),
            ),
          );

          if (salvou == true) {
            _voltarParaDashboard();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _currentIndex == 0
                    ? const Color(0xFF2D6A4F)
                    : Colors.grey,
              ),
              onPressed: () => _onNavTap(0),
            ),
            IconButton(
              icon: Icon(
                Icons.list,
                color: _currentIndex == 1
                    ? const Color(0xFF2D6A4F)
                    : Colors.grey,
              ),
              onPressed: () => _onNavTap(1),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(
                Icons.book,
                color: _currentIndex == 2
                    ? const Color(0xFF2D6A4F)
                    : Colors.grey,
              ),
              onPressed: () => _onNavTap(2),
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: _currentIndex == 3
                    ? const Color(0xFF2D6A4F)
                    : Colors.grey,
              ),
              onPressed: () => _onNavTap(3),
            ),
          ],
        ),
      ),
    );
  }
}
