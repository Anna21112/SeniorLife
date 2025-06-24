import 'package:flutter/material.dart';
import '../telaPerfilAcompanhante.dart';
import '../tela_saude.dart';
import '../telaNotificações.dart';
import '../telaAgenda.dart';
import '../telaExibirPerfilDepen.dart';
import '../telaLembretes.dart';
import '../menuDependentes.dart';
import '../menuAddDependente.dart';

// Adicione os imports das futuras telas de dependentes aqui

class Dependente {
  final int id;
  final String nome;

  Dependente({required this.id, required this.nome});
}

// Barra superior reutilizável com logo e botão de usuário
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfilePressed;
  const CustomAppBar({super.key, this.onProfilePressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF31A2C6),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const TelaAdicionarDependente(),
                ),
              );
            },
            child: Image.asset('assets/imagens/logo.png', height: 40),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white, size: 30),
            onPressed: onProfilePressed ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TelaPerfilAcompanhante(),
                    ),
                  );
                },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Rodapé reutilizável com ícones e animação do menu
class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback? onProfilePressed;
  final VoidCallback? onCalendarPressed;

  const CustomBottomNavBar({
    super.key,
    this.onProfilePressed,
    this.onCalendarPressed,
  });

  @override
  Widget build(BuildContext context) {
    // =======================================================================
    // AQUI É ONDE OS DADOS VIRIÃO DA SUA API
    // =======================================================================
    // Por enquanto, usamos uma lista estática como exemplo.
    final List<Dependente> listaDeDependentes = [
      Dependente(id: 1, nome: 'Rogério Almeida'),
      Dependente(id: 2, nome: 'Clark Quente'),
      Dependente(id: 3, nome: 'Chico Moedas'),
    ];
    // =======================================================================

    return SafeArea(
      child: Container(
        height: 80,
        color: const Color(0xFF31A2C6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Botão de Configurações (Menu animado)
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                onPressed: () => _showAnimatedMenu(context),
              ),
            ),

            // BOTÃO QUE ABRE O POPUP DOS DEPENDENTES (usando ícone padrão)
            Expanded(
              child: PopupMenuButton<dynamic>(
                onSelected: (value) {
                  if (value is Dependente) {
                    // Ação ao clicar em um dependente da lista
                    print('Selecionou o dependente: ${value.nome}');
                  } else if (value == 'adicionar') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TelaCadastroDependente(),
                      ),
                    );
                    // Ação ao clicar em "Adicionar dependente"
                    print('Navegar para Adicionar Dependente');
                  } else if (value == 'editar') {
                    // Ação ao clicar em "Editar Dependentes"
                    print('Navegar para Editar Dependentes');
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    ...listaDeDependentes.map((dependente) {
                      return PopupMenuItem<Dependente>(
                        value: dependente,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 12),
                            Text(dependente.nome),
                          ],
                        ),
                      );
                    }),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'adicionar',
                      child: Row(
                        children: [
                          Text('Adicionar dependente'),
                          Spacer(),
                          Icon(Icons.add_circle, color: Colors.green),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'editar',
                      child: Row(
                        children: [
                          Text('Editar Dependentes'),
                          Spacer(),
                          Icon(Icons.edit, color: Color(0xFF31A2C6)),
                        ],
                      ),
                    ),
                  ];
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(color: Color(0xFF31A2C6), width: 1),
                ),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    'assets/imagens/icone_senhor.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Botão de calendário
            Expanded(
              child: IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReminderScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnimatedMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Configurações',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeInOut.transform(anim1.value),
          child: Opacity(
            opacity: Curves.easeInOut.transform(anim1.value),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 270,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                // ftmoon esteve aqui
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.lightBlue, width: 3),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MenuButton(
                      texto: 'Perfil do Dependente',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(thickness: 2),
                    _MenuButton(
                      texto: 'Lembretes',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TelaLembretes(),
                          ),
                        );
                      },
                    ),
                    const Divider(thickness: 2),
                    _MenuButton(
                      texto: 'Saúde',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MedicalDataScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(thickness: 2),
                    _MenuButton(
                      texto: 'Notificações',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AgendaScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }, // https://www.reddit.com/r/NoMansSkyTheGame/comments/bv69hx/gek_cat/?tl=pt-br
    );
  }
}

// Botão do menu animado
class _MenuButton extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const _MenuButton({required this.texto, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Center(
        child: Text(
          texto,
          style: const TextStyle(
            color: Color(0xFF2B5C6B),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
