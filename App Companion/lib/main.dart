import 'package:flutter/material.dart';
import 'menu_gerenciamento.dart';

void main() {
  runApp(MaterialApp(
    home: DadosDependenteScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class DadosDependenteScreen extends StatelessWidget {
  const DadosDependenteScreen({super.key});
   final double iconSize1 = 28.0;
  final double iconSize2 = 32.0;
  final double iconSize3 = 26.0;

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

  // Função para construir o ícone de navegação
  Widget _buildNavigationIcon(
      {required IconData icon, required double size, required VoidCallback onPressed, Color? iconColor}) {
    return IconButton(
      icon: Icon(icon, color: iconColor), // A cor é aplicada aqui
      iconSize: size,
      tooltip: "Ir para o calendário",
      onPressed: onPressed,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Color(0xFF2CA6C9), // Azul superior
          leading: Padding(
            padding: const EdgeInsets.all(4.0),
            child: CircleAvatar(
              minRadius: 60,
              maxRadius: 75,
              backgroundColor: Colors.white,
              child: Image.asset(
                'assets/logo.png'
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.person, size: 55, color: Colors.white),
            ),
          ],
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: Text(
                'R',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            title: Text(
              'Horacio',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ),
          Divider(thickness: 1),
          Expanded(child: Container()), // espaço em branco
        ],
      ),
  

bottomNavigationBar: BottomAppBar(
        color: Color(0xFF2CA6C9), // Azul inferior
        child: Row(
          // Distribui os ícones igualmente ao longo da barra
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildIconWithMenu(
              context: context,
              imagePath: 'assets/config.png', 
              size: iconSize1,
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
      SnackBar(content: Text('Navegando para o calendário')),
    );
  },
),
          ],
        ),
    ),
    );
  }
}
