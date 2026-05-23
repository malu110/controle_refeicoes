import 'package:flutter/material.dart';
import 'tela_dashboard.dart';
import 'tela_lista_refeicoes.dart';
import 'tela_adicionar_refeicao.dart';
import 'tela_catalogo_comida.dart';
import 'tela_perfil.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: const [
          TelaDashboard(),
          TelaListaRefeicoes(),
          TelaCatalogoComida(),
          TelaPerfil(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2D6A4F),
        onPressed: () async {
          // O await espera você voltar da tela de adição
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaAdicionarRefeicao()),
          );
          // Atualiza o Dashboard e as Listas quando volta
          setState(() {}); 
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
            IconButton(icon: Icon(Icons.home, color: _currentIndex == 0 ? const Color(0xFF2D6A4F) : Colors.grey), onPressed: () => _onNavTap(0)),
            IconButton(icon: Icon(Icons.list, color: _currentIndex == 1 ? const Color(0xFF2D6A4F) : Colors.grey), onPressed: () => _onNavTap(1)),
            const SizedBox(width: 40),
            IconButton(icon: Icon(Icons.book, color: _currentIndex == 2 ? const Color(0xFF2D6A4F) : Colors.grey), onPressed: () => _onNavTap(2)),
            IconButton(icon: Icon(Icons.person, color: _currentIndex == 3 ? const Color(0xFF2D6A4F) : Colors.grey), onPressed: () => _onNavTap(3)),
          ],
        ),
      ),
    );
  }
}