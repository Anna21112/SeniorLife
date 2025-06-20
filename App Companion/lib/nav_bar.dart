import 'package:flutter/material.dart';
import 'menu_gerenciamento.dart';

class DadosDependenteScreen extends StatelessWidget {
  const DadosDependenteScreen({super.key});

  // Variáveis movidas para dentro do build ou mantidas como final na classe
  final double iconSize1 = 28.0;
  final double iconSize2 = 32.0;
  final double iconSize3 = 26.0;

  // O método build é OBRIGATÓRIO para todo StatelessWidget/StatefulWidget
  @override
  Widget build(BuildContext context) {
    // A estrutura da tela deve ser um Scaffold
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados do Dependente'),
        backgroundColor: const Color(0xFF2CA6C9), // Opcional: para combinar com a barra inferior
      ),
      body: const Center(
        // Aqui vai o conteúdo principal da sua tela
        child: Text('Informações do dependente aqui.'),
      ),

      // A bottomNavigationBar entra AQUI, como um parâmetro do Scaffold
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF2CA6C9), // Azul inferior
        child: Row(
          // Distribui os ícones igualmente ao longo da barra
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // ÍCONE 1
            _buildIconWithMenu(
              context: context,
              imagePath: 'assets/config.png',
              size: iconSize1,
              // Adicione um onTap se necessário
            ),

            // ÍCONE 2: Imagem com menu flutuante
            _buildIconWithMenu(
              context: context,
              imagePath: 'assets/old_man_smiling.png',
              size: iconSize2,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: MenuGerenciamento(),
                  ),
                );
              },
            ),

            // ÍCONE 3: Ícone padrão que navega para outra tela
            _buildNavigationIcon(
              icon: Icons.calendar_today,
              size: iconSize3,
              iconColor: Colors.white,
              onPressed: () {
                // Ação de clique para o terceiro ícone
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navegando para o calendário')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir o ícone com menu (GestureDetector)
  Widget _buildIconWithMenu({
    required BuildContext context,
    required String imagePath,
    required double size,
    VoidCallback? onTap, // Adicione este parâmetro opcional
  }) {
    return GestureDetector(
      onTap: onTap, // Executa a função passada ao clicar
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
        ),
      ),
    );
  }

  // Função para construir o ícone de navegação (IconButton)
  Widget _buildNavigationIcon({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return IconButton(
      icon: Icon(icon, color: iconColor), // A cor é aplicada aqui
      iconSize: size,
      tooltip: "Ir para o calendário",
      onPressed: onPressed,
    );
  }
}