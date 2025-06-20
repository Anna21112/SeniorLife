import 'package:flutter/material.dart';
// Certifique-se de que este import aponta para o seu arquivo de menu
// import 'menu_gerenciamento.dart'; 

// --- WIDGET DA BARRA SUPERIOR (APP BAR) ---

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onProfilePressed;

  const CustomAppBar({
    Key? key,
    this.title = '',
    required this.onProfilePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2A9DB8),
      automaticallyImplyLeading: false,
      elevation: 4.0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // SUBSTITUA PELO SEU LOGOTIPO
          // Exemplo: Image.asset('assets/seu_logo.png', height: 40)
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa, // Ícone de exemplo
              color: Colors.green,
              size: 32,
            ),
          ),
          
          Text(title, style: const TextStyle(color: Colors.white)),
          
          Row(
            children: [
              Container(
                height: 30,
                width: 2,
                color: Colors.white.withOpacity(0.7),
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white, size: 35),
                onPressed: onProfilePressed,
                tooltip: 'Perfil',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


// --- WIDGET DA BARRA INFERIOR (BOTTOM NAV BAR) ---

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Definindo as variáveis de tamanho aqui dentro para melhor escopo
    const double iconSize1 = 28.0;
    const double iconSize2 = 32.0;
    const double iconSize3 = 26.0;

    return BottomAppBar(
      color: const Color(0xFF2CA6C9), // Azul inferior
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Ícone 1 (Config)
          _buildIconWithMenu(
            context: context,
            imagePath: 'assets/config.png', // Verifique se o asset existe
            size: iconSize1,
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ícone de Configurações clicado!')),
              );
            }
          ),

          // Ícone 2 (Dependente com Menu)
          _buildIconWithMenu(
            context: context,
            imagePath: 'assets/old_man_smiling.png', // Verifique se o asset existe
            size: iconSize2,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const Dialog(
                  backgroundColor: Colors.transparent,
                  // Substitua pelo seu widget de menu real
                  child: Text("Menu de Gerenciamento Aqui", style: TextStyle(color: Colors.white)),
                  // child: MenuGerenciamento(), 
                ),
              );
            },
          ),

          // Ícone 3 (Calendário)
          _buildNavigationIcon(
            icon: Icons.calendar_today,
            size: iconSize3,
            iconColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navegando para o calendário')),
              );
            },
          ),
        ],
      ),
    );
  }

  // Função para construir o ícone com menu (GestureDetector)
  Widget _buildIconWithMenu({
    required BuildContext context,
    required String imagePath,
    required double size,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            // Um fallback caso a imagem não seja encontrada
            return Icon(Icons.error, color: Colors.red[300], size: size);
          },
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
      icon: Icon(icon, color: iconColor),
      iconSize: size,
      tooltip: "Ir para o calendário",
      onPressed: onPressed,
    );
  }
}
