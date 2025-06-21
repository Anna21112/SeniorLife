import 'package:flutter/material.dart';
import '../telaPerfilAcompanhante.dart';
import '../tela_saude.dart';

// Adicione os imports das futuras telas de dependentes aqui
// import '../tela_adicionar_dependente.dart';
// import '../tela_editar_dependentes.dart';
// import '../tela_perfil_dependente.dart';

// Modelo para representar um dependente.
// No futuro, você irá popular uma lista desses objetos com os dados da sua API.
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
          Image.asset('assets/imagens/logo.png', height: 40),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white, size: 30),
            onPressed:
                onProfilePressed ??
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
    // No futuro, você usará um FutureBuilder ou outro gerenciador de estado
    // para buscar esses dados e reconstruir o widget.
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
                icon: const Icon(Icons.settings, color: Colors.white, size: 30),
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
                    // NAVEGAÇÃO: COLOQUE AQUI O CAMINHO PARA A TELA DE PERFIL DO DEPENDENTE
                    // Exemplo: Navigator.push(context, MaterialPageRoute(builder: (_) => TelaPerfilDependente(dependenteId: value.id)));
                  } else if (value == 'adicionar') {
                    // Ação ao clicar em "Adicionar dependente"
                    print('Navegar para Adicionar Dependente');
                    // NAVEGAÇÃO: COLOQUE AQUI O CAMINHO PARA A TELA DE ADICIONAR DEPENDENTE
                    // Exemplo: Navigator.push(context, MaterialPageRoute(builder: (_) => TelaAdicionarDependente()));
                  } else if (value == 'editar') {
                    // Ação ao clicar em "Editar Dependentes"
                    print('Navegar para Editar Dependentes');
                    // NAVEGAÇÃO: COLOQUE AQUI O CAMINHO PARA A TELA DE EDITAR DEPENDENTES
                    // Exemplo: Navigator.push(context, MaterialPageRoute(builder: (_) => TelaEditarDependentes()));
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
                    }).toList(),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'adicionar',
                      child: Row(
                        children: [
                          const Text('Adicionar dependente'),
                          const Spacer(),
                          const Icon(Icons.add_circle, color: Colors.green),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'editar',
                      child: Row(
                        children: [
                          const Text('Editar Dependentes'),
                          const Spacer(),
                          const Icon(Icons.edit, color: Color(0xFF31A2C6)),
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
                    'assets/imagens/icone_senhor.png', // coloque o caminho da sua imagem aqui
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
                onPressed: onCalendarPressed ?? () {},
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
                      texto: 'Perfil',
                      onPressed: () {
                        Navigator.pop(context);
                        // Coloque aqui a navegação para a tela correta se desejar.
                      },
                    ),
                    const Divider(thickness: 2),
                    _MenuButton(
                      texto: 'Lembretes',
                      onPressed: () {
                        Navigator.pop(context);
                        // Navegação para Lembretes
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
                        // Navegação para Notificações
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
